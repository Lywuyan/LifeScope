// ============================================================
// FILE: lib/screens/home_screen.dart
// 首页 — 登录后的主界面骨架
// Phase 5 会在这里填充报告/挑战/成就模块
// ============================================================
import 'package:app/screens/manualInput_screen.dart';
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
                    color: const Color(0xFF22C55E33),
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
            _placeholderCard(
              title: '📊 今日报告',
              subtitle: 'AI 分析正在生成中...',
              icon: Icons.analytics_outlined,
              color: const Color(0xFFA78BFA),
            ),
            const SizedBox(height: 16),

            // ── 活跃挑战（占位）───────────────────
            _placeholderCard(
              title: '🏆 活跃挑战',
              subtitle: '还没有接受挑战，试试看？',
              icon: Icons.emoji_events_outlined,
              color: const Color(0xFFFBBF24),
            ),
            const SizedBox(height: 16),

            // ── 成就徽章（占位）───────────────────
            _placeholderCard(
              title: '🎖️ 成就徽章',
              subtitle: '你的第一个徽章还在等待...',
              icon: Icons.military_tech_outlined,
              color: const Color(0xFF60A5FA),
            ),
            const SizedBox(height: 16),

            // ── 快速数据上传入口（占位）───────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManualInputScreen()),
              ),
              child: _placeholderCard(
                title: '📱 手动上传数据',
                subtitle: '记录今天的游戏/健身/学习',
                icon: Icons.upload_outlined,
                color: const Color(0xFF34D399),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        Icon(Icons.chevron_right, color: const Color(0xFF64748B), size: 20),
      ],
    ),
  );
}
