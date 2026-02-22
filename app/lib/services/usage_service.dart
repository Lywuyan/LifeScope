// ============================================================
// FILE: lib/services/usage_service.dart
// Android 屏幕使用时间采集服务
//   - 通过 Platform Channel 调用 Android UsageStatsManager
//   - 按 APP 包名自动分类（social/game/work/other）
//   - 批量上传到后端
// ============================================================
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:app/providers/auth_provider.dart';

class UsageService {
  static const _channel = MethodChannel('com.lifescope/usage_stats');

  // ── APP 包名 → 分类映射 ─────────────────────
  static const Map<String, String> _categoryMap = {
    // 社交
    'com.tencent.mm': 'social',           // 微信
    'com.tencent.mobileqq': 'social',     // QQ
    'com.sina.weibo': 'social',           // 微博
    'com.ss.android.ugc.aweme': 'social', // 抖音
    'com.kuaishou.nebula': 'social',      // 快手
    'com.smile.gifmaker': 'social',       // 快手极速版
    'com.xingin.xhs': 'social',           // 小红书
    'com.zhihu.android': 'social',        // 知乎
    'tv.danmaku.bili': 'social',          // B站
    'com.eg.android.AlipayGphone': 'social', // 支付宝
    // 游戏
    'com.miHoYo.Yuanshen': 'game',        // 原神
    'com.miHoYo.hkrpg': 'game',           // 星穹铁道
    'com.tencent.tmgp.sgame': 'game',     // 王者荣耀
    'com.tencent.tmgp.pubgmhd': 'game',  // 和平精英
    'com.netease.hy': 'game',             // 第五人格
    'com.netease.onmyoji': 'game',        // 阴阳师
    // 工作/学习
    'com.alibaba.android.rimet': 'work',  // 钉钉
    'com.tencent.wework': 'work',         // 企业微信
    'com.microsoft.teams': 'work',        // Teams
    'com.lark.client': 'work',            // 飞书
    'com.youdao.dict': 'work',            // 有道词典
    'com.baidu.netdisk': 'work',          // 百度网盘
  };

  /// 检查是否有使用情况访问权限
  static Future<bool> hasPermission() async {
    try {
      return await _channel.invokeMethod('hasPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 跳转系统设置请求权限
  static Future<void> requestPermission() async {
    await _channel.invokeMethod('requestPermission');
  }

  /// 获取当天 APP 使用数据并上传后端
  /// 返回 true 表示成功
  static Future<bool> syncToday(String token) async {
    try {
      if (!await hasPermission()) return false;

      // 今天 0:00 ~ 现在
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final startTime = startOfDay.millisecondsSinceEpoch;
      final endTime = now.millisecondsSinceEpoch;

      // 调用原生获取使用数据
      final jsonStr = await _channel.invokeMethod<String>('getUsageStats', {
        'startTime': startTime,
        'endTime': endTime,
      });

      if (jsonStr == null || jsonStr.isEmpty) return false;

      final List<dynamic> rawList = jsonDecode(jsonStr);
      if (rawList.isEmpty) return false;

      // 分类汇总
      final String todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final List<Map<String, dynamic>> batchData = [];

      for (final item in rawList) {
        final pkg = item['packageName'] as String;
        final timeMs = item['totalTimeMs'] as int;
        final mins = (timeMs / 60000).round();
        if (mins < 1) continue; // 忽略不足 1 分钟的

        final category = _classifyApp(pkg);

        batchData.add({
          'recordDate': todayStr,
          'appName': pkg,
          'usageMins': mins,
          'category': category,
        });
      }

      if (batchData.isEmpty) return true; // 没有数据也不算失败

      // 批量上传
      final resp = await http.Client().post(
        Uri.parse('$API_BASE/data/batch'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(batchData),
      );

      return resp.statusCode == 200;
    } catch (e) {
      // 静默失败，不影响用户体验
      return false;
    }
  }

  /// 根据包名分类 APP
  static String _classifyApp(String packageName) {
    // 精确匹配
    if (_categoryMap.containsKey(packageName)) {
      return _categoryMap[packageName]!;
    }
    // 前缀匹配（游戏包名通常有共同前缀）
    if (packageName.startsWith('com.miHoYo.') ||
        packageName.startsWith('com.tencent.tmgp.') ||
        packageName.startsWith('com.netease.')) {
      return 'game';
    }
    return 'other';
  }
}
