package com.deepfocus.focus_lock

import android.app.*
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class FocusLockService : Service() {

    private var isMonitoring = false
    private var blockedPackages: List<String> = emptyList()
    private var monitorThread: Thread? = null

    companion object {
        private const val NOTIFICATION_ID = 888
        private const val CHANNEL_ID = "focus_lock_service"
        private const val CHANNEL_NAME = "Focus Lock Service"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val packages = intent?.getStringArrayListExtra("blockedPackages") ?: arrayListOf()
        val duration = intent?.getIntExtra("durationMinutes", 30) ?: 30

        blockedPackages = packages
        isMonitoring = true

        // Start as foreground service
        val notification = buildNotification(duration)
        startForeground(NOTIFICATION_ID, notification)

        // Start monitoring thread
        startMonitoringLoop()

        // Auto-stop after duration
        android.os.Handler(mainLooper).postDelayed({
            stopSelf()
        }, duration * 60 * 1000L)

        return START_STICKY
    }

    private fun startMonitoringLoop() {
        monitorThread?.interrupt()
        monitorThread = Thread {
            val usageStatsManager = getSystemService(
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
                            foregroundPackage != packageName
                        ) {
                            // Bring our app back to front
                            val bringToFront = Intent(this, MainActivity::class.java).apply {
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                                        Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                            }
                            startActivity(bringToFront)
                        }
                    }

                    Thread.sleep(500)
                } catch (e: InterruptedException) {
                    break
                } catch (e: Exception) {
                    try { Thread.sleep(1000) } catch (_: InterruptedException) { break }
                }
            }
        }.apply {
            isDaemon = true
            start()
        }
    }

    private fun buildNotification(durationMinutes: Int): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("🔒 Focus Lock Active")
            .setContentText("Stay focused for $durationMinutes minutes")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setAutoCancel(false)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps focus lock running in the background"
                setShowBadge(false)
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        isMonitoring = false
        monitorThread?.interrupt()
        monitorThread = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
