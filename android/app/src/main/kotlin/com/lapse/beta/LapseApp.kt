package com.lapse.beta

import android.content.IntentFilter
import com.lapse.beta.plugin.AlarmReceiver
import io.flutter.app.FlutterApplication

/**
 * Created by Lei Guoting on 2023/8/27.
 */
class LapseApp:FlutterApplication() {
    override fun onCreate() {
        super.onCreate()

        val alarmFilter = IntentFilter("com.lapse.beta.intent.action.ACTION_ALARM")
        registerReceiver(AlarmReceiver(), alarmFilter)
    }
}