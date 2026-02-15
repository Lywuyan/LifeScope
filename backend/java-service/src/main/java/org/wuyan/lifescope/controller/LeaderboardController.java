package org.wuyan.lifescope.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.wuyan.lifescope.commons.result.ResponseResult;
import org.wuyan.lifescope.dto.Response.LeaderboardInfoResponse;
import org.wuyan.lifescope.service.LeaderboardService;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/leaderboard")
public class LeaderboardController {

    private final LeaderboardService leaderboardService;

    /**
     * 获取日排行榜
     */
    @GetMapping("/daily")
    public ResponseEntity<ResponseResult<List<LeaderboardInfoResponse>>> getDailyRanking(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(ResponseResult.success(leaderboardService.getDailyRanking(userId)));
    }

    /**
     * 获取周排行榜
     */
    @GetMapping("/weekly")
    public ResponseEntity<ResponseResult<List<LeaderboardInfoResponse>>> getWeeklyRanking(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(ResponseResult.success(leaderboardService.getWeeklyRanking(userId)));
    }
}
