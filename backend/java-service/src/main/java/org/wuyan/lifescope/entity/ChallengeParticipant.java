package org.wuyan.lifescope.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Builder;
import lombok.Data;
import org.wuyan.lifescope.commons.enums.ParticipantResult;

import java.time.LocalDateTime;

@Data
@Builder
@TableName("challenge_participants")
public class ChallengeParticipant {

    private Long id;

    private Long challengeId;

    private Long userId;

    private ParticipantResult result;

    private Integer progressPct;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime joinedAt;
}
