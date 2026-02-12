import dashscope
from dashscope import Generation
from loguru import logger


from src.config import settings
from src.llm.base import BaseLLMClient


class QwenClient(BaseLLMClient):

    def __init__(self):
        dashscope.api_key = settings.llm_api_key
        self.model = settings.llm_model

    def generate(self,system_prompt: str, user_prompt: str,max_tokens: int = 500) -> str:
        logger.info(f"[Qwen] 模型调用：{self.model}")
        try:
            response = Generation.call(
                model=self.model,
                messages=[
                    {'role':'system','content':system_prompt},
                    {'role':'user','content':user_prompt}
                ],
                result_format = "message",
                max_tokens = max_tokens,
                temperature = 0.8,
            )
            if response.status_code != 200:
                logger.error(f"[Qwen] 模型调用失败：{response.status_code} {response.message}")
                raise RuntimeError("模型调用失败")
            content = response.output["choices"][0]["message"]["content"]
            return content.strip()
        except Exception as e:
            logger.error(f"[Qwen] 未知异常：{e}")
            raise