<p align="center">
  <h1 align="center">LifeScope</h1>
  <p align="center"><strong>智能生活分析报告 - 用 AI 解读你的数字生活</strong></p>
  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter"/>
    <img src="https://img.shields.io/badge/Spring%20Boot-4.0-6DB33F?logo=spring-boot" alt="Spring Boot"/>
    <img src="https://img.shields.io/badge/FastAPI-0.100+-009688?logo=fastapi" alt="FastAPI"/>
    <img src="https://img.shields.io/badge/Java-17-ED8B00?logo=openjdk" alt="Java"/>
    <img src="https://img.shields.io/badge/Python-3.10+-3776AB?logo=python" alt="Python"/>
    <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"/>
  </p>
</p>

---

## 📖 项目简介

**LifeScope** 是一款智能手机行为分析应用，通过采集用户的日常手机使用数据，利用 LLM（大语言模型）生成**幽默化、个性化**的行为分析报告。它不仅仅是一个屏幕时间统计工具，更是一面带有趣味滤镜的"数字生活之镜"。

### ✨ 核心亮点

- 🤖 **AI 驱动报告** — 三种风格（幽默调侃 / 毒舌吐槽 / 温暖鼓励），让数据"活"起来
- 📊 **数据可视化** — 饼图、柱状图、折线图，直观呈现使用习惯
- 🏆 **成就徽章** — 10+ 趣味成就（早起鸟 🌅、夜猫子 🦉、数字极简 📵 等）
- ⚔️ **挑战系统** — 与好友发起减时/专注/对抗挑战，互相督促
- 👥 **社交互动** — 好友排行榜、报告点赞、邀请好友
- 🔄 **实时数据流** — Kafka 消息队列驱动的端到端数据管道

---

## 🏗️ 技术架构

```
┌──────────────────────────────────────────────────────────┐
│                    Flutter 移动端 (Dart)                    │
│        登录/注册 · 首页 · 手动录入 · 仪表盘 · 报告          │
│      挑战 · 排行榜 · 好友 · 徽章 · 分享海报                │
└──────────────┬──────────────────────┬────────────────────┘
               │  REST API           │  REST API
               ▼                     ▼
┌──────────────────────┐  ┌───────────────────────────────┐
│  Spring Boot (Java)  │  │   FastAPI (Python)            │
│  · 用户认证 (JWT)     │  │   · ETL 数据处理              │
│  · 数据上传           │──│   · AI 报告生成 (LLM)         │
│  · 好友/挑战/排行榜   │  │   · 徽章计算                  │
│  · Kafka Producer    │  │   · 定时任务                   │
│  · 报告转发           │  │   · Kafka Consumer            │
└──────┬───────────────┘  └──────┬────────────────────────┘
       │                         │
       ▼                         ▼
┌─────────────┐  ┌──────────┐  ┌─────────────────┐
│    MySQL    │  │  Redis   │  │     Kafka       │
│  (持久存储)  │  │ (缓存层)  │  │  (消息队列)      │
└─────────────┘  └──────────┘  └─────────────────┘
```

### 技术栈一览

| 层级 | 技术 | 说明 |
|------|------|------|
| **移动端** | Flutter 3.x / Dart | 跨平台客户端，深色主题 UI |
| **API 网关** | Spring Boot 4.0 / Java 17 | 用户认证、业务 API、Kafka 生产者 |
| **AI 服务** | FastAPI / Python 3.10+ | ETL、LLM 报告生成、定时任务 |
| **数据库** | MySQL | 用户/行为/报告/挑战等核心数据 |
| **缓存** | Redis | 实时数据缓存、排行榜缓存 |
| **消息队列** | Kafka | 行为数据异步处理管道 |
| **ORM** | MyBatis-Plus (Java) / SQLAlchemy (Python) | 数据持久层 |
| **认证** | Spring Security + JWT | 无状态令牌认证 |
| **AI** | OpenAI / Qwen (通义千问) | 报告内容生成 |

---

## 📁 项目结构

```
LifeScope/
├── app/                          # Flutter 移动端
│   ├── lib/
│   │   ├── main.dart             # 应用入口 & 路由
│   │   ├── providers/            # 状态管理 (Provider)
│   │   │   └── auth_provider.dart
│   │   ├── screens/              # 页面
│   │   │   ├── splash_screen.dart        # 启动页
│   │   │   ├── login_screen.dart         # 登录
│   │   │   ├── register_screen.dart      # 注册
│   │   │   ├── home_screen.dart          # 首页
│   │   │   ├── manualInput_screen.dart   # 手动录入
│   │   │   ├── dashboard_screen.dart     # 数据仪表盘
│   │   │   ├── report_screen.dart        # 报告详情
│   │   │   ├── report_list_screen.dart   # 报告列表
│   │   │   ├── badge_screen.dart         # 成就徽章
│   │   │   ├── challenge_list_screen.dart# 挑战系统
│   │   │   ├── friends_screen.dart       # 好友管理
│   │   │   └── leaderboard_screen.dart   # 排行榜
│   │   ├── services/             # API 服务层
│   │   └── widgets/              # 通用组件
│   └── pubspec.yaml
│
├── backend/
│   ├── java-service/             # Spring Boot API 服务
│   │   ├── pom.xml
│   │   └── src/main/java/org/wuyan/lifescope/
│   │       ├── controller/       # REST 控制器
│   │       │   ├── AuthController.java
│   │       │   ├── DataUploadController.java
│   │       │   ├── ReportController.java
│   │       │   ├── ChallengeController.java
│   │       │   ├── FriendController.java
│   │       │   ├── LeaderboardController.java
│   │       │   └── BadgeController.java
│   │       ├── entity/           # 数据实体
│   │       ├── mapper/           # MyBatis-Plus Mapper
│   │       ├── service/          # 业务逻辑层
│   │       ├── config/           # 配置 (Security, Kafka, Redis)
│   │       ├── filter/           # JWT 认证过滤器
│   │       └── dto/              # 数据传输对象
│   │
│   └── python-service/           # Python AI 服务
│       ├── requirements.txt
│       ├── .env                  # 环境变量配置
│       └── src/
│           ├── main.py           # FastAPI 入口
│           ├── config.py         # 配置管理
│           ├── database.py       # SQLAlchemy ORM 模型
│           ├── etl.py            # ETL 数据处理
│           ├── kafka_consumer.py # Kafka 消费者
│           ├── redis_service.py  # Redis 缓存服务
│           ├── llm_service.py    # LLM API 调用
│           ├── prompts.py        # Prompt 模板
│           ├── report_service.py # 报告生成服务
│           └── badge_service.py  # 徽章计算服务
│
└── 
```

---

## 🚀 快速开始

### 前置要求

- **Java 17+**
- **Python 3.10+**
- **Flutter 3.2+** (Dart SDK ≥ 3.2.0)
- **Docker & Docker Compose** (MySQL / Redis / Kafka)
- **Maven 3.8+**

### 1. 启动基础设施

```bash
# 启动 MySQL + Redis + Kafka (Docker Compose)
docker compose up -d
```

### 2. 在项目根目录下创建 .env 文件
```bash
cd ..
cp .env.example .env
```
配置环境变量

### 3. 创建 Kafka Topic
在可视化界面创建 topic，名称为：`lifescope.raw.data`

### 4. 启动 Java API 服务

```bash
cd backend/java-service
mvn spring-boot:run
# 服务启动于 http://localhost:8080
```

### 4. 启动 Python AI 服务

```bash
cd backend/python-service
cp .env.example .env        # 配置数据库/Redis/Kafka/LLM API Key
pip install -r requirements.txt
uvicorn src.main:app --host 0.0.0.0 --port 8001 --reload
# 服务启动于 http://localhost:8001
```

### 5. 启动 Flutter 客户端

```bash
cd app
flutter pub get
flutter run
```

---

## 📡 API 概览

### Java API（端口 8080）

| 方法 | 路径 | 说明 |
|------|------|------|
| `POST` | `/api/auth/register` | 用户注册 |
| `POST` | `/api/auth/login` | 用户登录 |
| `GET` | `/api/auth/me` | 当前用户信息 |
| `POST` | `/api/data/upload` | 上传行为数据（单条） |
| `POST` | `/api/data/batch` | 批量上传数据 |
| `GET` | `/api/reports/list` | 报告列表（分页） |
| `POST` | `/api/reports/generate` | 触发生成报告 |
| `GET` | `/api/friends/list` | 好友列表 |
| `POST` | `/api/friends/add/{id}` | 添加好友 |
| `GET` | `/api/leaderboard/daily` | 今日排行榜 |
| `GET` | `/api/leaderboard/weekly` | 本周排行榜 |
| `POST` | `/api/challenges/create` | 创建挑战 |
| `GET` | `/api/challenges/active` | 进行中的挑战 |

### Python AI API（端口 8001）

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/health` | 健康检查 |
| `POST` | `/api/etl/compute/{uid}/{date}` | 手动触发 ETL |
| `POST` | `/api/reports/generate` | 生成 AI 报告 |
| `GET` | `/api/reports/daily/{uid}/{date}` | 查询日报 |
| `GET` | `/api/reports/list/{uid}` | 报告列表 |
| `GET` | `/api/stats/weekly/{uid}` | 周统计数据 |
| `GET` | `/api/stats/monthly/{uid}` | 月趋势数据 |
| `GET` | `/api/badges/{uid}` | 用户徽章 |

---

## 🔧 环境变量配置

Python 服务 `.env` 主要配置项：

```env
# 数据库
DB_HOST=localhost
DB_PORT=3306
DB_NAME=lifescope_db
DB_USER=app_user
DB_PASS=app_pass123

# Redis
REDIS_URL=redis://localhost:6379

# Kafka
KAFKA_BOOTSTRAP=localhost:9092

# LLM API
LLM_API_KEY=your-api-key
LLM_MODEL=qwen-plus
```

---

## 📊 数据流

```
用户操作 (手动录入 / 自动采集)
    │
    ▼
Flutter → POST /api/data/upload → Spring Boot
    │
    ▼
Kafka Producer → [lifescope.raw.data] Topic
    │
    ▼
Python Kafka Consumer 消费
    │
    ▼
ETL 处理 (校验 · 去重 · 清理) → MySQL raw_behavior_data
    │
    ▼
定时任务 (每日凌晨 1 点) → 计算 daily_metrics
    │
    ▼
LLM 报告生成 → ai_reports 表 + Redis 缓存
    │
    ▼
Flutter 展示报告 (文字 + 图表 + 分享)
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 License

本项目采用 [MIT License](LICENSE) 协议授权。

---
