# ============================================================
# FILE: app/database.py
# SQLAlchemy 引擎 + ORM 基类
# Python 侧主要写 daily_metrics，其他表目前只读
# ============================================================
from sqlalchemy import create_engine, Column, Integer, String, Date, Float, Text, DateTime, func
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from sqlalchemy.pool import QueuePool

from src.config import settings
from src.util.snowflake import IdWorker

# ── 引擎 ──────────────────────────────────────
engine = create_engine(
    settings.db_url,
    poolclass=QueuePool,
    pool_size=5,
    pool_pre_ping=True,  # 连接前 ping，避免用到断掉的连接
    echo=False  # 开发期可改为 True 打印 SQL
)

# ── Session 工厂 ──────────────────────────────
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# ── ORM 基类 ──────────────────────────────────
class Base(DeclarativeBase):
    pass


# 创建一个全局的雪花ID生成器实例
id_worker = IdWorker(datacenter_id=1, worker_id=1, sequence=0)

# ── Users 模型 ──────────────────────────
class Users(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    username = Column(String(64), nullable=False)
    email = Column(String(128))
    password_hash = Column(String(256), nullable=False)
    avatar_url = Column(String(256))
    fcm_token = Column(String(256))

# ── DailyMetrics 模型 ──────────────────────────
class DailyMetrics(Base):
    __tablename__ = "daily_metrics"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable=False)
    metric_date = Column(Date, nullable=False)
    total_active_mins = Column(Integer)
    social_mins = Column(Integer)
    game_mins = Column(Integer)
    work_mins = Column(Integer)
    browser_mins = Column(Integer)
    top_app = Column(String(128))
    peak_hour = Column(Integer)
    task_completion_rate = Column(Float)

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # 使用雪花算法生成唯一ID
        self.id = id_worker.get_id()


# ── RawBehaviorData 模型（只读） ────────────────
class RawBehaviorData(Base):
    __tablename__ = "raw_behavior_data"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable=False)
    record_date = Column(Date, nullable=False)
    app_name = Column(String(128), nullable=False)
    usage_mins = Column(Integer, nullable=False)
    category = Column(String(64))

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # 使用雪花算法生成唯一ID
        self.id = id_worker.get_id()

# ── AiReport 模型 ────────────────
class AIReport(Base):
    __tablename__ = "ai_reports"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable=False)
    report_date = Column(Date, nullable=False)
    report_type = Column(String(32), nullable=False)  # daily/weekly/monthly
    content = Column(Text)
    chart_url = Column(String(256))
    style = Column(String(32), default="funny")
    is_liked = Column(Integer, default=0)
    is_shared = Column(Integer, default=0)
    created_at = Column(DateTime, server_default=func.now())

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # 使用雪花算法生成唯一ID
        self.id = id_worker.get_id()

# ── 工具函数 ──────────────────────────────────
def get_db():
    """依赖注入用的 Session 生成器"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
