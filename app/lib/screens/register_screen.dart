// ============================================================
// FILE: lib/screens/register_screen.dart
// 注册页面
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmCtrl     = TextEditingController();
  String? _errorMsg;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _errorMsg = null);

    final username = _usernameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirm  = _confirmCtrl.text.trim();

    // ── 客户端校验 ─────────────────────────────
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = '所有字段不能为空');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMsg = '密码至少 6 位');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMsg = '两次密码不匹配');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorMsg = '邮箱格式不正确');
      return;
    }

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.register(username: username, email: email, password: password);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _errorMsg = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // ── 标题 ─────────────────────────────
              const Text('创建账户', style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('加入 LifeScope，开始了解你自己', style: TextStyle(
                fontSize: 14, color: Color(0xFF64748B))),

              const SizedBox(height: 36),

              // ── 表单字段 ───────────────────────────
              TextField(
                controller: _usernameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _regInputDecoration('用户名', Icons.person_outline),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: _regInputDecoration('邮箱', Icons.email_outlined),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _regInputDecoration('密码', Icons.lock_outline),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _confirmCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _regInputDecoration('确认密码', Icons.lock_outline),
              ),
              const SizedBox(height: 8),

              // ── 错误信息 ─────────────────────────
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_errorMsg!, style: const TextStyle(color: Color(0xFFF87171), fontSize: 13)),
                ),

              const SizedBox(height: 16),

              // ── 注册按钮 ─────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    disabledBackgroundColor: const Color(0xFF22C55E66),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('注册', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 24),

              // ── 登录链接 ─────────────────────────
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text.rich(TextSpan(
                    text: '已有账户？',
                    style: TextStyle(color: Color(0xFF64748B)),
                    children: [
                      TextSpan(text: ' 登录', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w600)),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _regInputDecoration(String label, IconData icon) {
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
