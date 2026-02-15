package org.wuyan.lifescope.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.wuyan.lifescope.commons.result.ResponseResult;
import org.wuyan.lifescope.dto.Response.FriendInfoResponse;
import org.wuyan.lifescope.service.FriendService;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/friends")
public class FriendController {

    private final FriendService friendService;

    /**
     * 发送好友请求
     */
    @PostMapping("/add/{friendId}")
    public ResponseEntity<ResponseResult<Void>> addFriend(@PathVariable Long friendId, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        friendService.sendRequest(userId, friendId);
        return ResponseEntity.ok(ResponseResult.success("发送成功"));
    }

    /**
     * 接受好友请求
     */
    @PostMapping("/accept/{requestId}")
    public ResponseEntity<ResponseResult<Void>> acceptRequest(@PathVariable Long requestId, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        friendService.acceptRequest(requestId, userId);
        return ResponseEntity.ok(ResponseResult.success("接受成功"));
    }

    /**
     * 拒绝好友请求
     */
    @PostMapping("/reject/{requestId}")
    public ResponseEntity<ResponseResult<Void>> rejectRequest(@PathVariable Long requestId, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        friendService.rejectRequest(requestId, userId);
        return ResponseEntity.ok(ResponseResult.success("拒绝成功"));
    }

    /**
     * 删除好友关系
     */
    @PostMapping("/remove/{friendId}")
    public ResponseEntity<ResponseResult<Void>> removeFriend(@PathVariable Long friendId, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        friendService.removeFriend(userId, friendId);
        return ResponseEntity.ok(ResponseResult.success("删除成功"));
    }

    /**
     * 获取好友列表
     */
    @GetMapping("/list")
    public ResponseEntity<ResponseResult<List<FriendInfoResponse>>> getFriendList(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        List<FriendInfoResponse> friendList = friendService.getFriendList(userId);
        return ResponseEntity.ok(ResponseResult.success("获取成功", friendList));
    }

    /**
     * 获取待处理好友请求列表
     */
    @GetMapping("/requests")
    public ResponseEntity<ResponseResult<List<FriendInfoResponse>>> getPendingRequests(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        List<FriendInfoResponse> requests = friendService.getPendingRequests(userId);
        return ResponseEntity.ok(ResponseResult.success("获取成功", requests));
    }

    /**
     * 搜索用户
     */
    @GetMapping("/search")
    public ResponseEntity<ResponseResult<List<FriendInfoResponse>>> searchUsers(@RequestParam String keyword, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        List<FriendInfoResponse> users = friendService.searchUsers(keyword,userId);
        return ResponseEntity.ok(ResponseResult.success("获取成功", users));
    }
}

