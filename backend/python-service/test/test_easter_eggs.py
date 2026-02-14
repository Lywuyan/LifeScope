from src.prompts import check_achievements, format_achievements


def test_easter_eggs():
    """测试彩蛋功能"""



    # 测试用例1: 全天无手机 - 数字极简主义者


test_case_1 = {
    "total_active_mins": 0,
    "social_mins": 0,
    "game_mins": 0,
    "work_mins": 0,
    "peak_hour": 12
}

achievements_1 = check_achievements(test_case_1)
print("测试用例1 - 全天无手机:")
print(format_achievements(achievements_1))
print()

# 测试用例2: 社交达人
test_case_2 = {
    "total_active_mins": 200,
    "social_mins": 190,
    "game_mins": 5,
    "work_mins": 5,
    "peak_hour": 21
}

achievements_2 = check_achievements(test_case_2)
print("测试用例2 - 社交达人:")
print(format_achievements(achievements_2))
print()

# 测试用例3: 工作狂 + 生活平衡大师
test_case_3 = {
    "total_active_mins": 300,
    "social_mins": 80,
    "game_mins": 30,
    "work_mins": 190,
    "peak_hour": 15
}

achievements_3 = check_achievements(test_case_3)
print("测试用例3 - 工作狂 + 生活平衡:")
print(format_achievements(achievements_3))
print()

# 测试用例4: 效率之王
test_case_4 = {
    "total_active_mins": 300,
    "social_mins": 60,
    "game_mins": 30,
    "work_mins": 250,
    "peak_hour": 14
}

achievements_4 = check_achievements(test_case_4)
print("测试用例4 - 效率之王:")
print(format_achievements(achievements_4))
print()

# 测试用例5: 健康作息
test_case_5 = {
    "total_active_mins": 120,
    "social_mins": 40,
    "game_mins": 20,
    "work_mins": 60,
    "peak_hour": 10
}

achievements_5 = check_achievements(test_case_5)
print("测试用例5 - 健康作息:")
print(format_achievements(achievements_5))

if __name__ == "__main__":
    test_easter_eggs()
