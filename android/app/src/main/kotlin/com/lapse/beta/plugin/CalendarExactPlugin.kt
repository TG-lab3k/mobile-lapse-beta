package com.lapse.beta.plugin

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import com.lapse.beta.AlarmReceiver
import com.lapse.beta.LapseBootReceiver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


/**
 * Created by Lei Guoting on 2023/8/20.
 */
internal const val TAG = "CalendarExactPlugin"

class CalendarExactPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var context: Context? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "plugin.calendarAndAlarm")
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        var method = call.method
        if ("createCalendarEvent" == method) {
            var title = call.argument<String>("title")
            var startAt = call.argument<Long>("startAt")
            var endAt = call.argument<Long>("endAt")
            if (title != null && startAt != null && endAt != null) {
                val succeed = createCalendarEvent(
                    title,
                    call.argument("description"),
                    call.argument("location"),
                    startAt,
                    endAt,
                    call.argument("aheadInMinutes"),
                )
                var successValue = 0
                if (succeed) {
                    successValue = 1
                }
                result.success(successValue)
            } else {
                result.success(0)
            }
        } else if ("deleteCalendarEvent" == method) {
            var title = call.argument<String>("title")
            var startAt = call.argument<Long>("startAt")
            if (title != null && startAt != null) {
                // deleteCalendarEvent(title, startAt)
            }
        } else {
            result.notImplemented();
        }
    }


    private fun createCalendarEvent(
        title: String,
        description: String?,
        location: String?,
        startAt: Long,
        endAt: Long,
        aheadInMinutes: Int?
    ): Boolean {
        var cxt: Context? = this.context ?: return false
        Log.d(TAG, "#createCalendarEvent# title: ${title}, startAt: ${startAt}")
        val alarmManager: AlarmManager =
            cxt!!.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(cxt, AlarmReceiver::class.java)
        intent.putExtra("title", title)
        intent.putExtra("description", description)
        val pendingIntent = PendingIntent.getBroadcast(cxt, 0, intent, PendingIntent.FLAG_IMMUTABLE)

        alarmManager.setExact(AlarmManager.RTC_WAKEUP, startAt, pendingIntent)

        //
        launchBootReceiver()
        return true
    }

    private fun launchBootReceiver() {
        var cxt: Context? = this.context ?: return
        val receiver = cxt?.let { ComponentName(it, LapseBootReceiver::class.java) }
        receiver?.let {
            cxt?.packageManager?.setComponentEnabledSetting(
                it, PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP
            )
        }
    }
}