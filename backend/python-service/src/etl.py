# ============================================================
# FILE: app/etl.py
# ETL 核心逻辑
#   process_raw_message()   — 单条消息入库
#   compute_daily_metrics() — 全天汇总指标计算
# ============================================================
from datetime import date
from loguru import logger
from sqlalchemy import func

from src.database import SessionLocal, RawBehaviorData, DailyMetrics


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
    # ── 基本校验 ────────────────────────────────
    required = ("user_id", "record_date", "app_name", "usage_mins")
    for key in required:
        if key not in payload:
            logger.warning(f"[ETL] 缺少字段 '{key}'，丢弃消息: {payload}")
            return

    try:
        record_date = date.fromisoformat(payload["record_date"])
    except ValueError:
        logger.warning(f"[ETL] 日期格式错误: {payload['record_date']}")
        return

    # ── 入库 ─────────────────────────────────────
    with SessionLocal() as db:
        row = RawBehaviorData(
            user_id=payload["user_id"],
            record_date=record_date,
            app_name=payload["app_name"],
            usage_mins=payload["usage_mins"],
            category=payload.get("category", "other"),
        )
        db.add(row)
        db.commit()
        logger.info(
            f"[ETL] 入库成功 → user={payload['user_id']}, app={payload['app_name']}, mins={payload['usage_mins']}")


# ── 2. 计算每日汇总指标 ────────────────────────────
def compute_daily_metrics(user_id: int, target_date: date):
    """
    从 raw_behavior_data 中聚合指定用户指定日期的数据,
    写入 daily_metrics 表（同一天存在则更新）。
    """
    with SessionLocal() as db:
        # ── 按 category 分组求和 ────────────────
        rows = (
            db.query(
                RawBehaviorData.category,
                func.sum(RawBehaviorData.usage_mins).label("total")
            )
            .filter(
                RawBehaviorData.user_id == user_id,
                RawBehaviorData.record_date == target_date
            )
            .group_by(RawBehaviorData.category)
            .all()
        )

        category_map = {r.category: r.total for r in rows}  # {"social": 120, "game": 45, ...}
        total_mins = sum(category_map.values())

        # ── 找出使用最多的 APP ──────────────────
        top_app_row = (
            db.query(RawBehaviorData.app_name, func.sum(RawBehaviorData.usage_mins).label("total"))
            .filter(
                RawBehaviorData.user_id == user_id,
                RawBehaviorData.record_date == target_date
            )
            .group_by(RawBehaviorData.app_name)
            .order_by(func.sum(RawBehaviorData.usage_mins).desc())
            .first()
        )
        top_app = top_app_row.app_name if top_app_row else None

        # ── 写入 / 更新 daily_metrics ──────────
        existing = (
            db.query(DailyMetrics)
            .filter(DailyMetrics.user_id == user_id, DailyMetrics.metric_date == target_date)
            .first()
        )

        if existing:
            # 更新
            existing.total_active_mins = total_mins
            existing.social_mins = category_map.get("social", 0)
            existing.game_mins = category_map.get("game", 0)
            existing.work_mins = category_map.get("work", 0)
            existing.browser_mins = category_map.get("browser", 0)
            existing.top_app = top_app
            # peak_hour 和 task_completion_rate 后续扩展
        else:
            # 新增
            metrics = DailyMetrics(
                user_id=user_id,
                metric_date=target_date,
                total_active_mins=total_mins,
                social_mins=category_map.get("social", 0),
                game_mins=category_map.get("game", 0),
                work_mins=category_map.get("work", 0),
                browser_mins=category_map.get("browser", 0),
                top_app=top_app,
            )
            db.add(metrics)

        db.commit()
        logger.info(f"[ETL] daily_metrics 更新完成 → user={user_id}, date={target_date}, total={total_mins}min")
