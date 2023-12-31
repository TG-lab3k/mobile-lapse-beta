package com.lapse.beta

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
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

        val title = intent.getStringExtra("lapseEvent_title")
        val description = intent.getStringExtra("lapseEvent_description")
        buildNotification(context, title, description)
        Log.d(TAG, "#onReceive# title: $title, description: $description")
    }

    private fun buildNotification(context: Context, title: String?, description: String?) {
        val builder: NotificationCompat.Builder =
            NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)

        builder.setTicker(title)
        builder.setContentText(description)
        builder.setContentTitle(title)
        builder.setSmallIcon(R.mipmap.ic_launcher)
        builder.setDefaults(Notification.DEFAULT_VIBRATE)

        val manager: NotificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            var channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID, "AlarmNotification", NotificationManager.IMPORTANCE_DEFAULT
            )
            if (manager != null) {
                manager.createNotificationChannel(channel)
            }
        }
        try {
            val id = SystemClock.elapsedRealtime().toInt()
            manager.notify(id, builder.build())
            Log.d(TAG, "#buildNotification# notify: $id, $title")
        } catch (ignore: Throwable) {
            Log.e(TAG, "", ignore)
        }
    }

    private fun createNotification(context: Context, title: String, description: String?) {
        Log.d(TAG, "#createNotification# ________  $title")
        createNotificationChannel(context)
        var builder = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher).setContentTitle(title).setContentText(description)
            .setPriority(NotificationCompat.PRIORITY_MAX)
        val notificationId = title.hashCode()
        with(NotificationManagerCompat.from(context)) {
            // notificationId is a unique int for each notification that you must define
            notify(notificationId, builder.build())
        }
    }

    private fun createNotificationChannel(context: Context) {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "AlarmNotification"
            val descriptionText = "Alarm-Notification-test"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(NOTIFICATION_CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            // Register the channel with the system
            val notificationManager: NotificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}