# ============================================================
# FILE: app/main.py
# FastAPI 入口
#   启动时 → 拉起 Kafka 消费线程
#   提供 /health 和手动触发 ETL 的接口
# 启动命令: uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
# ============================================================
from datetime import date,timedelta

from apscheduler.schedulers.background import BackgroundScheduler
from fastapi import FastAPI
from loguru import logger

from src.config import settings
from src import etl
from src.database import SessionLocal, RawBehaviorData
from src.kafka_consumer import start_consumer_thread

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
