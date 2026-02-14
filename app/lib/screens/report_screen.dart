import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:html' as html;

import 'package:app/providers/auth_provider.dart';
import 'package:app/widgets/share_poster.dart';

class ReportScreen extends StatefulWidget {
  final DateTime date;
  const ReportScreen({super.key, required this.date});
  
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = true;
  String? _content;
  String? _error;
  final _screenshotCtrl = ScreenshotController();
  
  @override
  void initState() {
    super.initState();
    _loadReport();
  }
  
  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    
    try {
      final dateStr = widget.date.toIso8601String().split('T')[0];
      
      final auth = Provider.of<AuthProvider>(context,listen: false);
      final token = auth.token;

      final url = '$API_BASE/reports/daily/$dateStr';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }
      );
      
      if (response.statusCode == 404) {
        // 报告不存在，生成一个
        await _generateReport();
        return;
      }
      
      final body = jsonDecode(response.body);
      setState(() {
        _content = body['data']['content'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _generateReport() async {
    // 调用生成接口...
  }

  /// 分享海报：截图 SharePoster → 保存临时文件 → 调用系统分享
  Future<void> _shareReport() async {
    if (_content == null) return;

    final dateStr =
        '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';

    // 用 ScreenshotController 对离屏 widget 截图
    final Uint8List? imageBytes = await _screenshotCtrl.captureFromWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Material(
          color: Colors.transparent,
          child: SharePoster(
            reportContent: _content!,
            date: dateStr,
            style: 'funny',
          ),
        ),
      ),
      delay: const Duration(milliseconds: 100),
    );

    if (imageBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ 海报生成失败')),
        );
      }
      return;
    }

    // 保存到临时目录
    // final tempDir = await getTemporaryDirectory();
    // final file = File('${tempDir.path}/lifescope_report_$dateStr.png');
    // await file.writeAsBytes(imageBytes);

    // Web 测试
    final blob = html.Blob([imageBytes], 'image/png');
    final url = html.Url.createObjectUrl(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'lifescope_report_$dateStr.png')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        title: Text('${widget.date.month}月${widget.date.day}日 报告'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _content != null
              ? _buildReport()
              : _buildError(),
    );
  }
  
  Widget _buildReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 报告卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Text(
              _content!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(Icons.favorite_border, '点赞', () {}),
              _actionButton(Icons.share, '分享', _shareReport),
              _actionButton(Icons.refresh, '重新生成', _loadReport),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF64748B)),
          const SizedBox(height: 16),
          Text(_error ?? '加载失败', style: const TextStyle(color: Color(0xFF94A3B8))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadReport,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
  
  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D27),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF22C55E)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}