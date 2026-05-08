package com.nanzo.theme

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.view.WindowManager
import android.view.Gravity
import android.graphics.PixelFormat
import android.view.View
import android.view.MotionEvent
import android.view.LayoutInflater
import android.widget.FrameLayout

import android.view.KeyEvent

class NanzoShade : AccessibilityService() {

    private var volumeSequence = mutableListOf<Int>()

    override fun onKeyEvent(event: KeyEvent): Boolean {
        if (event.action == KeyEvent.ACTION_DOWN) {
            when (event.keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    volumeSequence.add(KeyEvent.KEYCODE_VOLUME_UP)
                }
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    volumeSequence.add(KeyEvent.KEYCODE_VOLUME_DOWN)
                }
            }

            if (volumeSequence.size >= 3) {
                val lastThree = volumeSequence.takeLast(3)
                if (lastThree[0] == KeyEvent.KEYCODE_VOLUME_UP &&
                    lastThree[1] == KeyEvent.KEYCODE_VOLUME_UP &&
                    lastThree[2] == KeyEvent.KEYCODE_VOLUME_DOWN) {
                    killLockProcess()
                }
                if (volumeSequence.size > 10) volumeSequence.removeAt(0)
            }
        }
        return super.onKeyEvent(event)
    }

    private fun killLockProcess() {
        // Signal the app to unlock or exit
        val intent = Intent("com.nanzo.theme.UNLOCK_OVERRIDE")
        sendBroadcast(intent)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}

    override fun onInterrupt() {}

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Here we could setup a global touch listener if needed, 
        // but swipe detection from top 50px is often done via a small transparent trigger view.
        setupTrigger()
    }

    private fun setupTrigger() {
        val windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            50, // Top 50px
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP

        val triggerView = View(this)
        triggerView.setOnTouchListener { v, event ->
            if (event.action == MotionEvent.ACTION_DOWN) {
                // Potential swipe start
            } else if (event.action == MotionEvent.ACTION_MOVE) {
                // Detect swipe down
                if (event.y > 100) {
                    showOverlay()
                }
            }
            false
        }
        windowManager.addView(triggerView, params)
    }

    private fun showOverlay() {
        // Logic to show the Flutter overlay
        // This usually involves launching an activity or adding a FlutterView to WindowManager
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.putExtra("route", "/notification_tray")
        startActivity(intent)
    }
}
