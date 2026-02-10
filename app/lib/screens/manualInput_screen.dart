import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:app/providers/auth_provider.dart';

class ManualInputScreen extends StatefulWidget {
  const ManualInputScreen({super.key});
  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  final _appNameCtrl = TextEditingController();
  final _usageMinsCtrl = TextEditingController();
  String _category = 'other';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _appNameCtrl.dispose();
    _usageMinsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;

      final response = await http.post(
        Uri.parse('$API_BASE/data/upload'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recordDate': _selectedDate.toIso8601String().split('T')[0],
          'appName': _appNameCtrl.text.trim(),
          'usageMins': int.parse(_usageMinsCtrl.text.trim()),
          'category': _category,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ 数据上传成功！')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(body['message'] ?? '上传失败');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1117),
        title: const Text('手动录入数据'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 日期选择
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D27),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2D3A)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('日期', style: TextStyle(color: Color(0xFF94A3B8))),
                      Text(
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // APP 名称
              TextFormField(
                controller: _appNameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('APP 名称', Icons.phone_android),
                validator: (v) => v == null || v.trim().isEmpty ? '请输入 APP 名称' : null,
              ),
              const SizedBox(height: 16),

              // 使用时长
              TextFormField(
                controller: _usageMinsCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('使用时长（分钟）', Icons.timer),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '请输入使用时长';
                  final mins = int.tryParse(v.trim());
                  if (mins == null || mins < 1) return '时长至少1分钟';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 分类
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: const Color(0xFF1A1D27),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('分类', Icons.category),
                items: const [
                  DropdownMenuItem(value: 'social', child: Text('社交')),
                  DropdownMenuItem(value: 'game', child: Text('游戏')),
                  DropdownMenuItem(value: 'work', child: Text('工作/学习')),
                  DropdownMenuItem(value: 'browser', child: Text('浏览器')),
                  DropdownMenuItem(value: 'other', child: Text('其他')),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 24),

              // 提交按钮
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    disabledBackgroundColor: const Color(0xFF22C55E66),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('提交', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B)),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
      filled: true,
      fillColor: const Color(0xFF1A1D27),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A2D3A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A2D3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF22C55E)),
      ),
    );
  }
}