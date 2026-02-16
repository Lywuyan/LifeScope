package org.wuyan.lifescope.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.wuyan.lifescope.commons.result.ResponseResult;
import org.wuyan.lifescope.dto.Request.CreateChallengeRequest;
import org.wuyan.lifescope.dto.Response.ChallengeInfoResponse;
import org.wuyan.lifescope.service.ChallengeService;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/challenges")
public class ChallengeController {

    private final ChallengeService challengeService;

    /**
     * 创建挑战
     */
    @PostMapping("/create")
    public ResponseEntity<ResponseResult<ChallengeInfoResponse>> create(
            @RequestBody CreateChallengeRequest request, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        ChallengeInfoResponse result = challengeService.createChallenge(userId, request);
        return ResponseEntity.ok(ResponseResult.success("创建成功", result));
    }

    /**
     * 加入挑战
     */
    @PostMapping("/{id}/join")
    public ResponseEntity<ResponseResult<Void>> join(
            @PathVariable Long id, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        challengeService.joinChallenge(id, userId);
        return ResponseEntity.ok(ResponseResult.success("加入成功"));
    }

    /**
     * 我的进行中挑战
     */
    @GetMapping("/active")
    public ResponseEntity<ResponseResult<List<ChallengeInfoResponse>>> active(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        List<ChallengeInfoResponse> list = challengeService.getActiveChallenges(userId);
        return ResponseEntity.ok(ResponseResult.success("获取成功", list));
    }

    /**
     * 历史挑战
     */
    @GetMapping("/history")
    public ResponseEntity<ResponseResult<List<ChallengeInfoResponse>>> history(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        List<ChallengeInfoResponse> list = challengeService.getHistoryChallenges(userId);
        return ResponseEntity.ok(ResponseResult.success("获取成功", list));
    }

    /**
     * 发现可加入的挑战（好友创建的活跃挑战）
     */
    @GetMapping("/discover")
    public ResponseEntity<ResponseResult<List<ChallengeInfoResponse>>> discover(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        List<ChallengeInfoResponse> list = challengeService.getDiscoverChallenges(userId);
        return ResponseEntity.ok(ResponseResult.success("获取成功", list));
    }

    /**
     * 挑战详情
     */
    @GetMapping("/{id}")
    public ResponseEntity<ResponseResult<ChallengeInfoResponse>> detail(
            @PathVariable Long id, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        ChallengeInfoResponse detail = challengeService.getChallengeDetail(id, userId);
        return ResponseEntity.ok(ResponseResult.success("获取成功", detail));
    }
}
