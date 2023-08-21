package com.lapse.beta.plugin

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.AlarmManagerCompat
import com.lapse.beta.AlarmReceiver
import com.lapse.beta.LapseBootReceiver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.time.ZoneId
import java.util.*


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
        Log.d(TAG, "#createCalendarEvent# title: $title, startAt: $startAt")
        val alarmManager: AlarmManager =
            cxt!!.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent("lapse.intent.action.TIMER")
        intent.putExtra("title", title)
        intent.putExtra("description", description)
        val pendingIntent = PendingIntent.getBroadcast(cxt, 1, intent, PendingIntent.FLAG_UPDATE_CURRENT)

        var tone = TimeZone.getDefault()
        val calendar = Calendar.getInstance(tone)
        calendar.timeInMillis = startAt

        val newCalendar = Calendar.getInstance(tone)
        newCalendar.set(Calendar.YEAR, calendar.get(Calendar.YEAR))
        newCalendar.set(Calendar.MONTH, calendar.get(Calendar.MONTH))
        newCalendar.set(Calendar.DAY_OF_MONTH, calendar.get(Calendar.DAY_OF_MONTH))
        newCalendar.set(Calendar.HOUR_OF_DAY, calendar.get(Calendar.HOUR_OF_DAY))
        newCalendar.set(Calendar.MINUTE, calendar.get(Calendar.MINUTE))
        newCalendar.set(Calendar.SECOND, 0)

        /*
        AlarmManagerCompat.setExactAndAllowWhileIdle(
            alarmManager,
            AlarmManager.RTC_WAKEUP,
            newCalendar.timeInMillis,
            pendingIntent
        )
        */
        AlarmManagerCompat.setAlarmClock(
            alarmManager, newCalendar.timeInMillis, pendingIntent, pendingIntent
        )
        val format = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSSZ")
        val date = Date(newCalendar.timeInMillis)
        Log.d(TAG, "#createCalendarEvent# setExact END, triggerAt: ${format.format(date)}")

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