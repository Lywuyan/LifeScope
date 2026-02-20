package com.example.app

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.lifescope/usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> {
                    result.success(hasUsagePermission())
                }
                "requestPermission" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(true)
                }
                "getUsageStats" -> {
                    val startTime = call.argument<Long>("startTime") ?: 0L
                    val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()

                    if (!hasUsagePermission()) {
                        result.error("NO_PERMISSION", "未授予使用情况访问权限", null)
                        return@setMethodCallHandler
                    }

                    val stats = getUsageStats(startTime, endTime)
                    result.success(stats)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * 检查是否有使用情况访问权限
     */
    private fun hasUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /**
     * 获取指定时间范围内各 APP 的前台使用时长
     * 返回 JSON 字符串: [{"packageName":"xxx","totalTimeMs":12345}, ...]
     */
    private fun getUsageStats(startTime: Long, endTime: Long): String {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)

        val jsonArray = JSONArray()

        // 合并同一包名的数据
        val merged = mutableMapOf<String, Long>()
        for (s in stats) {
            if (s.totalTimeInForeground > 0) {
                merged[s.packageName] = (merged[s.packageName] ?: 0L) + s.totalTimeInForeground
            }
        }

        for ((pkg, timeMs) in merged) {
            val obj = JSONObject()
            obj.put("packageName", pkg)
            obj.put("totalTimeMs", timeMs)
            jsonArray.put(obj)
        }

        return jsonArray.toString()
    }
}
