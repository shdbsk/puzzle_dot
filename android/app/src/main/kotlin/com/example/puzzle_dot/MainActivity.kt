package com.example.puzzle_dot

import android.os.Handler
import android.os.Looper
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    private val channel = "com.example.puzzle_dot/python"
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                val imagePath = call.argument<String>("imagePath")

                when (call.method) {
                    "processImage" -> {
                        if (imagePath == null) {
                            result.error("INVALID_ARGUMENT", "imagePath is required", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                val py = Python.getInstance()
                                val module = py.getModule("image_processor")
                                val output = module.callAttr("process_image", imagePath).toString()
                                mainHandler.post { result.success(output) }
                            } catch (e: Exception) {
                                mainHandler.post { result.error("PYTHON_ERROR", e.message, null) }
                            }
                        }
                    }
                    "getImageInfo" -> {
                        if (imagePath == null) {
                            result.error("INVALID_ARGUMENT", "imagePath is required", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                val py = Python.getInstance()
                                val module = py.getModule("image_processor")
                                val output = module.callAttr("get_image_info", imagePath).toString()
                                mainHandler.post { result.success(output) }
                            } catch (e: Exception) {
                                mainHandler.post { result.error("PYTHON_ERROR", e.message, null) }
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
