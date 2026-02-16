package org.wuyan.lifescope.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Builder;
import lombok.Data;
import org.wuyan.lifescope.commons.enums.ChallengeStatus;

import java.time.LocalDateTime;

@Data
@Builder
@TableName("challenges")
public class Challenge {

    private Long id;

    private Long creatorId;

    private String challengeType;

    private String title;

    private String description;

    private String targetCategory;

    private String targetOperator;

    private Integer targetValue;

    private Integer durationDays;

    private String startDate;

    private String endDate;

    private ChallengeStatus status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

}
