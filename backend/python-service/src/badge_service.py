from datetime import date, timedelta
from sqlalchemy import func
from loguru import logger
from src.database import SessionLocal, DailyMetrics, Badge, UserBadge

class BadgeService:

    def check_and_award(self, user_id: int, target_date: date):
        """每日指标计算后调用，检查是否新解锁徽章"""
        with SessionLocal() as db:
            badges = db.query(Badge).all()
            existing = {
                r.badge_id
                for r in db.query(UserBadge).filter(UserBadge.user_id == user_id).all()
            }

            for badge in badges:
                if badge.id in existing:
                    continue

                if self._check_condition(db, user_id, target_date, badge):
                    db.add(UserBadge(user_id=user_id, badge_id=badge.id))
                    db.commit()
                    logger.info(f"[Badge] 🎉 用户 {user_id} 获得徽章: {badge.icon} {badge.name}")

    def _check_condition(self, db, user_id: int, target_date: date, badge) -> bool:
        if badge.condition_type == 'daily_over':
            m = db.query(DailyMetrics).filter(
                DailyMetrics.user_id == user_id,
                DailyMetrics.metric_date == target_date
            ).first()
            return m and (m.total_active_mins or 0) > badge.condition_value

        if badge.condition_type == 'daily_under':
            m = db.query(DailyMetrics).filter(
                DailyMetrics.user_id == user_id,
                DailyMetrics.metric_date == target_date
            ).first()
            return m and 0 < (m.total_active_mins or 0) < badge.condition_value

        if badge.condition_type == 'daily_social':
            m = db.query(DailyMetrics).filter(
                DailyMetrics.user_id == user_id,
                DailyMetrics.metric_date == target_date
            ).first()
            return m and (m.social_mins or 0) > badge.condition_value

        # ...其他条件类型类似
        return False

    def get_user_badges(self, user_id: int) -> list:
        with SessionLocal() as db:
            rows = (
                db.query(Badge, UserBadge.earned_at)
                .join(UserBadge, Badge.id == UserBadge.badge_id)
                .filter(UserBadge.user_id == user_id)
                .all()
            )
            return [
                {
                    "code": b.code, "name": b.name, "icon": b.icon,
                    "description": b.description,
                    "earned_at": str(earned_at),
                }
                for b, earned_at in rows
            ]

badge_service = BadgeService()