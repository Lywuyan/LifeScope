import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) _loadData();
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;
      final type = _tabCtrl.index == 0 ? 'daily' : 'weekly';
      final url = '$API_BASE/leaderboard/$type';
      final resp = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final body = jsonDecode(resp.body);

      setState(() {
        _items = List<Map<String, dynamic>>.from(body['data']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        title: const Text('🏅 好友排行榜'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFFF59E0B),
          labelColor: const Color(0xFFF59E0B),
          unselectedLabelColor: const Color(0xFF64748B),
          tabs: const [Tab(text: '今日'), Tab(text: '本周')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (_, i) => _buildRankCard(_items[i], i),
            ),
    );
  }

  Widget _buildRankCard(Map<String, dynamic> item, int index) {
    final isMe = item['me'] == true;
    final rank = item['rank'];
    final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '$rank';
    final hours = (item['totalMins'] ?? 0) ~/ 60;
    final mins = (item['totalMins'] ?? 0) % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF1E293B) : const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5))
            : Border.all(color: const Color(0xFF2A2D3A)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              medal, textAlign: TextAlign.center,
              style: TextStyle(fontSize: rank <= 3 ? 22 : 16, color: const Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF334155),
            child: Text(
              (item['username'] ?? '?')[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${item['username']}${isMe ? ' (我)' : ''}',
              style: TextStyle(
                fontSize: 15, color: isMe ? const Color(0xFFF59E0B) : Colors.white,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${hours}h ${mins}m',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: rank == 1 ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}