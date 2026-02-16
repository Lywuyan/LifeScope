import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';

class ChallengeListScreen extends StatefulWidget {
  const ChallengeListScreen({super.key});
  @override
  State<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _activeChallenges = [];
  List<Map<String, dynamic>> _discoverChallenges = [];
  List<Map<String, dynamic>> _historyChallenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
        http.get(Uri.parse('$API_BASE/challenges/active'), headers: _headers),
        http.get(Uri.parse('$API_BASE/challenges/discover'), headers: _headers),
        http.get(Uri.parse('$API_BASE/challenges/history'), headers: _headers),
      ]);

      setState(() {
        _activeChallenges =
            List<Map<String, dynamic>>.from(jsonDecode(results[0].body)['data'] ?? []);
        _discoverChallenges =
            List<Map<String, dynamic>>.from(jsonDecode(results[1].body)['data'] ?? []);
        _historyChallenges =
            List<Map<String, dynamic>>.from(jsonDecode(results[2].body)['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinChallenge(String challengeId) async {
    try {
      final resp = await http.post(
        Uri.parse('$API_BASE/challenges/$challengeId/join'),
        headers: _headers,
      );
      final body = jsonDecode(resp.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['status'] == true ? '✅ 加入成功' : '❌ ${body['message']}')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ 加入失败: $e')));
      }
    }
  }

  List<Map<String, dynamic>> get _currentList {
    switch (_tabCtrl.index) {
      case 0: return _activeChallenges;
      case 1: return _discoverChallenges;
      case 2: return _historyChallenges;
      default: return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        title: const Text('⚡ 挑战中心'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF22C55E),
          labelColor: const Color(0xFF22C55E),
          unselectedLabelColor: const Color(0xFF64748B),
          tabs: [
            Tab(text: '进行中 (${_activeChallenges.length})'),
            Tab(text: '发现 (${_discoverChallenges.length})'),
            Tab(text: '历史 (${_historyChallenges.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF22C55E),
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildListView(_activeChallenges, 0),
                _buildListView(_discoverChallenges, 1),
                _buildListView(_historyChallenges, 2),
              ],
            ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> list, int tabIndex) {
    if (list.isEmpty) return _buildEmptyState(tabIndex);
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (_, i) => _buildChallengeCard(list[i], tabIndex),
      ),
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    final messages = ['还没有进行中的挑战', '暂无可加入的挑战', '暂无历史挑战'];
    final hints = ['点击右下角 + 创建一个吧！', '添加好友后即可发现他们的挑战', ''];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(messages[tabIndex],
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 16)),
          if (hints[tabIndex].isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(hints[tabIndex],
                style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> c, int tabIndex) {
    final progress = (c['myProgressPct'] ?? 0) / 100.0;
    final daysLeft = c['daysLeft'] ?? 0;
    final status = c['status'] ?? 'ACTIVE';
    final isActive = status == 'ACTIVE';
    final isDiscover = tabIndex == 1;

    Color statusColor;
    String statusText;
    if (status == 'COMPLETED') {
      statusColor = const Color(0xFF22C55E);
      statusText = '✅ 已完成';
    } else if (status == 'FAILED') {
      statusColor = const Color(0xFFEF4444);
      statusText = '❌ 已失败';
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusText = '${daysLeft}天剩余';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2D3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(c['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusText,
                    style: TextStyle(fontSize: 12, color: statusColor)),
              ),
            ],
          ),

          // 描述
          if (c['description'] != null && c['description'] != '') ...[
            const SizedBox(height: 8),
            Text(c['description'],
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          ],

          const SizedBox(height: 12),

          // 信息标签
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _infoChip('🎯',
                  '${c['targetCategory'] ?? '总计'} ${c['targetOperator'] ?? '<'} ${c['targetValue'] ?? 0}分钟'),
              _infoChip('👥', '${c['participantCount'] ?? 1}人参与'),
              _infoChip('📅', '${c['durationDays'] ?? 1}天'),
            ],
          ),

          // 进度条（进行中 Tab）
          if (!isDiscover && isActive && c['myProgressPct'] != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFF2A2D3A),
                color: progress >= 1.0
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 4),
            Text('我的进度 ${(progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ],

          // 加入按钮（发现 Tab）
          if (isDiscover) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _joinChallenge(c['id'].toString()),
                child: const Text('🚀 加入挑战',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],

          // 创建者
          const SizedBox(height: 8),
          Text('创建者: ${c['creatorName'] ?? '未知'}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _infoChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$emoji $text',
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
    );
  }

  // ==================== 创建挑战 ====================

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final valueCtrl = TextEditingController(text: '180');
    String selectedType = 'reduce';
    String selectedCategory = 'total';
    String selectedOperator = '<';
    int selectedDays = 3;

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
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text('⚡ 创建挑战',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(height: 20),
                _inputField('挑战标题', titleCtrl, '例如：少刷手机'),
                const SizedBox(height: 12),
                _inputField('描述 (可选)', descCtrl, '给这个挑战加点说明'),
                const SizedBox(height: 12),

                const Text('挑战类型',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                const SizedBox(height: 6),
                Wrap(spacing: 8, children: [
                  _choiceChip('减时', 'reduce', selectedType, (v) {
                    setModalState(() => selectedType = v);
                  }),
                  _choiceChip('专注', 'focus', selectedType, (v) {
                    setModalState(() => selectedType = v);
                  }),
                  _choiceChip('自律', 'discipline', selectedType, (v) {
                    setModalState(() => selectedType = v);
                  }),
                ]),
                const SizedBox(height: 12),

                const Text('目标类别',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                const SizedBox(height: 6),
                Wrap(spacing: 8, children: [
                  _choiceChip('总计', 'total', selectedCategory, (v) {
                    setModalState(() => selectedCategory = v);
                  }),
                  _choiceChip('社交', 'social', selectedCategory, (v) {
                    setModalState(() => selectedCategory = v);
                  }),
                  _choiceChip('游戏', 'game', selectedCategory, (v) {
                    setModalState(() => selectedCategory = v);
                  }),
                  _choiceChip('工作', 'work', selectedCategory, (v) {
                    setModalState(() => selectedCategory = v);
                  }),
                ]),
                const SizedBox(height: 12),

                Row(children: [
                  DropdownButton<String>(
                    value: selectedOperator,
                    dropdownColor: const Color(0xFF2A2D3A),
                    style: const TextStyle(color: Colors.white),
                    items: ['<', '>', '=']
                        .map((op) =>
                            DropdownMenuItem(value: op, child: Text(op)))
                        .toList(),
                    onChanged: (v) =>
                        setModalState(() => selectedOperator = v!),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _inputField('目标 (分钟)', valueCtrl, '180',
                          isNumber: true)),
                ]),
                const SizedBox(height: 12),

                const Text('持续天数',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [1, 3, 7, 14, 30]
                      .map((d) => _choiceChip('${d}天', d, selectedDays, (v) {
                            setModalState(() => selectedDays = v as int);
                          }))
                      .toList(),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      await _submitCreate(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        challengeType: selectedType,
                        targetCategory: selectedCategory,
                        targetOperator: selectedOperator,
                        targetValue: int.tryParse(valueCtrl.text) ?? 180,
                        durationDays: selectedDays,
                      );
                      if (mounted) Navigator.pop(ctx);
                    },
                    child: const Text('创建挑战',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, String hint,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF475569)),
            filled: true,
            fillColor: const Color(0xFF2A2D3A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _choiceChip<T>(
      String label, T value, T selected, ValueChanged<T> onSelected) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF22C55E).withOpacity(0.2)
              : const Color(0xFF2A2D3A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF22C55E)
                : const Color(0xFF3A3D4A),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF94A3B8),
            )),
      ),
    );
  }

  Future<void> _submitCreate({
    required String title,
    required String description,
    required String challengeType,
    required String targetCategory,
    required String targetOperator,
    required int targetValue,
    required int durationDays,
  }) async {
    try {
      await http.post(
        Uri.parse('$API_BASE/challenges/create'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'challengeType': challengeType,
          'targetCategory': targetCategory,
          'targetOperator': targetOperator,
          'targetValue': targetValue,
          'durationDays': durationDays,
        }),
      );
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('创建失败: $e')));
      }
    }
  }
}
