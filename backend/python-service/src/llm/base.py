from abc import ABC, abstractmethod


class BaseLLMClient(ABC):
    """
    所有大模型的统一接口
    """
    @abstractmethod
    def generate(self,system_prompt: str, user_prompt: str,max_tokens: int = 500) -> str:
        """
        生成文本内容
        Returns:
            str:模型生成的文本
        """
        pass