from datetime import date
from loguru import logger

from src import llm_service
from src.database import SessionLocal, DailyMetrics, AIReport,Users
from src.llm_service import llm_service
from src.redis_service import redis_service


class ReportService:

    def generate_daily_report(
            self,
            user_id: int,
            target_date: date,
            style: str = "funny"
    ) -> dict:
        """
        生成某用户某天的报告

        Returns:
            {
                "report_id": 123,
                "content": "报告内容...",
                "style": "funny",
                "date": "2025-02-10"
            }
        """
        with SessionLocal() as db:
            # 1. 查询用户信息
            user = db.query(Users).filter(Users.id == user_id).first()
            if not user:
                raise Exception("用户不存在")

            # 2. 查询 daily_metrics
            metrics = (
                db.query(DailyMetrics)
                .filter(
                    DailyMetrics.user_id == user_id,
                    DailyMetrics.metric_date == target_date
                )
                .first()
            )

            if not metrics:
                raise Exception("该日期暂无数据")

            # 3. 准备数据
            user_data = {
                "username": user.username,
                "date": str(target_date)
            }

            metrics_data = {
                "total_active_mins": metrics.total_active_mins or 0,
                "social_mins": metrics.social_mins or 0,
                "game_mins": metrics.game_mins or 0,
                "work_mins": metrics.work_mins or 0,
                "top_app": metrics.top_app or "未知",
                "peak_hour": metrics.peak_hour or 12,
                "change_pct": 0,  # TODO: 从 Redis 读昨天数据对比
            }

            # 4. 调用 LLM 生成
            content = llm_service.generate_report(user_data, metrics_data, style)

            # 5. 存储到数据库
            report = AIReport(
                user_id=user_id,
                report_date=target_date,
                report_type="daily",
                content=content,
                style=style,
            )
            db.add(report)
            db.commit()
            db.refresh(report)

            # 6. 缓存到 Redis
            redis_service.client.setex(
                f"user:{user_id}:report:{target_date}",
                604800,  # 7 天
                content
            )

            logger.info(f"[Report] 生成完成: user={user_id}, date={target_date}, id={report.id}")

            return {
                "report_id": report.id,
                "content": content,
                "style": style,
                "date": str(target_date),
            }


report_service = ReportService()