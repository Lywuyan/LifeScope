// ============================================================
// FILE: lib/providers/auth_provider.dart
// 认证状态管理 — Provider 模式
//   - 存储 token（flutter_secure_storage）
//   - 提供 login / register / logout
//   - 暴露 isLoggedIn / currentUser 供 UI 读取
// ============================================================
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'dart:convert';

/// API 基地址（开发期指向本机）
const String API_BASE = "http://localhost:8080/api";

class UserInfo {
  final int    id;
  final String username;
  final String email;
  final String? avatarUrl;

  const UserInfo({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id:        json['id'],
    username:  json['username'],
    email:     json['email'],
    avatarUrl: json['avatarUrl'],
  );
}

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String?   _token;
  UserInfo? _currentUser;
  bool      _isLoading = false;

  // ── Getters ──────────────────────────────────
  bool      get isLoggedIn  => _token != null;
  UserInfo? get currentUser => _currentUser;
  bool      get isLoading   => _isLoading;
  String?   get token => _token;
  // ── 初始化（检查本地 token）───────────────────
  Future<void> initialize() async {
    _token = await _storage.read(key: 'token');
    notifyListeners();
  }

  // ── 注册 ─────────────────────────────────────
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final resp = await http.post(
        Uri.parse('$API_BASE/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email':    email,
          'password': password,
        }),
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode == 200 && body['status'] == true) {
        await _handleAuthSuccess(body['data']);
      } else {
        throw Exception(body['message'] ?? '注册失败');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── 登录 ─────────────────────────────────────
  Future<void> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final resp = await http.post(
        Uri.parse('$API_BASE/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final body = jsonDecode(resp.body);
      if (resp.statusCode == 200 && body['status'] == true) {
        await _handleAuthSuccess(body['data']);
      } else {
        throw Exception(body['message'] ?? '登录失败');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── 退出 ─────────────────────────────────────
  Future<void> logout() async {
    await _storage.delete(key: 'token');
    _token       = null;
    _currentUser = null;
    notifyListeners();
  }

  // ── 私有工具 ─────────────────────────────────
  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    _token       = data['token'];
    _currentUser = UserInfo.fromJson(data['user']);
    await _storage.write(key: 'token', value: _token!);
  }
}

/// 全局 http client 单例（避免每次都 new）
final http = Client();
