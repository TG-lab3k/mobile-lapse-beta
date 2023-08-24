package com.lapse.beta.plugin

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.lapse.beta.R

/**
 * Created by Lei Guoting on 2023/8/23.
 */
private const val CHANNEL_ID = "AlarmNotification"

class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        intent?.let {
            val title = it.getStringExtra("title")
            val description = it.getStringExtra("description")
            Log.d(TAG, "#onReceive# $title, $description")
            context?.let { cxt ->
                title?.let { title ->
                    createNotification(cxt, title, description)
                }
            }
        }
    }

    private fun createNotification(context: Context, title: String, description: String?) {
        Log.d(TAG, "#createNotification# ________  $title")
        createNotificationChannel(context)
        var builder =
            NotificationCompat.Builder(context, CHANNEL_ID).setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title).setContentText(description)
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
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            // Register the channel with the system
            val notificationManager: NotificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}