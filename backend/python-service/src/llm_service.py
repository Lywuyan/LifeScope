from loguru import logger

from src.llm.factory import create_llm_client
from src.prompts import SYSTEM_PROMPTS, build_user_prompt


class LLMService:

    def __init__(self):
        self.client = create_llm_client()
        logger.info(f"[LLMService] 已初始化模型客户端: {self.client.__class__.__name__}")

    def generate_report(self, user_data: dict, metrics: dict, style: str = "funny") -> str:
        system_prompt = SYSTEM_PROMPTS.get(style, SYSTEM_PROMPTS["funny"])
        user_prompt = build_user_prompt(user_data, metrics, style)

        return self.client.generate(
            system_prompt = system_prompt,
            user_prompt = user_prompt,
            max_tokens = 500
        )

llm_service = LLMService()