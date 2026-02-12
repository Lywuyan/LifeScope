# ============================================================
# FILE: app/etl.py
# ETL 核心逻辑
#   process_raw_message()   — 单条消息入库
#   compute_daily_metrics() — 全天汇总指标计算
# ============================================================
from datetime import date
from loguru import logger

from src.database import SessionLocal, RawBehaviorData, DailyMetrics
from src.redis_service import redis_service


# ── 1. 处理单条原始消息 ──────────────────────────
def process_raw_message(payload: dict):
    """
    payload 期望格式:
    {
        "user_id":      123,
        "record_date":  "2025-02-03",   # ISO 日期字符串
        "app_name":     "微信",
        "usage_mins":   45,
        "category":     "social"        # social / game / work / browser / other
    }
    """
    # ── 1. 基本校验 ──────────────────────────
    required = ("user_id", "record_date", "app_name", "usage_mins")
    for key in required:
        if key not in payload:
            logger.warning(f"[ETL] 缺少字段 '{key}'，丢弃消息")
            return

    # ── 2. 数据清理 ──────────────────────────
    user_id = payload["user_id"]
    app_name = payload["app_name"].strip()
    usage_mins = payload["usage_mins"]

    # 过滤空值
    if not app_name:
        logger.warning(f"[ETL] APP 名称为空，丢弃消息")
        return

    # 异常值检测
    if usage_mins < 1 or usage_mins > 1440:  # 1 天 = 1440 分钟
        logger.warning(f"[ETL] 使用时长异常: {usage_mins}，丢弃消息")
        return

    # 日期验证
    try:
        record_date = date.fromisoformat(payload["record_date"])
        if record_date > date.today():
            logger.warning(f"[ETL] 日期是未来: {record_date}，丢弃消息")
            return
    except ValueError:
        logger.warning(f"[ETL] 日期格式错误: {payload['record_date']}")
        return

    # ── 3. 去重处理（同一天同一个 APP 取最大值或累加）──
    with SessionLocal() as db:
        existing = db.query(RawBehaviorData).filter(
            RawBehaviorData.user_id == user_id,
            RawBehaviorData.record_date == record_date,
            RawBehaviorData.app_name == app_name
        ).first()

        if existing:
            # 策略 A: 累加（推荐）
            existing.usage_mins += usage_mins
            logger.info(f"[ETL] 累加数据 → {app_name}: {existing.usage_mins}min")
        else:
            # 新增
            row = RawBehaviorData(
                user_id=user_id,
                record_date=record_date,
                app_name=app_name,
                usage_mins=usage_mins,
                category=payload.get("category", "other")
            )
            db.add(row)

        db.commit()
        logger.info(
            f"[ETL] 入库成功 → user={payload['user_id']}, app={payload['app_name']}, mins={payload['usage_mins']}")
        # 读取当日所有数据
        today_data = (
            db.query(
                RawBehaviorData.app_name,
                RawBehaviorData.usage_mins,
                RawBehaviorData.category
            )
            .filter(
                RawBehaviorData.user_id == payload["user_id"],
                RawBehaviorData.record_date == record_date
            )
            .all()
        )

        # 序列化并缓存
        data = [
            {"app_name": r.app_name, "usage_mins": r.usage_mins, "category": r.category}
            for r in today_data
        ]
        redis_service.cache_daily_data(payload["user_id"], record_date, data)

# ── 2. 计算每日汇总指标 ────────────────────────────
def compute_daily_metrics(user_id: int, target_date: date):
    logger.info(f"[ETL] 开始计算 → user={user_id}, date={target_date}")

    cached_data = redis_service.get_daily_data(user_id, target_date)

    category_map = {}
    app_usage = {}

    source_data = []

    # ── 1. 数据来源 ─────────────────────
    if cached_data:
        logger.info("[ETL] 使用 Redis 原始数据")
        source_data = cached_data
    else:
        logger.info("[ETL] Redis 未命中，查询 DB")
        with SessionLocal() as db:
            source_data = (
                db.query(
                    RawBehaviorData.category,
                    RawBehaviorData.app_name,
                    RawBehaviorData.usage_mins
                )
                .filter(
                    RawBehaviorData.user_id == user_id,
                    RawBehaviorData.record_date == target_date
                )
                .all()
            )
            source_data = [
                {
                    "category": r.category,
                    "app_name": r.app_name,
                    "usage_mins": r.usage_mins
                }
                for r in source_data
            ]
    # ── 2. 聚合计算 ─────────────────────
    for row in source_data:
        category_map[row["category"]] = category_map.get(row["category"], 0) + row["usage_mins"]
        app_usage[row["app_name"]] = app_usage.get(row["app_name"], 0) + row["usage_mins"]

    total_mins = sum(category_map.values())
    top_app = max(app_usage.items(), key=lambda x: x[1])[0] if app_usage else None

    # ── 3. 写入 daily_metrics ────────────
    with SessionLocal() as db:
        try:
            existing = (
                db.query(DailyMetrics)
                .filter(
                    DailyMetrics.user_id == user_id,
                    DailyMetrics.metric_date == target_date
                )
                .first()
            )

            if existing:
                existing.total_active_mins = total_mins
                existing.social_mins = category_map.get("social", 0)
                existing.game_mins = category_map.get("game", 0)
                existing.work_mins = category_map.get("work", 0)
                existing.browser_mins = category_map.get("browser", 0)
                existing.top_app = top_app
            else:
                db.add(DailyMetrics(
                    user_id=user_id,
                    metric_date=target_date,
                    total_active_mins=total_mins,
                    social_mins=category_map.get("social", 0),
                    game_mins=category_map.get("game", 0),
                    work_mins=category_map.get("work", 0),
                    browser_mins=category_map.get("browser", 0),
                    top_app=top_app,
                ))

            db.commit()

        except Exception:
            db.rollback()
            raise

    # ── 4. 缓存结果 ─────────────────────
    redis_service.cache_metrics(user_id, target_date, {
        "total_active_mins": total_mins,
        "social_mins": category_map.get("social", 0),
        "game_mins": category_map.get("game", 0),
        "work_mins": category_map.get("work", 0),
        "browser_mins": category_map.get("browser", 0),
        "top_app": top_app,
    })

    logger.info(f"[ETL] 完成 → total={total_mins}min")

