package com.lapse.beta

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.lapse.beta.plugin.TAG


/**
 * Created by Lei Guoting on 2023/8/20.
 */
private const val NOTIFICATION_CHANNEL_ID = "lapse_alarm_notification"

class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent == null || context == null) {
            return
        }

        val title = intent.getStringExtra("title")
        val description = intent.getStringExtra("description")
        buildNotification(context, title, description)
        Log.d(TAG, "#onReceive# title: ${title}")
    }

    private fun buildNotification(context: Context, title: String?, description: String?) {
        val builder: NotificationCompat.Builder =
            NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)

        builder.setTicker(title)
        builder.setContentText(description)

        val manager: NotificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            var channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID, "Channel", NotificationManager.IMPORTANCE_DEFAULT
            )
            if (manager != null) {
                manager.createNotificationChannel(channel)
            }
        }
        manager.notify(1, builder.build())
    }
}