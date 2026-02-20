// ============================================================
// FILE: lib/screens/home_screen.dart
// 首页 — 登录后的主界面骨架
// ============================================================
import 'package:app/screens/manualInput_screen.dart';
import 'package:app/screens/report_screen.dart';
import 'package:app/screens/dashboard_screen.dart';
import 'package:app/screens/report_list_screen.dart';
import 'package:app/screens/badge_screen.dart';
import 'package:app/screens/leaderboard_screen.dart';
import 'package:app/screens/friends_screen.dart';
import 'package:app/screens/challenge_list_screen.dart';
import 'package:app/services/usage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    _initUsageSync();
  }

  Future<void> _initUsageSync() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null) return;

    // 检查权限
    final hasPermission = await UsageService.hasPermission();
    if (!hasPermission && mounted) {
      _showPermissionDialog();
      return;
    }

    // 自动同步当天数据
    await UsageService.syncToday(token);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('📱 开启使用情况访问',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'LifeScope 需要访问你的屏幕使用时间来自动记录行为数据、生成报告和参与挑战。\n\n请在设置中找到 LifeScope 并开启权限。',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('稍后', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await UsageService.requestPermission();
            },
            child: const Text('去设置', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        title: const Text('LifeScope', style: TextStyle(
          fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF64748B)),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── 问候语 ─────────────────────────────
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xff22c55e33),
                  ),
                  child: const Center(
                      child: Icon(Icons.person, color: Color(0xFF22C55E))),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('你好，${user?.username ?? "用户"}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const Text('今天过得怎么样？',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── 今日报告卡片 ────────────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ReportScreen(date: DateTime.now())),
              ),
              child: _placeholderCard(
                title: '📊 今日报告',
                subtitle: 'AI 分析正在生成中...',
                icon: Icons.analytics_outlined,
                color: const Color(0xFFA78BFA),
              ),
            ),
            const SizedBox(height: 24),

            // ── 功能模块网格 ────────────────────
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _featureCard(
                  icon: Icons.analytics_outlined,
                  title: '📊 数据仪表盘',
                  subtitle: '可视化你的行为',
                  color: const Color(0xFF3B82F6),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen())),
                ),
                _featureCard(
                  icon: Icons.article_outlined,
                  title: '📋 历史报告',
                  subtitle: '查看所有报告',
                  color: const Color(0xFFA78BFA),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReportListScreen())),
                ),
                _featureCard(
                  icon: Icons.emoji_events_outlined,
                  title: '🏆 成就徽章',
                  subtitle: '查看已获得徽章',
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BadgeScreen())),
                ),
                _featureCard(
                  icon: Icons.upload_outlined,
                  title: '📱 手动录入',
                  subtitle: '记录行为数据',
                  color: const Color(0xFF34D399),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ManualInputScreen())),
                ),
                _featureCard(
                  icon: Icons.leaderboard_outlined,
                  title: '🏅 排行榜',
                  subtitle: '好友活跃度排名',
                  color: const Color(0xFFF59E0B),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                ),
                _featureCard(
                  icon: Icons.people_outline,
                  title: '👥 好友',
                  subtitle: '管理好友关系',
                  color: const Color(0xFF06B6D4),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FriendsScreen())),
                ),
                _featureCard(
                  icon: Icons.flash_on_outlined,
                  title: '⚡ 挑战',
                  subtitle: '向好友发起挑战',
                  color: const Color(0xFFEF4444),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChallengeListScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 功能卡片组件（支持角标）
Widget _featureCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
  int badge = 0,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2D3A)),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color.withOpacity(0.15),
                ),
                child: Center(child: Icon(icon, color: color, size: 20)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: badge > 0
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          // 角标
          if (badge > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$badge',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ),
        ],
      ),
    ),
  );
}

/// 占位卡片组件
Widget _placeholderCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1D27),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF2A2D3A)),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.15),
          ),
          child: Center(child: Icon(icon, color: color, size: 22)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 20),
      ],
    ),
  );
}
