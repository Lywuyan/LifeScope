// ============================================================
// FILE: lib/main.dart
// Flutter 入口点
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/splash_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/register_screen.dart';
import 'package:app/screens/home_screen.dart';

void main() {
  runApp(const LifeScopeApp());
}

class LifeScopeApp extends StatelessWidget {
  const LifeScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'LifeScope',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        // 路由
        initialRoute: '/',
        routes: {
          '/':         (ctx) => const SplashScreen(),
          '/login':    (ctx) => const LoginScreen(),
          '/register': (ctx) => const RegisterScreen(),
          '/home':     (ctx) => const HomeScreen(),
        },
      ),
    );
  }

  /// 深色主题 — LifeScope 视觉风格
  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF22C55E),   // 主色 绿
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0F1117),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1D27),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
