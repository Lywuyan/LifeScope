import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String get _token =>
      Provider.of<AuthProvider>(context, listen: false).token ?? '';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      };

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$API_BASE/friends/list'), headers: _headers),
        http.get(Uri.parse('$API_BASE/friends/requests'), headers: _headers),
      ]);

      setState(() {
        _friends = List<Map<String, dynamic>>.from(
            jsonDecode(results[0].body)['data'] ?? []);
        _requests = List<Map<String, dynamic>>.from(
            jsonDecode(results[1].body)['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    await http.post(
      Uri.parse('$API_BASE/friends/accept/$requestId'),
      headers: _headers,
    );
    _loadData();
  }

  Future<void> _rejectRequest(String requestId) async {
    await http.post(
      Uri.parse('$API_BASE/friends/reject/$requestId'),
      headers: _headers,
    );
    _loadData();
  }

  Future<void> _removeFriend(String friendId) async {
    await http.post(
      Uri.parse('$API_BASE/friends/remove/$friendId'),
      headers: _headers,
    );
    _loadData();
  }

  // ==================== 搜索添加好友 ====================

  void _showSearchDialog() {
    final searchCtrl = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1D27),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔍 搜索用户',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16),

              // 搜索框
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '输入用户名搜索...',
                        hintStyle:
                            const TextStyle(color: Color(0xFF475569)),
                        filled: true,
                        fillColor: const Color(0xFF2A2D3A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) async {
                        if (searchCtrl.text.trim().isEmpty) return;
                        setModalState(() => isSearching = true);
                        try {
                          final resp = await http.get(
                            Uri.parse(
                                '$API_BASE/friends/search?keyword=${searchCtrl.text.trim()}'),
                            headers: _headers,
                          );
                          final body = jsonDecode(resp.body);
                          setModalState(() {
                            searchResults =
                                List<Map<String, dynamic>>.from(
                                    body['data'] ?? []);
                            isSearching = false;
                          });
                        } catch (e) {
                          setModalState(() => isSearching = false);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onPressed: () async {
                      if (searchCtrl.text.trim().isEmpty) return;
                      setModalState(() => isSearching = true);
                      try {
                        final resp = await http.get(
                          Uri.parse(
                              '$API_BASE/friends/search?keyword=${searchCtrl.text.trim()}'),
                          headers: _headers,
                        );
                        final body = jsonDecode(resp.body);
                        setModalState(() {
                          searchResults =
                              List<Map<String, dynamic>>.from(
                                  body['data'] ?? []);
                          isSearching = false;
                        });
                      } catch (e) {
                        setModalState(() => isSearching = false);
                      }
                    },
                    child: const Text('搜索',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 搜索结果
              if (isSearching)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
              else if (searchResults.isEmpty &&
                  searchCtrl.text.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('未找到用户',
                      style: TextStyle(color: Color(0xFF64748B))),
                )
              else
                ...searchResults.map((user) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2D3A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF334155),
                            child: Text(
                                (user['username'] ?? '?')[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(user['username'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF22C55E),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              try {
                                await http.post(
                                  Uri.parse(
                                      '$API_BASE/friends/add/${user['id']}'),
                                  headers: _headers,
                                );
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content:
                                              Text('✅ 好友请求已发送')));
                                }
                              } catch (e) {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          content:
                                              Text('❌ 发送失败: $e')));
                                }
                              }
                            },
                            child: const Text('添加',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        title: const Text('👥 我的好友'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Color(0xFF22C55E)),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 待处理请求
                    if (_requests.isNotEmpty) ...[
                      Text('待处理请求 (${_requests.length})',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59E0B))),
                      const SizedBox(height: 8),
                      ..._requests.map((r) => _buildRequestCard(r)),
                      const SizedBox(height: 20),
                    ],
                    // 好友列表
                    Text('好友 (${_friends.length})',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    if (_friends.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Text('👥', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 8),
                              Text('还没有好友',
                                  style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 16)),
                              SizedBox(height: 4),
                              Text('点击右上角 + 搜索添加好友',
                                  style: TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._friends.map((f) => _buildFriendCard(f)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF334155),
            child: Text((req['username'] ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(req['username'] ?? '',
                  style: const TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () => _acceptRequest(req['id']),
            child: const Text('接受',
                style: TextStyle(color: Color(0xFF22C55E))),
          ),
          TextButton(
            onPressed: () => _rejectRequest(req['id']),
            child: const Text('拒绝',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2D3A)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF334155),
            child: Text(
                (friend['username'] ?? '?')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(friend['username'] ?? '',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15))),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert,
                color: Color(0xFF475569), size: 20),
            color: const Color(0xFF2A2D3A),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'remove',
                child: Text('删除好友',
                    style: TextStyle(color: Color(0xFFEF4444))),
              ),
            ],
            onSelected: (value) {
              if (value == 'remove') {
                _removeFriend(friend['id']);
              }
            },
          ),
        ],
      ),
    );
  }
}