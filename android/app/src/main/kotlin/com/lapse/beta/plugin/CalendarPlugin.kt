package com.lapse.beta.plugin

import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.graphics.Color
import android.net.Uri
import android.provider.CalendarContract
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class CalendarPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private val TAG = "CalendarPlugin";
    private val CALENDAR_NAME = "LapseTodo"
    private val CALENDAR_ACCOUNT_NAME = "todo@lapse.com"
    private val CALENDAR_ACCOUNT_TYPE = "com.lapse.beta"
    private val CALENDAR_DISPLAY_NAME = "Lapse.Todo"
    private val CALENDAR_APP_PACKAGE = "com.lapse.beta"
    private val CALENDAR_APP_URI = "lapse://app.lapse.com"

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
        } else if ("deleteCalendarEvent" == method) {
            var title = call.argument<String>("title")
            var startAt = call.argument<Long>("startAt")
            if (title != null && startAt != null) {
                deleteCalendarEvent(title, startAt)
            }
        } else {
            result.notImplemented();
        }
    }

    private fun deleteCalendarEvent(title: String, startAt: Long): Boolean {
        var cxt = this.context ?: return false
        val calendarId = checkCalendarAccounts(cxt)
        if (calendarId == -1) {
            return false
        }
        val projection = arrayOf(
            CalendarContract.Events._ID,
            CalendarContract.Events.TITLE,
            CalendarContract.Events.CALENDAR_ID,
        )

        val selection =
            "((${CalendarContract.Events.CALENDAR_ID} = ?) AND (${CalendarContract.Events.TITLE} = ?) AND (${CalendarContract.Events.DTSTART} = ?))"
        val selectionArgs = arrayOf(calendarId.toString(), title, startAt.toString())
        val eventCursor: Cursor = cxt.contentResolver.query(
            CalendarContract.Events.CONTENT_URI, projection, selection, selectionArgs, null
        ) ?: return false

        val eventId = eventCursor.use { cursor ->
            val count: Int = cursor.count
            if (count > 0) {
                cursor.moveToNext()
                var idIndex = cursor.getColumnIndex(CalendarContract.Events._ID)
                cursor.getInt(idIndex)
            } else {
                -1
            }
        }

        if (eventId == -1) {
            return false
        }

        cxt.contentResolver.delete(
            CalendarContract.Reminders.CONTENT_URI,
            "(${CalendarContract.Reminders.EVENT_ID} = ?)",
            arrayOf(eventId.toString())
        )

        var eventCount = cxt.contentResolver.delete(
            CalendarContract.Events.CONTENT_URI,
            "(${CalendarContract.Events._ID} = ?)",
            arrayOf(eventId.toString())
        )
        return eventCount == 1
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
        event.put(CalendarContract.Events.CUSTOM_APP_PACKAGE, CALENDAR_APP_PACKAGE)
        event.put(CalendarContract.Events.CUSTOM_APP_URI, CALENDAR_APP_URI)
        event.put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
        event.put(CalendarContract.Events.EVENT_END_TIMEZONE, TimeZone.getDefault().id)
        val eventSyncUri = asSyncAdapter(CalendarContract.Events.CONTENT_URI)
        var eventUri = cxt.contentResolver.insert(eventSyncUri, event)
        var eventId = eventUri?.let {
            ContentUris.parseId(eventUri)
        }

        //提醒事件
        var alertUri = eventId?.let {
            val values = ContentValues()
            values.put(CalendarContract.Reminders.EVENT_ID, it)

            var remindMinutes = aheadInMinutes ?: 0
            values.put(CalendarContract.Reminders.MINUTES, remindMinutes)
            values.put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_ALERT)
            val remindersSyncUri = asSyncAdapter(CalendarContract.Reminders.CONTENT_URI)
            cxt.contentResolver.insert(remindersSyncUri, values)

            //alarm
            if ("Xiaomi" == android.os.Build.MANUFACTURER) {
                println("$TAG @insertCalendarEvent _________ MANUFACTURER:Xiaomi, title: $title")
                val alarmValues = ContentValues()
                alarmValues.put(CalendarContract.ExtendedProperties.EVENT_ID, eventId)
                alarmValues.put(CalendarContract.ExtendedProperties.NAME, "need_alarm")
                alarmValues.put(CalendarContract.ExtendedProperties.VALUE, true)
                val extPropSyncUri = asSyncAdapter(CalendarContract.ExtendedProperties.CONTENT_URI)
                cxt.contentResolver.insert(
                    extPropSyncUri, alarmValues
                )
            }
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
        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.ACCOUNT_NAME,
            CalendarContract.Calendars.ACCOUNT_TYPE
        )

        val selection =
            "((${CalendarContract.Calendars.ACCOUNT_NAME} = ?) AND (" + "${CalendarContract.Calendars.ACCOUNT_TYPE} = ?))"
        val selectionArgs: Array<String> = arrayOf(CALENDAR_ACCOUNT_NAME, CALENDAR_ACCOUNT_TYPE)
        val userCursor: Cursor = context.contentResolver.query(
            CalendarContract.Calendars.CONTENT_URI, projection, selection, selectionArgs, null
        ) ?: return -1

        return userCursor.use { userCursor ->
            val count: Int = userCursor.count
            if (count > 0) {
                userCursor.moveToNext()
                var idIndex = userCursor.getColumnIndex(CalendarContract.Calendars._ID)
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
        value.put(CalendarContract.Calendars.CALENDAR_COLOR, Color.RED)
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

    fun asSyncAdapter(uri: Uri): Uri {
        return uri.buildUpon().appendQueryParameter(CalendarContract.CALLER_IS_SYNCADAPTER, "true")
            .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_NAME, CALENDAR_ACCOUNT_NAME)
            .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_TYPE, CALENDAR_ACCOUNT_TYPE)
            .build()
    }

}