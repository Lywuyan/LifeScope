import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _todayData;
  List<Map<String, dynamic>> _weeklyData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      // 并行加载
      final results = await Future.wait([
        http.get(
          Uri.parse('$API_BASE/reports/weekly'),
          headers: {
            'Authorization': 'Bearer ${auth.token}',
            'Content-Type': 'application/json',
          },
        ),
        http.get(
          Uri.parse('$API_BASE/api/reports/top-apps/${DateTime.now().toIso8601String().split('T')[0]}'),
          headers: {
            'Authorization': 'Bearer ${auth.token}',
            'Content-Type': 'application/json',
          },
        ),
      ]);

      final weeklyBody = jsonDecode(results[0].body);
      final topAppsBody = jsonDecode(results[1].body);

      setState(() {
        _weeklyData = List<Map<String, dynamic>>.from(weeklyBody['data']);
        _todayData = _weeklyData.isNotEmpty ? _weeklyData.last : null;
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
        title: const Text('📊 数据仪表盘'),
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
                    // ── 今日概览 ──
                    _buildSectionTitle('今日概览'),
                    const SizedBox(height: 12),
                    _buildTodayOverview(),
                    const SizedBox(height: 24),

                    // ── 分类占比饼图 ──
                    _buildSectionTitle('分类占比'),
                    const SizedBox(height: 12),
                    _buildPieChart(),
                    const SizedBox(height: 24),

                    // ── 近 7 天趋势柱状图 ──
                    _buildSectionTitle('近 7 天趋势'),
                    const SizedBox(height: 12),
                    _buildBarChart(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
      ),
    );
  }

  Widget _buildTodayOverview() {
    if (_todayData == null) {
      return _emptyCard('暂无今日数据');
    }
    final total = _todayData!['total_mins'] ?? 0;
    final hours = total ~/ 60;
    final mins = total % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('总时长', '${hours}h ${mins}m', const Color(0xFF22C55E)),
          _statItem('社交', '${_todayData!['social_mins']}m', const Color(0xFF3B82F6)),
          _statItem('游戏', '${_todayData!['game_mins']}m', const Color(0xFFF59E0B)),
          _statItem('工作', '${_todayData!['work_mins']}m', const Color(0xFFA78BFA)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildPieChart() {
    if (_todayData == null) return _emptyCard('暂无数据');

    final social = (_todayData!['social_mins'] ?? 0).toDouble();
    final game = (_todayData!['game_mins'] ?? 0).toDouble();
    final work = (_todayData!['work_mins'] ?? 0).toDouble();
    final browser = (_todayData!['browser_mins'] ?? 0).toDouble();
    final total = social + game + work + browser;
    if (total == 0) return _emptyCard('暂无数据');

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(16),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(value: social, title: '社交', color: const Color(0xFF3B82F6), radius: 50, titleStyle: const TextStyle(fontSize: 12, color: Colors.white)),
            PieChartSectionData(value: game, title: '游戏', color: const Color(0xFFF59E0B), radius: 50, titleStyle: const TextStyle(fontSize: 12, color: Colors.white)),
            PieChartSectionData(value: work, title: '工作', color: const Color(0xFFA78BFA), radius: 50, titleStyle: const TextStyle(fontSize: 12, color: Colors.white)),
            PieChartSectionData(value: browser, title: '浏览', color: const Color(0xFF34D399), radius: 50, titleStyle: const TextStyle(fontSize: 12, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (_weeklyData.isEmpty) return _emptyCard('暂无数据');

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (_weeklyData.map((e) => (e['total_mins'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b)) * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= _weeklyData.length) return const SizedBox();
                  final d = _weeklyData[idx]['date'] as String;
                  return Text(d.substring(5), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _weeklyData.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: (e.value['total_mins'] ?? 0).toDouble(),
                  gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF34D399)]),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      height: 120, width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Text(msg, style: const TextStyle(color: Color(0xFF64748B)))),
    );
  }
}