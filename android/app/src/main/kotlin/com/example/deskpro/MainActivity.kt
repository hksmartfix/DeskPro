package com.example.deskpro

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.deskpro/screen_capture"
    private val REQUEST_CODE_SCREEN_CAPTURE = 1000
    private var methodResult: MethodChannel.Result? = null
    private var mediaProjectionManager: MediaProjectionManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startScreenCapture" -> {
                    methodResult = result
                    startScreenCapture()
                }
                "stopScreenCapture" -> {
                    stopScreenCapture()
                    result.success(null)
                }
                "injectMouseEvent" -> {
                    val x = call.argument<Double>("x") ?: 0.0
                    val y = call.argument<Double>("y") ?: 0.0
                    val action = call.argument<String>("action") ?: "move"
                    injectMouseEvent(x, y, action)
                    result.success(null)
                }
                "injectKeyEvent" -> {
                    val keyCode = call.argument<Int>("keyCode") ?: 0
                    val isDown = call.argument<Boolean>("isDown") ?: true
                    injectKeyEvent(keyCode, isDown)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startScreenCapture() {
        val captureIntent = mediaProjectionManager?.createScreenCaptureIntent()
        startActivityForResult(captureIntent, REQUEST_CODE_SCREEN_CAPTURE)
    }

    private fun stopScreenCapture() {
        // Stop screen capture implementation
        // This will be handled by the MediaProjection instance
    }

    private fun injectMouseEvent(x: Double, y: Double, action: String) {
        // Note: Android requires accessibility service for input injection
        // This is a placeholder for the actual implementation
        // You would need to implement an AccessibilityService for this to work
        println("Mouse event: $action at ($x, $y)")
    }

    private fun injectKeyEvent(keyCode: Int, isDown: Boolean) {
        // Note: Android requires accessibility service for input injection
        // This is a placeholder for the actual implementation
        println("Key event: $keyCode, down: $isDown")
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_SCREEN_CAPTURE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                methodResult?.success(true)
            } else {
                methodResult?.error("PERMISSION_DENIED", "Screen capture permission denied", null)
            }
            methodResult = null
        }
    }
}
