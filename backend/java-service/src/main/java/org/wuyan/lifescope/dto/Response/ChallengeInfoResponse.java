package org.wuyan.lifescope.dto.Response;

import lombok.Builder;
import lombok.Data;
import tools.jackson.databind.annotation.JsonSerialize;
import tools.jackson.databind.ser.std.ToStringSerializer;

@Data
@Builder
public class ChallengeInfoResponse {

    /** 挑战 ID */
    private Long id;

    /** 创建者用户名 */
    private String creatorName;

    /** 挑战类型: reduce / focus / versus / discipline */
    private String challengeType;

    /** 标题 */
    private String title;

    /** 描述 */
    private String description;

    /** 目标类别: social / game / work / total */
    private String targetCategory;

    /** 目标运算符: < / > / = */
    private String targetOperator;

    /** 目标值（分钟） */
    private Integer targetValue;

    /** 持续天数 */
    private Integer durationDays;

    /** 开始/结束日期 */
    private String startDate;
    private String endDate;

    /** 状态: ACTIVE / COMPLETED / FAILED / CANCELLED */
    private String status;

    /** 当前参与人数 */
    private Integer participantCount;

    /** 当前用户的进度百分比（如果已参与） */
    private Integer myProgressPct;

    /** 剩余天数 */
    private Integer daysLeft;

    @JsonSerialize(using = ToStringSerializer.class)
    public Long getId() {
        return id;
    }

}
