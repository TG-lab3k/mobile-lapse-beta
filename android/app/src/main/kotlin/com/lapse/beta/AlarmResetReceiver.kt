package com.lapse.beta

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.lapse.beta.plugin.TAG

class AlarmResetReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        intent?.action?.let {
            Log.d(TAG, "AlarmResetReceiver@onReceive action: $it")
        }
    }
}