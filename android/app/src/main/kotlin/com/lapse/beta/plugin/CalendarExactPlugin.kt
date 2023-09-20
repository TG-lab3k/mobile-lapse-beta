package com.lapse.beta.plugin

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log
import androidx.core.app.AlarmManagerCompat
import com.lapse.beta.AlarmReceiver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date


/**
 * Created by Lei Guoting on 2023/8/20.
 */
internal const val TAG = "CalendarExactPlugin"

class CalendarExactPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var context: Context? = null
    private val simpleDateFormat: SimpleDateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS")

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
        val requestCode = SystemClock.elapsedRealtime().toInt()
        Log.d(
            TAG, "#createCalendarEvent# requestCode:$requestCode, title: ${title}, startAt: ${
                simpleDateFormat.format(
                    startAt
                )
            }"
        )
        val alarmManager: AlarmManager =
            cxt!!.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(cxt, AlarmReceiver::class.java)
        intent.putExtra("lapseEvent_title", title)
        intent.putExtra("lapseEvent_description", description)

        val calendar = Calendar.getInstance()
        calendar.timeInMillis = startAt
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)

        val pendingIntent = PendingIntent.getBroadcast(
            cxt, requestCode, intent, PendingIntent.FLAG_IMMUTABLE
        )
        AlarmManagerCompat.setExactAndAllowWhileIdle(
            alarmManager, AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent
        )

        val format = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSSZ")
        val date = Date(calendar.timeInMillis)
        Log.d(TAG, "#createCalendarEvent# setExact END, triggerAt: ${format.format(date)}")
        return true
    }
}