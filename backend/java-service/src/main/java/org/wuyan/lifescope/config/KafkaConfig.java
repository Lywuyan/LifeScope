package org.wuyan.lifescope.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;

@Configuration
public class KafkaConfig {

    private final ProducerFactory<String, String> producerFactory;

    public KafkaConfig(ProducerFactory<String, String> producerFactory) {
        this.producerFactory = producerFactory;
    }

    @Bean
    public KafkaTemplate<String, String> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory);
    }
}
