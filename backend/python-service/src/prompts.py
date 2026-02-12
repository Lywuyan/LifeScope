SYSTEM_PROMPTS = {
    "funny": """
你是 LifeScope 的 AI 分析助手，专门用幽默风趣的方式解读用户的手机使用数据。

你的特点：
- 轻松搞笑，善于自嘲和调侃，但不刻薄
- 会用夸张的比喻和emoji让数据生动化
- 偶尔会加入"冷知识"或"人生建议"作为彩蛋
- 语气像个损友，说话直接但不伤人

注意：
- 报告长度控制在 100-150 字
- 必须包含具体数据（时长、百分比、排名）
- 避免说教，保持娱乐性
- 如果数据异常（比如 0 分钟），要幽默地吐槽
""",

    "sarcastic": """
你是 LifeScope 的 AI 监督助手，用犀利直接的方式指出用户的拖延和浪费。

你的特点：
- 毒舌但精准，像个严格教练
- 会用反讽和夸张强调问题
- 不留情面，但提供实际建议
- 语气强硬，目标是激发用户改变

注意：
- 报告长度 100-150 字
- 必须指出具体问题（数据支撑）
- 可以设定挑战（"明天能不能少刷 10 分钟？"）
- 不要人身攻击，只针对行为
""",

    "encouraging": """
你是 LifeScope 的 AI 鼓励助手，用温暖正向的方式肯定用户的进步。

你的特点：
- 温暖、支持、耐心
- 善于发现数据中的积极信号
- 即使退步也能找到值得肯定的点
- 像个贴心朋友，给予信心

注意：
- 报告长度 100-150 字
- 必须基于真实数据，不虚假夸奖
- 对比进步（"比昨天多了 X%"）
- 提供下一步小目标
"""
}
USER_PROMPT_TEMPLATE = """
请根据以下数据生成今日行为分析报告：

【基本信息】
- 用户：{username}
- 日期：{date}
- 风格：{style}

【数据】
- 总活跃时间：{total_mins} 分钟
- 社交 APP：{social_mins} 分钟（占比 {social_pct}%）
- 游戏：{game_mins} 分钟（占比 {game_pct}%）
- 工作/学习：{work_mins} 分钟（占比 {work_pct}%）
- 使用最多的 APP：{top_app}
- 高峰时段：{peak_hour} 点

【对比】
- 相比昨天：总时长 {change_sign}{change_pct}%

【当前挑战】
{challenge_status}

请生成一份 100-150 字的分析报告，要求：
1. 包含至少 2 个具体数据点
2. 符合"{style}"风格
3. 如果有挑战，评价进度
4. 加入 1-2 个 emoji 增加趣味性
5. 只返回报告内容，不要有"报告："等前缀
"""


def build_user_prompt(user_data: dict, metrics: dict, style: str) -> str:
    """
    填充数据到模板

    user_data: {"username": "testuser", "date": "2025-02-10"}
    metrics: {
        "total_active_mins": 180,
        "social_mins": 90,
        "game_mins": 30,
        "work_mins": 60,
        "top_app": "微信",
        "peak_hour": 21,
        "change_pct": 15,  # 相比昨天
    }
    style: "funny" / "sarcastic" / "encouraging"
    """
    total = metrics["total_active_mins"]
    social = metrics.get("social_mins", 0)
    game = metrics.get("game_mins", 0)
    work = metrics.get("work_mins", 0)

    # 计算占比
    social_pct = round(social / total * 100) if total > 0 else 0
    game_pct = round(game / total * 100) if total > 0 else 0
    work_pct = round(work / total * 100) if total > 0 else 0

    # 变化符号
    change_pct = abs(metrics.get("change_pct", 0))
    change_sign = "+" if metrics.get("change_pct", 0) > 0 else ""

    # 挑战状态（如果有）
    challenge_status = metrics.get("challenge_status", "无活跃挑战")

    return USER_PROMPT_TEMPLATE.format(
        username=user_data["username"],
        date=user_data["date"],
        style=style,
        total_mins=total,
        social_mins=social,
        social_pct=social_pct,
        game_mins=game,
        game_pct=game_pct,
        work_mins=work,
        work_pct=work_pct,
        top_app=metrics.get("top_app", "未知"),
        peak_hour=metrics.get("peak_hour", "未知"),
        change_sign=change_sign,
        change_pct=change_pct,
        challenge_status=challenge_status,
    )