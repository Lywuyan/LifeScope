package org.wuyan.lifescope;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("org.wuyan.lifescope.mapper")
public class LifeScopeApplication {

    public static void main(String[] args) {
        SpringApplication.run(LifeScopeApplication.class, args);
    }

}
