package org.wuyan.lifescope.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.wuyan.lifescope.dto.Response.LeaderboardInfoResponse;
import org.wuyan.lifescope.entity.DailyMetrics;

import java.time.LocalDate;
import java.util.List;

public interface DailyMetricsMapper extends BaseMapper<DailyMetrics> {

    /**
     * 查询指定用户列表在某天的活跃排行
     */
    @Select("<script>"
            + "SELECT dm.user_id, u.username, COALESCE(dm.total_active_mins, 0) AS total_mins "
            + "FROM daily_metrics dm "
            + "JOIN users u ON dm.user_id = u.id "
            + "WHERE dm.metric_date = #{date} "
            + "AND dm.user_id IN "
            + "<foreach collection='userIds' item='uid' open='(' separator=',' close=')'>"
            + "#{uid}"
            + "</foreach> "
            + "ORDER BY total_mins DESC"
            + "</script>")
    List<LeaderboardInfoResponse> selectDailyRanking(
            @Param("userIds") List<Long> userIds,
            @Param("date") LocalDate date);

    /**
     * 查询指定用户列表在日期范围内的累计活跃排行
     */
    @Select("<script>"
            + "SELECT dm.user_id, u.username, COALESCE(SUM(dm.total_active_mins), 0) AS total_mins "
            + "FROM daily_metrics dm "
            + "JOIN users u ON dm.user_id = u.id "
            + "WHERE dm.metric_date BETWEEN #{startDate} AND #{endDate} "
            + "AND dm.user_id IN "
            + "<foreach collection='userIds' item='uid' open='(' separator=',' close=')'>"
            + "#{uid}"
            + "</foreach> "
            + "GROUP BY dm.user_id, u.username "
            + "ORDER BY total_mins DESC"
            + "</script>")
    List<LeaderboardInfoResponse> selectWeeklyRanking(
            @Param("userIds") List<Long> userIds,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}
