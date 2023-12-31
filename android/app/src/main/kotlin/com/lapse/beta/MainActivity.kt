package com.lapse.beta

import android.Manifest
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.lapse.beta.plugin.CalendarExactPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"
    private val REQUEST_CODE_PERMISSION = 0x01

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (ContextCompat.checkSelfPermission(
                context, Manifest.permission.WRITE_CALENDAR
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            var permissions =
                arrayOf(Manifest.permission.WRITE_CALENDAR, Manifest.permission.READ_CALENDAR)
            ActivityCompat.requestPermissions(this, permissions, REQUEST_CODE_PERMISSION)
        }
        checkExactAlarmPermissions()
    }

    private fun checkExactAlarmPermissions() {
        val alarmManager: AlarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {
                val uri = Uri.parse("package:$packageName")
                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, uri)
                startActivity(intent)
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (REQUEST_CODE_PERMISSION == requestCode && grantResults.contains(PackageManager.PERMISSION_DENIED)) {
            //TODO
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            flutterEngine.plugins.add(CalendarExactPlugin())
        } catch (e: Exception) {
            Log.e(
                TAG,
                "Error registering plugin plugin.calendarAndAlarm, com.lapse.beta.plugin.CalendarPlugin",
                e
            )
        }
    }
}
