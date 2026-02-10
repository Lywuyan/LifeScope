package org.wuyan.lifescope.service;

import org.wuyan.lifescope.dto.Request.BehaviorDataRequest;

public interface KafkaProducerService {
    void send(Long userId, BehaviorDataRequest request);
}
