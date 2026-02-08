# ============================================================
# FILE: app/kafka_consumer.py
# Kafka 消费者 — 后台线程轮询 raw.data Topic
# 每条消息 → etl.process_raw_message()
# ============================================================
import json
import threading
from loguru import logger
from confluent_kafka import Consumer, KafkaError

from src.config import settings
from src import etl  # ETL 处理模块（下一个文件）


def _create_consumer() -> Consumer:
    """构建 confluent_kafka Consumer 实例"""
    return Consumer({
        "bootstrap.servers": settings.kafka_bootstrap,
        "group.id":          settings.kafka_consumer_group,
        "auto.offset.reset": "earliest",
        "enable.auto.commit": True,
    })


def _poll_loop():
    """消费循环 — 运行在独立线程里"""
    consumer = _create_consumer()
    consumer.subscribe([settings.kafka_topic_raw_data])
    logger.info(f"[Kafka Consumer] 已订阅 Topic: {settings.kafka_topic_raw_data}")

    while True:
        msg = consumer.poll(timeout=1.0)   # 每秒轮询一次

        if msg is None:
            continue                        # 超时，没消息

        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                continue                    # 到达分区末尾，正常
            logger.error(f"[Kafka Consumer] 错误: {msg.error()}")
            continue

        # ── 解析并处理 ──────────────────────────
        try:
            payload = json.loads(msg.value().decode("utf-8"))
            logger.info(f"[Kafka Consumer] 收到消息 offset={msg.offset()}: {payload}")
            etl.process_raw_message(payload)
        except Exception as e:
            logger.error(f"[Kafka Consumer] 处理失败: {e}")
            # TODO: 后续可接死信队列 DLQ


def start_consumer_thread():
    """在 FastAPI 启动时调用，开一个 daemon 线程跑消费循环"""
    t = threading.Thread(target=_poll_loop, daemon=True, name="kafka-consumer")
    t.start()
    logger.info("[Kafka Consumer] 后台消费线程已启动")
