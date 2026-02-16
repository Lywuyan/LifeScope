package org.wuyan.lifescope.dto.Response;

import lombok.Data;
import tools.jackson.databind.annotation.JsonSerialize;
import tools.jackson.databind.ser.std.ToStringSerializer;

@Data
public class LeaderboardInfoResponse {

    private Integer rank;
    private Long userId;
    private String username;
    private Integer totalMins;
    private boolean isMe;

    @JsonSerialize(using = ToStringSerializer.class)
    public Long getUserId() {
        return userId;
    }

}
