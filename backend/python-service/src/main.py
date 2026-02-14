# ============================================================
# FILE: app/main.py
# FastAPI 入口
#   启动时 → 拉起 Kafka 消费线程
#   提供 /health 和手动触发 ETL 的接口
# 启动命令: uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
# ============================================================
from datetime import date,timedelta
from typing import Optional

from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import FastAPI, HTTPException
from loguru import logger
from sqlalchemy import func

from src.badge_service import badge_service
from src.config import settings
from src import etl
from src.database import SessionLocal, RawBehaviorData, AIReport, DailyMetrics, Badge
from src.kafka_consumer import start_consumer_thread
from src.report_service import report_service

app = FastAPI(title="LifeScope AI Service", version="1.0.0", debug=True)

scheduler = BackgroundScheduler()


def daily_compute_job():
    """每天凌晨 1 点执行"""
    yesterday = date.today() - timedelta(days=1)
    logger.info(f"[定时任务] 开始计算 {yesterday} 的指标")

    with SessionLocal() as db:
        # 查询所有有数据的用户
        user_ids = (
            db.query(RawBehaviorData.user_id)
            .filter(RawBehaviorData.record_date == yesterday)
            .distinct()
            .all()
        )

        for (user_id,) in user_ids:
            try:
                etl.compute_daily_metrics(user_id, yesterday)
            except Exception as e:
                logger.error(f"[定时任务] 失败 user={user_id}: {e}")

    logger.info(f"[定时任务] 完成，处理 {len(user_ids)} 个用户")


# 添加定时任务
scheduler.add_job(daily_compute_job, 'cron', hour=1, minute=0)

# ── 启动事件 ─────────────────────────────────────
@app.on_event("startup")
async def startup():
    logger.info("=== LifeScope Python Service 启动 ===")
    logger.info(f"  MySQL : {settings.db_host}:{settings.db_port}/{settings.db_name}")
    logger.info(f"  Kafka : {settings.kafka_bootstrap}")
    logger.info(f"  端口  : {settings.app_port}")
    start_consumer_thread()  # 后台拉数据


# ── 健康检查 ─────────────────────────────────────
@app.get("/health")
async def health():
    return {"status": "ok", "service": "lifescope-ai"}


# ── 手动触发 ETL 汇总（开发期方便测试）────────────
@app.post("/api/etl/compute/{user_id}/{target_date}")
async def trigger_compute(user_id: int, target_date: date):
    """
    手动触发某用户某天的指标汇总
    示例: POST /api/etl/compute/1/2025-02-03
    生产环境会由定时任务触发，这里留给开发期手动调试
    """
    etl.compute_daily_metrics(user_id, target_date)
    return {"status": "ok", "user_id": user_id, "date": str(target_date)}


@app.post("/api/reports/generate")
async def generate_report(
        user_id: int,
        target_date: date,
        style: str = "funny"
):
    """
    生成报告
    POST /api/reports/generate?user_id=1&target_date=2025-02-10&style=funny
    """
    try:
        result = report_service.generate_daily_report(user_id, target_date, style)
        return {"success": True, "data": result}
    except Exception as e:
        logger.error(f"[API] 生成报告失败: {e}")
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/reports/daily/{user_id}/{target_date}")
async def get_daily_report(user_id: int, target_date: date):
    """
    查询某天的报告
    GET /api/reports/daily/1/2025-02-10
    """
    with SessionLocal() as db:
        report = (
            db.query(AIReport)
            .filter(
                AIReport.user_id == user_id,
                AIReport.report_date == target_date,
                AIReport.report_type == "daily"
            )
            .first()
        )

        if not report:
            raise HTTPException(status_code=404, detail="报告不存在")

        return {
            "success": True,
            "data": {
                "id": report.id,
                "content": report.content,
                "style": report.style,
                "date": str(report.report_date),
                "is_liked": bool(report.is_liked),
            }
        }

@app.get("/api/stats/weekly/{user_id}")
async def get_weekly_stats(user_id: int,end_date: Optional[date] = None):
    """
    查询某用户的周统计数据
    GET /api/stats/weekly/1
    """
    if not end_date:
        end_date = date.today()
    start_date = end_date - timedelta(days=6)

    with SessionLocal() as db:
        rows = (
            db.query(DailyMetrics)
            .filter(
                DailyMetrics.user_id == user_id,
                DailyMetrics.metric_date.between(start_date, end_date)
            )
            .order_by(DailyMetrics.metric_date)
            .all()
        )

        data = [
            {
                "date": str(r.metric_date),
                "total_mins": r.total_active_mins or 0,
                "social_mins": r.social_mins or 0,
                "game_mins": r.game_mins or 0,
                "work_mins": r.work_mins or 0,
                "browser_mins": r.browser_mins or 0,
                "top_app": r.top_app,
            }
            for r in rows
        ]
    return {"success": True, "data": data}

@app.get("/api/stats/monthly/{user_id}")
async def get_monthly_stats(user_id: int, end_date: Optional[date] = None):
    """
    查询某用户的月统计数据
    GET /api/stats/monthly/1
    """
    if not end_date:
        end_date = date.today()
    start_date = end_date - timedelta(days=29)

    with SessionLocal() as db:
        rows = (
            db.query(DailyMetrics)
            .filter(
                DailyMetrics.user_id == user_id,
                DailyMetrics.metric_date.between(start_date, end_date)
            )
            .order_by(DailyMetrics.metric_date)
            .all()
        )
        data = [
            {
                "date": str(r.metric_date),
                "total_mins": r.total_active_mins or 0,
            }
            for r in rows
        ]
    return {"success": True, "data": data}

@app.get("/api/stats/top-apps/{user_id}/{target_date}")
async def get_top_apps(user_id: int, target_date: date, limit: int = 5):
    """获取某天 TOP N 应用"""

    with SessionLocal() as db:
        rows = (
            db.query(
                RawBehaviorData.app_name,
                func.sum(RawBehaviorData.usage_mins).label("total")
            )
            .filter(
                RawBehaviorData.user_id == user_id,
                RawBehaviorData.record_date == target_date
            )
            .group_by(RawBehaviorData.app_name)
            .order_by(func.sum(RawBehaviorData.usage_mins).desc())
            .limit(limit)
            .all()
        )

        data = [{"app_name": r.app_name, "usage_mins": r.total} for r in rows]

    return {"success": True, "data": data}

@app.get("/api/reports/list/{user_id}")
async def list_reports(
    user_id: int,
    report_type: str = "daily",
    page: int = 1,
    size: int = 10
):
    """分页查询报告列表"""
    offset = (page - 1) * size

    with SessionLocal() as db:
        total = (
            db.query(func.count(AIReport.id))
            .filter(AIReport.user_id == user_id, AIReport.report_type == report_type)
            .scalar()
        )

        rows = (
            db.query(AIReport)
            .filter(AIReport.user_id == user_id, AIReport.report_type == report_type)
            .order_by(AIReport.report_date.desc())
            .offset(offset)
            .limit(size)
            .all()
        )

        items = [
            {
                "id": r.id,
                "date": str(r.report_date),
                "content": r.content[:80] + "..." if len(r.content) > 80 else r.content,
                "full_content": r.content,
                "style": r.style,
                "is_liked": bool(r.is_liked),
            }
            for r in rows
        ]

    return {
        "success": True,
        "data": {"items": items, "total": total, "page": page, "size": size}
    }

@app.get("/api/badges/all")
async def get_all_badges():
    """获取所有徽章定义"""
    with SessionLocal() as db:
        rows = db.query(Badge).all()
        data = [
            {
                "code": b.code, "name": b.name, "icon": b.icon,
                "description": b.description,
            }
            for b in rows
        ]
    return {"success": True, "data": data}

@app.get("/api/badges/{user_id}")
async def get_user_badges(user_id: int):
    """获取用户已获得的徽章"""
    badges = badge_service.get_user_badges(user_id)
    return {"success": True, "data": badges}

