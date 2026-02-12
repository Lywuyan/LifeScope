import json
import redis
from datetime import date, timedelta
from loguru import logger
from src.config import settings


class RedisService:
    def __init__(self):
        self.client = redis.from_url(settings.redis_url)

    # ── 缓存当日原始数据 ──────────────────────────
    def cache_daily_data(self, user_id: int, target_date: date, data: list):
        """
        缓存某用户某天的所有原始数据
        data: [{"app_name": "微信", "usage_mins": 45, "category": "social"}, ...]
        """
        key = f"user:{user_id}:daily:{target_date}"
        self.client.setex(
            key,
            86400 + 3600,  # TTL: 25 小时（确保第二天凌晨前还能读到）
            json.dumps(data)
        )
        logger.info(f"[Redis] 缓存数据 → {key}")

    def get_daily_data(self, user_id: int, target_date: date):
        """
        从缓存读取当日数据
        返回: list 或 None
        """
        key = f"user:{user_id}:daily:{target_date}"
        cached = self.client.get(key)
        if cached:
            logger.info(f"[Redis] 缓存命中 → {key}")
            return json.loads(cached)
        return None

    # ── 缓存 daily_metrics 结果 ──────────────────
    def cache_metrics(self, user_id: int, target_date: date, metrics: dict):
        key = f"user:{user_id}:metrics:{target_date}"
        self.client.setex(
            key,
            604800,  # TTL: 7 天
            json.dumps(metrics)
        )

    def get_metrics(self, user_id: int, target_date: date):
        key = f"user:{user_id}:metrics:{target_date}"
        cached = self.client.get(key)
        if cached:
            return json.loads(cached)
        return None

    # ── 清理过期缓存 ──────────────────────────────
    def clear_old_data(self, user_id: int):
        """清理 7 天前的缓存"""
        old_date = date.today() - timedelta(days=7)
        pattern = f"user:{user_id}:daily:{old_date}"
        keys = self.client.keys(pattern)
        if keys:
            self.client.delete(*keys)
            logger.info(f"[Redis] 清理旧缓存 {len(keys)} 条")


redis_service = RedisService()