import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';

class BadgeScreen extends StatefulWidget {
  const BadgeScreen({super.key});
  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _earnedBadges = [];
  List<Map<String, dynamic>> _allBadges = [];

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      // 获取用户已获得的徽章
      final resp = await http.get(
        Uri.parse('$API_BASE/badges'),
        headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Content-Type': 'application/json',
        },
      );
      final body = jsonDecode(resp.body);

      // 获取所有徽章定义
      final allResp = await http.get(
        Uri.parse('$API_BASE/badges/all'),
        headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Content-Type': 'application/json',
        },
      );
      final allBody = jsonDecode(allResp.body);

      setState(() {
        _earnedBadges = List<Map<String, dynamic>>.from(body['data']);
        _allBadges = List<Map<String, dynamic>>.from(allBody['data']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final earnedCodes = _earnedBadges.map((b) => b['code']).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        title: const Text('🏆 成就徽章'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_earnedBadges.length} / ${_allBadges.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF22C55E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBadges,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _allBadges.length,
                itemBuilder: (context, index) {
                  final badge = _allBadges[index];
                  final isEarned = earnedCodes.contains(badge['code']);
                  return _buildBadgeCard(badge, isEarned);
                },
              ),
            ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge, bool isEarned) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(badge, isEarned),
      child: Container(
        decoration: BoxDecoration(
          color: isEarned
              ? const Color(0xFF1A1D27)
              : const Color(0xFF1A1D27).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEarned
                ? const Color(0xFF22C55E).withOpacity(0.5)
                : const Color(0xFF2A2D3A),
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge['icon'] ?? '🏅',
              style: TextStyle(
                fontSize: 36,
                color: isEarned ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge['name'] ?? '',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isEarned
                    ? Colors.white
                    : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            if (!isEarned) ...[
              const SizedBox(height: 4),
              const Icon(Icons.lock_outline, size: 14, color: Color(0xFF475569)),
            ],
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(Map<String, dynamic> badge, bool isEarned) {
    // 查找获得时间
    final earned = _earnedBadges.firstWhere(
      (b) => b['code'] == badge['code'],
      orElse: () => {},
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D27),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽条
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // 图标
            Text(badge['icon'] ?? '🏅', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            // 名称
            Text(
              badge['name'] ?? '',
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // 描述
            Text(
              badge['description'] ?? '',
              style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // 状态
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isEarned
                    ? const Color(0xFF22C55E).withOpacity(0.1)
                    : const Color(0xFF64748B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isEarned
                    ? '✅ 已获得 · ${earned['earned_at'] ?? ''}'
                    : '🔒 未解锁',
                style: TextStyle(
                  fontSize: 13,
                  color: isEarned
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}