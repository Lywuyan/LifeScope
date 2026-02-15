package org.wuyan.lifescope.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.wuyan.lifescope.dto.Response.FriendInfoResponse;
import org.wuyan.lifescope.entity.Friendship;

import java.util.List;

public interface FriendService extends IService<Friendship> {

    /**
     * 发送好友请求
     */
    void sendRequest(Long userId, Long friendId);

    /**
     * 接受好友请求
     */
    void acceptRequest(Long requestId, Long userId);

    /**
     * 拒绝好友请求
     */
    void rejectRequest(Long requestId, Long userId);

    /**
     * 删除好友关系
     */
    void removeFriend(Long userId, Long friendId);

    /**
     * 获取好友列表
     */
    List<FriendInfoResponse> getFriendList(Long userId);

    /**
     * 获取待处理的好友请求列表
     */
    List<FriendInfoResponse> getPendingRequests(Long userId);

    /**
     * 查找用户
     */
    List<FriendInfoResponse> searchUsers(String keyword,Long userId);
}
