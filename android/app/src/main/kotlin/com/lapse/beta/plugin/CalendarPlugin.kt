package com.lapse.beta.plugin

import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.graphics.Color
import android.provider.CalendarContract
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class CalendarPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private val TAG = "CalendarPlugin";
    private val CALENDAR_NAME = "Lapse"
    private val CALENDAR_ACCOUNT_NAME = "lapse.com"
    private val CALENDAR_ACCOUNT_TYPE = "com.lapse.beta"
    private val CALENDAR_DISPLAY_NAME = "Lapse"

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
        if ("createCalendarEvent" == call.method) {
            var title = call.argument<String>("title")
            var startAt = call.argument<Long>("startAt")
            var endAt = call.argument<Long>("endAt")
            if (title != null && startAt != null && endAt != null) {
                val success = insertCalendarEvent(
                    title,
                    call.argument("description"),
                    call.argument("location"),
                    startAt,
                    endAt,
                    call.argument("aheadInMinutes"),
                )
                result.success(success)
            } else {
                result.success(false)
            }
        } else {
            result.notImplemented();
        }
    }

    private fun insertCalendarEvent(
        title: String,
        description: String?,
        location: String?,
        startAt: Long,
        endAt: Long,
        aheadInMinutes: Int?,
    ): Boolean {
        if (title == null || startAt == null || endAt == null) {
            return false
        }

        var cxt = this.context ?: return false

        val calendarId = checkAndAddCalendarAccounts(cxt)
        if (calendarId == -1) {
            return false
        }
        val event = ContentValues()
        event.put(CalendarContract.Events.TITLE, title)
        description?.let {
            event.put(CalendarContract.Events.DESCRIPTION, it)
        }

        location?.let {
            event.put(CalendarContract.Events.EVENT_LOCATION, it)
        }
        event.put(CalendarContract.Events.CALENDAR_ID, calendarId)
        event.put(CalendarContract.Events.DTSTART, startAt)
        event.put(CalendarContract.Events.DTEND, endAt)
        event.put(CalendarContract.Events.HAS_ALARM, 1)
        event.put(CalendarContract.Events.CUSTOM_APP_PACKAGE, "com.lapse.beta")
        event.put(CalendarContract.Events.CUSTOM_APP_URI, "lapse://app.lapse.com/")
        event.put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
        event.put(CalendarContract.Events.EVENT_END_TIMEZONE, TimeZone.getDefault().id)
        var eventUri = cxt.contentResolver.insert(CalendarContract.Events.CONTENT_URI, event)
        var eventId = eventUri?.let {
            ContentUris.parseId(eventUri)
        }

        Log.d(TAG, "#insertCalendarEvent# eventId: $eventId")

        //提醒事件
        var alertUri = eventId?.let {
            val values = ContentValues()
            values.put(CalendarContract.Reminders.EVENT_ID, it)

            var remindMinutes = aheadInMinutes ?: 0
            values.put(CalendarContract.Reminders.MINUTES, remindMinutes)
            values.put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_DEFAULT)
            cxt.contentResolver.insert(CalendarContract.Reminders.CONTENT_URI, values)
        }
        return alertUri != null
    }


    private fun checkAndAddCalendarAccounts(context: Context): Int {
        val oldId = checkCalendarAccounts(context)
        return if (oldId >= 0) {
            oldId
        } else {
            val addId = addCalendarAccount(context)
            if (addId >= 0) {
                checkCalendarAccounts(context)
            } else {
                -1
            }
        }
    }

    private fun checkCalendarAccounts(context: Context): Int {
        val userCursor: Cursor = context.contentResolver.query(
            CalendarContract.Calendars.CONTENT_URI,
            null,
            null,
            null,
            CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL + " ASC "
        ) ?: return -1

        return userCursor.use { userCursor ->
            val count: Int = userCursor.count
            if (count > 0) {
                userCursor.moveToNext()
                var idIndex = userCursor.getColumnIndex(CalendarContract.Calendars._ID);
                userCursor.getInt(idIndex)
            } else {
                -1
            }
        }
    }

    private fun addCalendarAccount(context: Context): Long {
        val timeZone = TimeZone.getDefault()
        val value = ContentValues()
        value.put(CalendarContract.Calendars.NAME, CALENDAR_NAME)
        value.put(CalendarContract.Calendars.ACCOUNT_NAME, CALENDAR_ACCOUNT_NAME)
        value.put(CalendarContract.Calendars.ACCOUNT_TYPE, CALENDAR_ACCOUNT_TYPE)
        value.put(
            CalendarContract.Calendars.CALENDAR_DISPLAY_NAME, CALENDAR_DISPLAY_NAME
        )
        value.put(CalendarContract.Calendars.VISIBLE, 1)
        value.put(CalendarContract.Calendars.CALENDAR_COLOR, Color.BLUE)
        value.put(
            CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL,
            CalendarContract.Calendars.CAL_ACCESS_OWNER
        )
        value.put(CalendarContract.Calendars.SYNC_EVENTS, 1)
        value.put(CalendarContract.Calendars.CALENDAR_TIME_ZONE, timeZone.id)
        value.put(CalendarContract.Calendars.OWNER_ACCOUNT, CALENDAR_ACCOUNT_NAME)
        value.put(CalendarContract.Calendars.CAN_ORGANIZER_RESPOND, 0)
        var calendarUri = CalendarContract.Calendars.CONTENT_URI
        calendarUri = calendarUri.buildUpon()
            .appendQueryParameter(CalendarContract.CALLER_IS_SYNCADAPTER, "true")
            .appendQueryParameter(
                CalendarContract.Calendars.ACCOUNT_NAME, CALENDAR_ACCOUNT_NAME
            ).appendQueryParameter(
                CalendarContract.Calendars.ACCOUNT_TYPE, CALENDAR_ACCOUNT_TYPE
            ).build()
        val result = context.contentResolver.insert(calendarUri, value)
        return if (result == null) -1 else ContentUris.parseId(result)
    }

}