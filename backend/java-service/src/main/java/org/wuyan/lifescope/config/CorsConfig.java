package org.wuyan.lifescope.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowCredentials(true)
                .allowedOrigins("http://localhost:7872") // 移除 /**
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // 推荐加上OPTIONS，因为CORS预检请求使用OPTIONS
                .allowedHeaders("*")
                .exposedHeaders("*")
                .maxAge(3600); // 建议加上，用于预检请求的缓存
    }
}


