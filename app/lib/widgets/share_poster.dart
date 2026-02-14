import 'package:flutter/material.dart';

class SharePoster extends StatelessWidget {
  final String reportContent;
  final String date;
  final String style;
  final Map<String, dynamic>? todayStats;

  const SharePoster({
    super.key,
    required this.reportContent,
    required this.date,
    required this.style,
    this.todayStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo + 标题
          Row(
            children: [
              const Text('🔭', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              const Text('LifeScope',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF334155)),
          const SizedBox(height: 16),

          // 报告内容
          Text(
            reportContent,
            style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFFE2E8F0)),
          ),
          const SizedBox(height: 20),

          // 数据摘要
          if (todayStats != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat('总时长', '${todayStats!['total_mins']}m'),
                _miniStat('社交', '${todayStats!['social_mins']}m'),
                _miniStat('游戏', '${todayStats!['game_mins']}m'),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // 底部
          const Divider(color: Color(0xFF334155)),
          const SizedBox(height: 8),
          const Text(
            '扫码下载 LifeScope，发现你的数字生活',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
      ],
    );
  }
}