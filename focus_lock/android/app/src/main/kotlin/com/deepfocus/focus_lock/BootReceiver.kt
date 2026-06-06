package com.deepfocus.focus_lock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build

class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val PREFS_NAME = "focus_lock_prefs"
        private const val KEY_IS_ACTIVE = "is_session_active"
        private const val KEY_BLOCKED_PACKAGES = "blocked_packages"
        private const val KEY_REMAINING_MINUTES = "remaining_minutes"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val isActive = prefs.getBoolean(KEY_IS_ACTIVE, false)

            if (isActive) {
                val packages = prefs.getStringSet(KEY_BLOCKED_PACKAGES, emptySet())
                    ?.toList() ?: return
                val remainingMinutes = prefs.getInt(KEY_REMAINING_MINUTES, 0)

                if (remainingMinutes > 0 && packages.isNotEmpty()) {
                    val serviceIntent = Intent(context, FocusLockService::class.java).apply {
                        putStringArrayListExtra("blockedPackages", ArrayList(packages))
                        putExtra("durationMinutes", remainingMinutes)
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(serviceIntent)
                    } else {
                        context.startService(serviceIntent)
                    }
                }
            }
        }
    }

    companion object SaveHelper {
        fun saveActiveSession(
            context: Context,
            blockedPackages: List<String>,
            remainingMinutes: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                putBoolean(KEY_IS_ACTIVE, true)
                putStringSet(KEY_BLOCKED_PACKAGES, blockedPackages.toSet())
                putInt(KEY_REMAINING_MINUTES, remainingMinutes)
                apply()
            }
        }

        fun clearActiveSession(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                putBoolean(KEY_IS_ACTIVE, false)
                remove(KEY_BLOCKED_PACKAGES)
                remove(KEY_REMAINING_MINUTES)
                apply()
            }
        }
    }
}
