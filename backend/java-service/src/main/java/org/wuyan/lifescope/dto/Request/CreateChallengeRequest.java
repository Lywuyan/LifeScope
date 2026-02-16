package org.wuyan.lifescope.dto.Request;

import lombok.Data;

@Data
public class CreateChallengeRequest {

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
}
