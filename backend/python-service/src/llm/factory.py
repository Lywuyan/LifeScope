from src.config import settings
from src.llm.qwen import QwenClient


def create_llm_client():
    provider = settings.llm_provider.lower()

    if provider == "qwen":
        return QwenClient()

    raise ValueError(f"不支持的 LLM 提供商: {provider}")