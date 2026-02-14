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

【成就系统】
{achievements}

请生成一份 100-150 字的分析报告，要求：
1. 包含至少 2 个具体数据点
2. 符合"{style}"风格
3. 如果有挑战，评价进度
4. 加入 1-2 个 emoji 增加趣味性
5. 如果获得成就，要特别提及并祝贺
6. 只返回报告内容，不要有"报告："等前缀
"""

WEEKLY_PROMPT_TEMPLATE = """
请根据以下一周数据生成周度行为分析报告：

【基本信息】
- 用户：{username}
- 周期：{start_date} ~ {end_date}

【数据汇总】
- 本周总活跃时间：{total_mins} 分钟（日均 {avg_daily_mins} 分钟）
- 社交 APP 累计：{social_mins} 分钟
- 游戏累计：{game_mins} 分钟
- 工作/学习累计：{work_mins} 分钟
- 本周最常用 APP：{top_app}
- 最活跃的一天：{peak_day}（{peak_day_mins} 分钟）
- 最不活跃的一天：{low_day}（{low_day_mins} 分钟）

【对比上周】
- 总时长变化：{change_sign}{change_pct}%
- 新获得徽章：{new_badges}

请生成一份 200-300 字的周报，要求：
1. 有整体总结，也有亮点/槽点
2. 符合"{style}"风格
3. 如果有新徽章，点名表扬
4. 加入 2-3 个 emoji
5. 给出下周的一个小目标建议
"""

MONTHLY_PROMPT_TEMPLATE = """
请根据以下一月数据生成月度行为总结报告：

【基本信息】
- 用户：{username}
- 月份：{month}

【数据汇总】
- 本月总活跃时间：{total_mins} 分钟（日均 {avg_daily_mins} 分钟）
- 数据覆盖天数：{active_days} 天
- 最常用 APP TOP3：{top_3_apps}
- 社交占比：{social_pct}%
- 游戏占比：{game_pct}%
- 工作占比：{work_pct}%
- 本月获得徽章：{badges_earned}

【趋势】
- 对比上月总时长：{change_sign}{change_pct}%
- 活跃度趋势：{trend}（上升/下降/稳定）

请生成一份 300-400 字的月度总结，要求：
1. 回顾整月亮点和不足
2. 用数据对比展示变化
3. 符合"{style}"风格
4. 给予下月建议和挑战
5. 如果有多个徽章，做个"月度成就回顾"
"""

EASTER_EGG_CONDITIONS = {
    # 时间相关成就
    "数字极简主义者": lambda m: m["total_active_mins"] == 0,  # 全天无手机
    "早起鸟儿": lambda m: m.get("peak_hour", 0) < 7,  # 凌晨活跃
    "夜猫子": lambda m: m.get("peak_hour", 0) >= 23,  # 深夜活跃

    # 社交达人成就
    "社交帝王": lambda m: m["social_mins"] > 240,  # 超过4小时社交
    "社交达人": lambda m: m["social_mins"] > 180,  # 超过3小时社交
    "社交新手": lambda m: 60 < m["social_mins"] <= 120,  # 1-2小时社交

    # 工作学习成就
    "工作狂魔": lambda m: m["work_mins"] > 480,  # 超过8小时工作
    "工作狂": lambda m: m["work_mins"] > 360,  # 超过6小时工作
    "学霸模式": lambda m: m["work_mins"] > 240,  # 超过4小时学习
    "专注力大师": lambda m: 180 < m["work_mins"] <= 300,  # 3-5小时专注

    # 游戏娱乐成就
    "游戏王者": lambda m: m["game_mins"] > 240,  # 超过4小时游戏
    "娱乐大师": lambda m: m["game_mins"] > 120,  # 超过2小时娱乐
    "休闲玩家": lambda m: 30 < m["game_mins"] <= 90,  # 半小时到1.5小时娱乐

    # 平衡生活成就
    "生活平衡大师": lambda m: (
            m["work_mins"] > 120 > m["game_mins"] and
            m["social_mins"] > 60
    ),  # 工作社交均衡，娱乐适度

    # 特殊成就
    "效率之王": lambda m: (
            m["work_mins"] > 240 and
            m["total_active_mins"] < 480
    ),  # 高效工作但总体使用时间合理

    "健康作息": lambda m: (
            m["total_active_mins"] < 180 and
            7 <= m.get("peak_hour", 12) <= 22
    ),  # 使用时间短且活跃时间合理
}

# 成就对应的描述和图标
ACHIEVEMENT_DETAILS = {
    "数字极简主义者": {"icon": "🧘", "desc": "一整天都没碰手机，真正的数字排毒大师！"},
    "早起鸟儿": {"icon": "🌅", "desc": "凌晨就开始活跃，你是早起的冠军！"},
    "夜猫子": {"icon": "🌙", "desc": "深夜还在活跃，夜生活丰富多彩！"},
    "社交帝王": {"icon": "👑", "desc": "社交时间超过4小时，朋友圈的王者！"},
    "社交达人": {"icon": "👥", "desc": "社交时间长达3小时以上，人脉广泛！"},
    "社交新手": {"icon": "👋", "desc": "适度社交，保持良好的人际关系！"},
    "工作狂魔": {"icon": "💼", "desc": "工作超过8小时，职场精英本精！"},
    "工作狂": {"icon": "⚡", "desc": "工作超过6小时，敬业精神可嘉！"},
    "学霸模式": {"icon": "📚", "desc": "学习时间超过4小时，求知若渴！"},
    "专注力大师": {"icon": "🎯", "desc": "3-5小时专注工作学习，效率爆表！"},
    "游戏王者": {"icon": "🏆", "desc": "游戏时间超过4小时，电竞潜力股！"},
    "娱乐大师": {"icon": "🎮", "desc": "娱乐时间超过2小时，生活多姿多彩！"},
    "休闲玩家": {"icon": "😊", "desc": "适度娱乐，劳逸结合刚刚好！"},
    "生活平衡大师": {"icon": "⚖️", "desc": "工作社交娱乐完美平衡，生活艺术家！"},
    "效率之王": {"icon": "🚀", "desc": "高效工作但不过度使用手机，时间管理大师！"},
    "健康作息": {"icon": "💚", "desc": "使用时间合理且作息规律，健康生活典范！"},
}


def check_achievements(metrics: dict) -> list:
    """
    检查用户获得的成就
    Returns:
        list: [{'name': '成就名称', 'icon': '图标', 'desc': '描述'}, ...]
    """
    achievements = []
    for achievement_name, condition_func in EASTER_EGG_CONDITIONS.items():
        if condition_func(metrics):
            detail = ACHIEVEMENT_DETAILS.get(achievement_name, {})
            achievements.append({
                "name": achievement_name,
                "icon": detail.get("icon", "⭐"),
                "desc": detail.get("desc", f"获得成就：{achievement_name}")
            })
    return achievements


def format_achievements(achievements: list) -> str:
    """
    格式化成就列表为字符串
    """
    if not achievements:
        return "暂无特殊成就"

    achievement_lines = []
    for ach in achievements:
        achievement_lines.append(f"{ach['icon']} {ach['name']}: {ach['desc']}")

    return "\n".join(achievement_lines)

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

    # 检查成就
    achievements = check_achievements(metrics)
    achievements_str = format_achievements(achievements)

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
        achievements=achievements_str,
    )