package org.wuyan.lifescope.dto.Response;

import lombok.Builder;
import lombok.Data;
import tools.jackson.databind.annotation.JsonSerialize;
import tools.jackson.databind.ser.std.ToStringSerializer;

@Data
@Builder
public class FriendInfoResponse {

    private Long id;

    private String username;

    private String avatarUrl;

    private String createdAt;

    @JsonSerialize(using = ToStringSerializer.class)
    public Long getId() {
        return id;
    }

}
