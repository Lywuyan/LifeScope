// ============================================================
// FILE: lib/screens/home_screen.dart
// 首页 — 登录后的主界面骨架
// Phase 5 会在这里填充报告/挑战/成就模块
// ============================================================
import 'package:app/screens/manualInput_screen.dart';
import 'package:app/screens/report_screen.dart';
import 'package:app/screens/dashboard_screen.dart';
import 'package:app/screens/report_list_screen.dart';
import 'package:app/screens/badge_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

            // ── 今日报告卡片（占位）────────────────
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
              childAspectRatio: 1.6,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 功能卡片组件
Widget _featureCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
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
      child: Column(
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
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    ),
  );
}

/// 占位卡片组件（已弃用）
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
