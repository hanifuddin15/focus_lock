package com.deepfocus.focus_lock

import android.app.Activity
import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class DeviceLockPlugin private constructor(
    private val activity: Activity,
    private val methodChannel: MethodChannel,
    private val eventChannel: EventChannel
) : MethodCallHandler {

    private var eventSink: EventChannel.EventSink? = null
    private var monitoringThread: Thread? = null
    private var isMonitoring = false
    private var blockedPackages: List<String> = emptyList()

    companion object {
        private const val CHANNEL = "com.deepfocus.focus_lock/device_lock"
        private const val EVENT_CHANNEL = "com.deepfocus.focus_lock/lock_events"

        fun registerWith(flutterEngine: FlutterEngine, activity: Activity) {
            val methodChannel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger, CHANNEL
            )
            val eventChannel = EventChannel(
                flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL
            )

            val plugin = DeviceLockPlugin(activity, methodChannel, eventChannel)
            methodChannel.setMethodCallHandler(plugin)
            eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    plugin.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    plugin.eventSink = null
                }
            })
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkPermissions" -> checkPermissions(result)
            "requestUsageStatsPermission" -> requestUsageStatsPermission(result)
            "requestOverlayPermission" -> requestOverlayPermission(result)
            "startMonitoring" -> {
                val packages = call.argument<List<String>>("blockedPackages") ?: emptyList()
                val duration = call.argument<Int>("durationMinutes") ?: 30
                startMonitoring(packages, duration, result)
            }
            "stopMonitoring" -> stopMonitoring(result)
            "getInstalledApps" -> getInstalledApps(result)
            "enableImmersiveMode" -> enableImmersiveMode(result)
            "disableImmersiveMode" -> disableImmersiveMode(result)
            else -> result.notImplemented()
        }
    }

    // ─── Permission Checks ───────────────────────────────────────────

    private fun checkPermissions(result: MethodChannel.Result) {
        val hasUsageStats = hasUsageStatsPermission()
        val hasOverlay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(activity)
        } else true
        val hasCamera = activity.checkSelfPermission(
            android.Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED

        result.success(mapOf(
            "usageStats" to hasUsageStats,
            "overlay" to hasOverlay,
            "camera" to hasCamera
        ))
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = activity.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                activity.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                activity.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            activity.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("PERMISSION_ERROR", e.message, null)
        }
    }

    private fun requestOverlayPermission(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:${activity.packageName}")
                )
                activity.startActivity(intent)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("PERMISSION_ERROR", e.message, null)
        }
    }

    // ─── App Monitoring ──────────────────────────────────────────────

    private fun startMonitoring(
        packages: List<String>,
        durationMinutes: Int,
        result: MethodChannel.Result
    ) {
        if (!hasUsageStatsPermission()) {
            result.error("NO_PERMISSION", "Usage Stats permission not granted", null)
            return
        }

        blockedPackages = packages
        isMonitoring = true

        // Start foreground service
        val serviceIntent = Intent(activity, FocusLockService::class.java).apply {
            putStringArrayListExtra("blockedPackages", ArrayList(packages))
            putExtra("durationMinutes", durationMinutes)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.startForegroundService(serviceIntent)
        } else {
            activity.startService(serviceIntent)
        }

        // Also start monitoring in plugin for direct feedback
        startPollingLoop()

        result.success(true)
    }

    private fun stopMonitoring(result: MethodChannel.Result) {
        isMonitoring = false
        monitoringThread?.interrupt()
        monitoringThread = null

        // Stop foreground service
        val serviceIntent = Intent(activity, FocusLockService::class.java)
        activity.stopService(serviceIntent)

        result.success(true)
    }

    private fun startPollingLoop() {
        monitoringThread?.interrupt()
        monitoringThread = Thread {
            val usageStatsManager = activity.getSystemService(
                Context.USAGE_STATS_SERVICE
            ) as UsageStatsManager

            while (isMonitoring && !Thread.currentThread().isInterrupted) {
                try {
                    val endTime = System.currentTimeMillis()
                    val startTime = endTime - 1000

                    val stats = usageStatsManager.queryUsageStats(
                        UsageStatsManager.INTERVAL_DAILY, startTime, endTime
                    )

                    if (stats != null && stats.isNotEmpty()) {
                        val foregroundApp = stats
                            .filter { it.lastTimeUsed > startTime - 5000 }
                            .maxByOrNull { it.lastTimeUsed }

                        val foregroundPackage = foregroundApp?.packageName

                        if (foregroundPackage != null &&
                            blockedPackages.contains(foregroundPackage) &&
                            foregroundPackage != activity.packageName
                        ) {
                            // Blocked app detected! Bring our app to front
                            activity.runOnUiThread {
                                eventSink?.success(mapOf(
                                    "type" to "blocked_app_detected",
                                    "packageName" to foregroundPackage
                                ))

                                // Bring app to foreground
                                val bringToFront = Intent(activity, MainActivity::class.java).apply {
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                                            Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                                }
                                activity.startActivity(bringToFront)
                            }
                        }
                    }

                    Thread.sleep(500)
                } catch (e: InterruptedException) {
                    break
                } catch (e: Exception) {
                    // Continue monitoring even on errors
                    Thread.sleep(1000)
                }
            }
        }.apply {
            isDaemon = true
            start()
        }
    }

    // ─── Installed Apps ──────────────────────────────────────────────

    private fun getInstalledApps(result: MethodChannel.Result) {
        try {
            val pm = activity.packageManager
            val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)

            val appList = apps
                .filter { isUserApp(it) }
                .filter { it.packageName != activity.packageName }
                .map { appInfo ->
                    val appName = pm.getApplicationLabel(appInfo).toString()
                    val category = getCategoryName(appInfo)

                    mapOf(
                        "packageName" to appInfo.packageName,
                        "appName" to appName,
                        "category" to category,
                        "isBlocked" to false,
                        "isWhitelisted" to false
                    )
                }
                .sortedBy { it["appName"] as String }

            result.success(appList)
        } catch (e: Exception) {
            result.error("APP_LIST_ERROR", e.message, null)
        }
    }

    private fun isUserApp(appInfo: ApplicationInfo): Boolean {
        return (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0 ||
               (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
    }

    private fun getCategoryName(appInfo: ApplicationInfo): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return when (appInfo.category) {
                ApplicationInfo.CATEGORY_SOCIAL -> "Social"
                ApplicationInfo.CATEGORY_VIDEO -> "Entertainment"
                ApplicationInfo.CATEGORY_AUDIO -> "Music"
                ApplicationInfo.CATEGORY_IMAGE -> "Media"
                ApplicationInfo.CATEGORY_GAME -> "Games"
                ApplicationInfo.CATEGORY_NEWS -> "News"
                ApplicationInfo.CATEGORY_PRODUCTIVITY -> "Productivity"
                else -> "Other"
            }
        }
        return "Other"
    }

    // ─── Immersive Mode ──────────────────────────────────────────────

    private fun enableImmersiveMode(result: MethodChannel.Result) {
        activity.runOnUiThread {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                activity.window.setDecorFitsSystemWindows(false)
            }
            activity.window.addFlags(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
        result.success(true)
    }

    private fun disableImmersiveMode(result: MethodChannel.Result) {
        activity.runOnUiThread {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                activity.window.setDecorFitsSystemWindows(true)
            }
            activity.window.clearFlags(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
        result.success(true)
    }
}
