from src.redis_service import redis_service
from datetime import date

# 写入测试数据
redis_service.cache_daily_data(
    user_id=1,
    target_date=date.today(),
    data=[
        {"app_name": "微信", "usage_mins": 45, "category": "social"},
        {"app_name": "抖音", "usage_mins": 30, "category": "social"},
    ]
)

# 读取
data = redis_service.get_daily_data(1, date.today())
print(data)