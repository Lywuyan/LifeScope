package org.wuyan.lifescope.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.wuyan.lifescope.commons.enums.ChallengeStatus;
import org.wuyan.lifescope.commons.enums.FriendStatus;
import org.wuyan.lifescope.commons.enums.ParticipantResult;
import org.wuyan.lifescope.commons.exception.ServiceException;
import org.wuyan.lifescope.dto.Request.CreateChallengeRequest;
import org.wuyan.lifescope.dto.Response.ChallengeInfoResponse;
import org.wuyan.lifescope.entity.Challenge;
import org.wuyan.lifescope.entity.ChallengeParticipant;
import org.wuyan.lifescope.entity.Friendship;
import org.wuyan.lifescope.entity.User;
import org.wuyan.lifescope.mapper.ChallengeMapper;
import org.wuyan.lifescope.mapper.ChallengeParticipantMapper;
import org.wuyan.lifescope.mapper.FriendMapper;
import org.wuyan.lifescope.mapper.UserMapper;
import org.wuyan.lifescope.service.ChallengeService;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ChallengeServiceImpl extends ServiceImpl<ChallengeMapper, Challenge> implements ChallengeService {

    private final ChallengeParticipantMapper participantMapper;
    private final UserMapper userMapper;
    private final FriendMapper friendMapper;

    @Override
    @Transactional
    public ChallengeInfoResponse createChallenge(Long userId, CreateChallengeRequest request) {
        LocalDate startDate = LocalDate.now();
        LocalDate endDate = startDate.plusDays(request.getDurationDays());

        Challenge challenge = Challenge.builder()
                .creatorId(userId)
                .challengeType(request.getChallengeType())
                .title(request.getTitle())
                .description(request.getDescription())
                .targetCategory(request.getTargetCategory())
                .targetOperator(request.getTargetOperator())
                .targetValue(request.getTargetValue())
                .durationDays(request.getDurationDays())
                .startDate(startDate.toString())
                .endDate(endDate.toString())
                .status(ChallengeStatus.ACTIVE)
                .build();

        this.save(challenge);

        // 创建者自动加入
        ChallengeParticipant participant = ChallengeParticipant.builder()
                .challengeId(challenge.getId())
                .userId(userId)
                .result(ParticipantResult.PENDING)
                .progressPct(0)
                .build();
        participantMapper.insert(participant);

        log.info("[Challenge] 用户 {} 创建挑战: {}", userId, challenge.getTitle());
        return toResponse(challenge, userId);
    }

    @Override
    @Transactional
    public void joinChallenge(Long challengeId, Long userId) {
        Challenge challenge = this.getById(challengeId);
        if (challenge == null) {
            throw new ServiceException("挑战不存在");
        }
        if (challenge.getStatus() != ChallengeStatus.ACTIVE) {
            throw new ServiceException("挑战已结束，无法加入");
        }

        Long count = participantMapper.selectCount(
                new LambdaQueryWrapper<ChallengeParticipant>()
                        .eq(ChallengeParticipant::getChallengeId, challengeId)
                        .eq(ChallengeParticipant::getUserId, userId)
        );
        if (count > 0) {
            throw new ServiceException("你已加入该挑战");
        }

        ChallengeParticipant participant = ChallengeParticipant.builder()
                .challengeId(challengeId)
                .userId(userId)
                .result(ParticipantResult.PENDING)
                .progressPct(0)
                .build();
        participantMapper.insert(participant);

        log.info("[Challenge] 用户 {} 加入挑战 {}", userId, challengeId);
    }

    @Override
    public List<ChallengeInfoResponse> getActiveChallenges(Long userId) {
        List<Long> challengeIds = getParticipatingChallengeIds(userId);
        if (challengeIds.isEmpty()) return List.of();

        return this.list(
                new LambdaQueryWrapper<Challenge>()
                        .in(Challenge::getId, challengeIds)
                        .eq(Challenge::getStatus, ChallengeStatus.ACTIVE)
                        .orderByDesc(Challenge::getCreatedAt)
        ).stream().map(c -> toResponse(c, userId)).collect(Collectors.toList());
    }

    @Override
    public List<ChallengeInfoResponse> getHistoryChallenges(Long userId) {
        List<Long> challengeIds = getParticipatingChallengeIds(userId);
        if (challengeIds.isEmpty()) return List.of();

        return this.list(
                new LambdaQueryWrapper<Challenge>()
                        .in(Challenge::getId, challengeIds)
                        .ne(Challenge::getStatus, ChallengeStatus.ACTIVE)
                        .orderByDesc(Challenge::getCreatedAt)
        ).stream().map(c -> toResponse(c, userId)).collect(Collectors.toList());
    }

    @Override
    public ChallengeInfoResponse getChallengeDetail(Long challengeId, Long userId) {
        Challenge challenge = this.getById(challengeId);
        if (challenge == null) {
            throw new ServiceException("挑战不存在");
        }
        return toResponse(challenge, userId);
    }

    @Override
    public List<ChallengeInfoResponse> getDiscoverChallenges(Long userId) {
        // 获取好友 ID
        List<Long> friendIds = friendMapper.selectObjs(
                new LambdaQueryWrapper<Friendship>()
                        .eq(Friendship::getUserId, userId)
                        .eq(Friendship::getStatus, FriendStatus.ACCEPTED)
                        .select(Friendship::getFriendId)
        ).stream().map(obj -> ((Number) obj).longValue())
                .collect(Collectors.toList());

        if (friendIds.isEmpty()) return List.of();

        // 好友创建的活跃挑战
        List<Challenge> friendChallenges = this.list(
                new LambdaQueryWrapper<Challenge>()
                        .in(Challenge::getCreatorId, friendIds)
                        .eq(Challenge::getStatus, ChallengeStatus.ACTIVE)
                        .orderByDesc(Challenge::getCreatedAt)
        );

        // 排除已参与的
        List<Long> myJoinedIds = getParticipatingChallengeIds(userId);
        return friendChallenges.stream()
                .filter(c -> !myJoinedIds.contains(c.getId()))
                .map(c -> toResponse(c, userId))
                .collect(Collectors.toList());
    }

    // ==================== 私有方法 ====================

    private List<Long> getParticipatingChallengeIds(Long userId) {
        return participantMapper.selectObjs(
                new LambdaQueryWrapper<ChallengeParticipant>()
                        .eq(ChallengeParticipant::getUserId, userId)
                        .select(ChallengeParticipant::getChallengeId)
        ).stream().map(obj -> (Long) obj).collect(Collectors.toList());
    }

    private ChallengeInfoResponse toResponse(Challenge c, Long userId) {
        User creator = userMapper.selectById(c.getCreatorId());
        String creatorName = creator != null ? creator.getUsername() : "未知";

        Long participantCount = participantMapper.selectCount(
                new LambdaQueryWrapper<ChallengeParticipant>()
                        .eq(ChallengeParticipant::getChallengeId, c.getId())
        );

        ChallengeParticipant myParticipation = participantMapper.selectOne(
                new LambdaQueryWrapper<ChallengeParticipant>()
                        .eq(ChallengeParticipant::getChallengeId, c.getId())
                        .eq(ChallengeParticipant::getUserId, userId)
        );
        Integer myProgress = myParticipation != null ? myParticipation.getProgressPct() : null;

        int daysLeft = 0;
        if (c.getEndDate() != null && c.getStatus() == ChallengeStatus.ACTIVE) {
            LocalDate endDate = LocalDate.parse(c.getEndDate());
            daysLeft = Math.max(0, (int) ChronoUnit.DAYS.between(LocalDate.now(), endDate));
        }

        return ChallengeInfoResponse.builder()
                .id(c.getId())
                .creatorName(creatorName)
                .challengeType(c.getChallengeType())
                .title(c.getTitle())
                .description(c.getDescription())
                .targetCategory(c.getTargetCategory())
                .targetOperator(c.getTargetOperator())
                .targetValue(c.getTargetValue())
                .durationDays(c.getDurationDays())
                .startDate(c.getStartDate())
                .endDate(c.getEndDate())
                .status(c.getStatus().name())
                .participantCount(participantCount.intValue())
                .myProgressPct(myProgress)
                .daysLeft(daysLeft)
                .build();
    }
}
