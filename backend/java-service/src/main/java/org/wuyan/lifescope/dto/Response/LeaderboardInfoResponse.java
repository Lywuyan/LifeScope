package org.wuyan.lifescope.dto.Response;

import lombok.Data;

@Data
public class LeaderboardInfoResponse {

    private Integer rank;
    private Long userId;
    private String username;
    private Integer totalMins;
    private boolean isMe;
}
