// ============================================================
// FILE: lib/screens/login_screen.dart
// 登录页面
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _errorMsg;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _errorMsg = null);

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = '用户名和密码不能为空');
      return;
    }

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(username: username, password: password);
      // 登录成功 → 跳转首页
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
              const SizedBox(height: 60),

              // ── Logo ────────────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA78BFA), Color(0xFF60A5FA), Color(0xFF34D399)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(child: Text('LS',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              ),
              const SizedBox(height: 16),
              const Text('LifeScope', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              const Text('了解你的生活', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),

              const SizedBox(height: 48),

              // ── 用户名输入 ───────────────────────
              TextField(
                controller: _usernameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('用户名', Icons.person_outline),
              ),
              const SizedBox(height: 16),

              // ── 密码输入 ─────────────────────────
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('密码', Icons.lock_outline),
              ),
              const SizedBox(height: 8),

              // ── 错误信息 ─────────────────────────
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_errorMsg!, style: const TextStyle(color: Color(0xFFF87171), fontSize: 13)),
                ),

              const SizedBox(height: 12),

              // ── 登录按钮 ─────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    disabledBackgroundColor: const Color(0xff22c55e66),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('登录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 24),

              // ── 注册链接 ─────────────────────────
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                  child: const Text.rich(TextSpan(
                    text: '没有账户？',
                    style: TextStyle(color: Color(0xFF64748B)),
                    children: [
                      TextSpan(text: ' 注册', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w600)),
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

/// 统一的输入框样式
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
