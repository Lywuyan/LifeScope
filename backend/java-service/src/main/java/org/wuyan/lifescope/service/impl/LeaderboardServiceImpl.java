package org.wuyan.lifescope.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.wuyan.lifescope.commons.enums.FriendStatus;
import org.wuyan.lifescope.dto.Response.LeaderboardInfoResponse;
import org.wuyan.lifescope.entity.Friendship;
import org.wuyan.lifescope.mapper.DailyMetricsMapper;
import org.wuyan.lifescope.mapper.FriendMapper;
import org.wuyan.lifescope.service.LeaderboardService;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.Duration;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class LeaderboardServiceImpl implements LeaderboardService {

    private final FriendMapper friendMapper;

    private final DailyMetricsMapper dailyMetricsMapper;

    private final StringRedisTemplate redisTemplate;

    private final ObjectMapper objectMapper;

    @Override
    public List<LeaderboardInfoResponse> getDailyRanking(Long userId) {
        LocalDate today = LocalDate.now();
        String key = "leaderboard:daily:" + today;

        // 1. 尝试从 Redis 读取缓存
        String cached = redisTemplate.opsForValue().get(key);
        if (cached != null) {
            try {
                return objectMapper.readValue(cached,
                        new TypeReference<>() {
                        });
            } catch (Exception e) {
                log.warn("排行榜缓存反序列化失败，走 DB 查询", e);
            }
        }

        // 2. 获取好友 ID 列表 + 自己
        List<Long> userIds = getFriendIds(userId);
        userIds.add(userId);

        // 3. MyBatis-Plus 自定义 SQL 查询排行
        List<LeaderboardInfoResponse> result = dailyMetricsMapper.selectDailyRanking(userIds, today);

        // 4. 填充排名和 isMe 标记
        fillRankAndMe(result, userId);

        // 5. 写入 Redis 缓存（10 分钟过期）
        writeCache(key, result);

        return result;
    }

    @Override
    public List<LeaderboardInfoResponse> getWeeklyRanking(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(DayOfWeek.MONDAY);
        String key = "leaderboard:weekly:" + weekStart;

        // 1. 尝试从 Redis 读取缓存
        String cached = redisTemplate.opsForValue().get(key);
        if (cached != null) {
            try {
                return objectMapper.readValue(cached,
                        new TypeReference<>() {
                        });
            } catch (Exception e) {
                log.warn("周排行榜缓存反序列化失败，走 DB 查询", e);
            }
        }

        // 2. 获取好友 ID 列表 + 自己
        List<Long> userIds = getFriendIds(userId);
        userIds.add(userId);

        // 3. 查询本周累计排行
        List<LeaderboardInfoResponse> result =
                dailyMetricsMapper.selectWeeklyRanking(userIds, weekStart, today);

        // 4. 填充排名和 isMe
        fillRankAndMe(result, userId);

        // 5. 缓存
        writeCache(key, result);

        return result;
    }

    /**
     * 获取当前用户的已接受好友 ID 列表
     */
    private List<Long> getFriendIds(Long userId) {
        List<Object> friendIds = friendMapper.selectObjs(
                new LambdaQueryWrapper<Friendship>()
                        .eq(Friendship::getUserId, userId)
                        .eq(Friendship::getStatus, FriendStatus.ACCEPTED)
                        .select(Friendship::getFriendId)
        );
         return friendIds.stream()
                .map(obj -> ((Number) obj).longValue())
                .collect(Collectors.toList());
    }

    /**
     * 填充排名序号和 isMe 标记
     */
    private void fillRankAndMe(List<LeaderboardInfoResponse> list, Long userId) {
        for (int i = 0; i < list.size(); i++) {
            list.get(i).setRank(i + 1);
            list.get(i).setMe(userId.equals(list.get(i).getUserId()));
        }
    }

    /**
     * 写入 Redis 缓存，10 分钟过期
     */
    private void writeCache(String key, List<LeaderboardInfoResponse> data) {
        try {
            String json = objectMapper.writeValueAsString(data);
            redisTemplate.opsForValue().set(key, json, Duration.ofMinutes(10));
        } catch (Exception e) {
            log.warn("排行榜缓存写入失败", e);
        }
    }
}
