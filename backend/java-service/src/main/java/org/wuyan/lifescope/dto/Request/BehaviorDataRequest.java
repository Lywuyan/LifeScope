package org.wuyan.lifescope.dto.Request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class BehaviorDataRequest {

    @NotNull(message = "日期不能为空")
    private LocalDate recordDate;

    @NotBlank(message = "应用名称不能为空")
    private String appName;

    @Min(value = 1, message = "使用时长至少1分钟")
    private int usageMins;

    private String category;
}
