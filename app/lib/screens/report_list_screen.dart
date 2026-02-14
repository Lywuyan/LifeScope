import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/report_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});
  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _types = ['daily', 'weekly', 'monthly'];
  final _typeLabels = ['日报', '周报', '月报'];

  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  int _page = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        _page = 1;
        _loadReports();
      }
    });
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final type = _types[_tabCtrl.index];

      final url = '$API_BASE/reports/list'
          '?report_type=$type&page=$_page&size=10';
      final resp = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Content-Type': 'application/json',
        },
      );
      final body = jsonDecode(resp.body);

      setState(() {
        _items = List<Map<String, dynamic>>.from(body['data']['items']);
        _total = body['data']['total'];
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
        title: const Text('📋 历史报告'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF22C55E),
          labelColor: const Color(0xFF22C55E),
          unselectedLabelColor: const Color(0xFF64748B),
          tabs: _typeLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('暂无报告', style: TextStyle(color: Color(0xFF64748B))))
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (_, i) => _buildReportCard(_items[i]),
                  ),
                ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportScreen(date: DateTime.parse(item['date'])),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D27),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2D3A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['date'],
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: Color(0xFF22C55E),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['style'] ?? 'funny',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF22C55E)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item['content'] ?? '',
              style: const TextStyle(fontSize: 14, color: Color(0xFFCBD5E1), height: 1.5),
              maxLines: 3, overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}