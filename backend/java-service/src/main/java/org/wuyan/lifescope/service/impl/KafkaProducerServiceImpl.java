package org.wuyan.lifescope.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.wuyan.lifescope.dto.Request.BehaviorDataRequest;
import org.wuyan.lifescope.service.KafkaProducerService;
import tools.jackson.databind.ObjectMapper;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class KafkaProducerServiceImpl implements KafkaProducerService {

    private final KafkaTemplate<String, String> kafkaTemplate;

    private final ObjectMapper objectMapper;

    private final String TOPIC = "lifescope.raw.data";

    @Override
    public void send(Long userId, BehaviorDataRequest request) {
        // 构造消息
        Map<String, Object> message = Map.of(
                "user_id", userId,
                "record_date", request.getRecordDate().toString(),
                "app_name", request.getAppName(),
                "usage_mins", request.getUsageMins(),
                "category", request.getCategory() != null ? request.getCategory() : "others"
        );

        String json = objectMapper.writeValueAsString(message);

        kafkaTemplate.send(TOPIC, json);
    }
}
