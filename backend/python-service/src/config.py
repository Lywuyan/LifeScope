# ============================================================
# FILE: app/config.py
# 全局配置 — 所有模块都从这里拿配置，不直接读 os.environ
# ============================================================
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # ── MySQL ────────────────────────────────────
    db_host: str = "localhost"
    db_port: int = 3306
    db_name: str = "lifescope_db"
    db_user: str = "app_user"
    db_pass: str = "app_pass123"

    @property
    def db_url(self) -> str:
        return f"mysql+pymysql://{self.db_user}:{self.db_pass}@{self.db_host}:{self.db_port}/{self.db_name}"

    # ── Redis ────────────────────────────────────
    redis_host: str = "192.168.31.128"
    redis_port: int = 6379
    redis_db:   int = 0

    @property
    def redis_url(self) -> str:
        return f"redis://{self.redis_host}:{self.redis_port}/{self.redis_db}"

    # ── Kafka ────────────────────────────────────
    kafka_bootstrap:        str = "localhost:9092"
    kafka_consumer_group:   str = "lifescope-python-etl"
    kafka_topic_raw_data:   str = "lifescope.raw.data"
    kafka_topic_report_trigger: str = "lifescope.report.trigger"
    kafka_topic_report_done:    str = "lifescope.report.done"

    # ── LLM ──────────────────────────────────────
    llm_api_key:  str = ""
    llm_api_url:  str = "https://api.anthropic.com/v1/messages"
    llm_model:    str = "claude-sonnet-4-20250514"

    # ── 服务 ─────────────────────────────────────
    app_port: int = 8001

    # pydantic-settings 自动从 .env 读取
    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


# 全局单例
settings = Settings()
