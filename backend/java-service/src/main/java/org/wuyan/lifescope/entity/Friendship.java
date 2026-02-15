package org.wuyan.lifescope.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Builder;
import lombok.Data;
import org.wuyan.lifescope.commons.enums.FriendStatus;

import java.time.LocalDateTime;

@Data
@Builder
@TableName("friendships")
public class Friendship {
    /**
     * 朋友关系ID
     */
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 朋友ID
     */
    private Long friendId;

    /**
     * 朋友关系状态
     */
    private FriendStatus status;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
