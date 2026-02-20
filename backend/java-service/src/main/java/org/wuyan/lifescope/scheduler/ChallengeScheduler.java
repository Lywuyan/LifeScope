package org.wuyan.lifescope.scheduler;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.wuyan.lifescope.commons.enums.ChallengeStatus;
import org.wuyan.lifescope.commons.enums.ParticipantResult;
import org.wuyan.lifescope.entity.Challenge;
import org.wuyan.lifescope.entity.ChallengeParticipant;
import org.wuyan.lifescope.entity.DailyMetrics;
import org.wuyan.lifescope.mapper.ChallengeMapper;
import org.wuyan.lifescope.mapper.ChallengeParticipantMapper;
import org.wuyan.lifescope.mapper.DailyMetricsMapper;

import java.time.LocalDate;
import java.util.List;

/**
 * 挑战定时评判
 * 每天凌晨 1:00 执行：更新所有 ACTIVE 挑战的参与者进度，到期后结算
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChallengeScheduler {

    private final ChallengeMapper challengeMapper;
    private final ChallengeParticipantMapper participantMapper;
    private final DailyMetricsMapper dailyMetricsMapper;

    private static final int PASS_THRESHOLD = 80; // 达标率 >= 80% 算成功

    @Scheduled(cron = "0 0 1 * * *")
    @Transactional
    public void evaluateChallenges() {
        log.info("[ChallengeScheduler] 开始评判挑战...");

        List<Challenge> activeChallenges = challengeMapper.selectList(
                new LambdaQueryWrapper<Challenge>()
                        .eq(Challenge::getStatus, ChallengeStatus.ACTIVE)
        );

        LocalDate today = LocalDate.now();

        for (Challenge challenge : activeChallenges) {
            LocalDate startDate = LocalDate.parse(challenge.getStartDate());
            LocalDate endDate = LocalDate.parse(challenge.getEndDate());

            // 获取该挑战所有参与者
            List<ChallengeParticipant> participants = participantMapper.selectList(
                    new LambdaQueryWrapper<ChallengeParticipant>()
                            .eq(ChallengeParticipant::getChallengeId, challenge.getId())
            );

            for (ChallengeParticipant p : participants) {
                int progressPct = calcProgress(p.getUserId(), challenge, startDate, today.isBefore(endDate) ? today : endDate);

                // 更新进度
                participantMapper.update(null,
                        new LambdaUpdateWrapper<ChallengeParticipant>()
                                .eq(ChallengeParticipant::getId, p.getId())
                                .set(ChallengeParticipant::getProgressPct, progressPct)
                );
            }

            // 挑战到期 → 结算
            if (!today.isBefore(endDate)) {
                settleChallenge(challenge, participants);
            }
        }

        log.info("[ChallengeScheduler] 评判完成，处理了 {} 个挑战", activeChallenges.size());
    }

    /**
     * 计算参与者进度百分比
     * progressPct = (达标天数 / 已过天数) * 100
     */
    private int calcProgress(Long userId, Challenge challenge, LocalDate startDate, LocalDate endDate) {
        List<DailyMetrics> metricsList = dailyMetricsMapper.selectByUserAndDateRange(
                userId, startDate, endDate);

        // 已过天数（从 startDate 到 endDate，含两端）
        int totalDays = (int) (endDate.toEpochDay() - startDate.toEpochDay()) + 1;
        if (totalDays <= 0) return 0;

        int qualifiedDays = 0;
        for (LocalDate d = startDate; !d.isAfter(endDate); d = d.plusDays(1)) {
            final LocalDate date = d;
            DailyMetrics dm = metricsList.stream()
                    .filter(m -> m.getMetricDate().equals(date))
                    .findFirst()
                    .orElse(null);

            if (dm == null) {
                // 没有数据的天，视为不达标
                continue;
            }

            int actualValue = getMetricValue(dm, challenge.getTargetCategory());
            if (compareValue(actualValue, challenge.getTargetOperator(), challenge.getTargetValue())) {
                qualifiedDays++;
            }
        }

        return (int) ((qualifiedDays * 100.0) / totalDays);
    }

    /**
     * 根据 targetCategory 取对应字段值
     */
    private int getMetricValue(DailyMetrics dm, String category) {
        if (category == null) return dm.getTotalActiveMins() != null ? dm.getTotalActiveMins() : 0;
        return switch (category.toLowerCase()) {
            case "social" -> dm.getSocialMins() != null ? dm.getSocialMins() : 0;
            case "game"   -> dm.getGameMins() != null ? dm.getGameMins() : 0;
            case "work"   -> dm.getWorkMins() != null ? dm.getWorkMins() : 0;
            default       -> dm.getTotalActiveMins() != null ? dm.getTotalActiveMins() : 0;
        };
    }

    /**
     * 根据 operator 比较实际值与目标值
     */
    private boolean compareValue(int actual, String operator, int target) {
        return switch (operator) {
            case "<" -> actual < target;
            case ">" -> actual > target;
            case "=" -> actual == target;
            default  -> false;
        };
    }

    /**
     * 结算挑战：根据 progressPct 判定每个参与者的结果，更新挑战状态
     */
    private void settleChallenge(Challenge challenge, List<ChallengeParticipant> participants) {
        for (ChallengeParticipant p : participants) {
            // 重新读取最新 progressPct
            ChallengeParticipant latest = participantMapper.selectById(p.getId());
            ParticipantResult result = latest.getProgressPct() >= PASS_THRESHOLD
                    ? ParticipantResult.SUCCESS
                    : ParticipantResult.FAILED;

            participantMapper.update(null,
                    new LambdaUpdateWrapper<ChallengeParticipant>()
                            .eq(ChallengeParticipant::getId, p.getId())
                            .set(ChallengeParticipant::getResult, result)
            );

            log.info("[ChallengeScheduler] 挑战 {} 参与者 {} → {} (进度 {}%)",
                    challenge.getTitle(), p.getUserId(), result, latest.getProgressPct());
        }

        // 挑战状态改为 COMPLETED
        challengeMapper.update(null,
                new LambdaUpdateWrapper<Challenge>()
                        .eq(Challenge::getId, challenge.getId())
                        .set(Challenge::getStatus, ChallengeStatus.COMPLETED)
        );

        log.info("[ChallengeScheduler] 挑战 [{}] 结算完成", challenge.getTitle());
    }
}
