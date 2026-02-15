package org.wuyan.lifescope.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;

@Data
@TableName("daily_metrics")
public class DailyMetrics {

    private Long id;
    private Long userId;
    private LocalDate metricDate;
    private Integer totalActiveMins;
    private Integer socialMins;
    private Integer gameMins;
    private Integer workMins;
    private String topApp;
    private String peakHour;
}
