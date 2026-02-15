package org.wuyan.lifescope.service;

import org.wuyan.lifescope.dto.Response.LeaderboardInfoResponse;

import java.util.List;

public interface LeaderboardService {

    List<LeaderboardInfoResponse> getDailyRanking(Long userId);

    List<LeaderboardInfoResponse> getWeeklyRanking(Long userId);
}
