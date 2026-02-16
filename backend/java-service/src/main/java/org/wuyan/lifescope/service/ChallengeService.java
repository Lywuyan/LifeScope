package org.wuyan.lifescope.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.wuyan.lifescope.dto.Request.CreateChallengeRequest;
import org.wuyan.lifescope.dto.Response.ChallengeInfoResponse;
import org.wuyan.lifescope.entity.Challenge;

import java.util.List;

public interface ChallengeService extends IService<Challenge> {

    ChallengeInfoResponse createChallenge(Long userId, CreateChallengeRequest request);

    void joinChallenge(Long challengeId, Long userId);

    List<ChallengeInfoResponse> getActiveChallenges(Long userId);

    List<ChallengeInfoResponse> getHistoryChallenges(Long userId);

    ChallengeInfoResponse getChallengeDetail(Long challengeId, Long userId);

    List<ChallengeInfoResponse> getDiscoverChallenges(Long userId);
}
