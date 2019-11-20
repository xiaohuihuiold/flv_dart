package com.example.example

import android.graphics.BitmapFactory
import android.media.MediaCodec
import android.os.Bundle
import android.view.Surface

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant
import javax.swing.UIManager.put
import android.text.method.TextKeyListener.clear
import android.graphics.SurfaceTexture


class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        TestPlugin.registerWith(registrarFor("com.test.flv"))
        GeneratedPluginRegistrant.registerWith(this)
    }
}

class TestPlugin(private val registrar: PluginRegistry.Registrar, private val channel: MethodChannel) : MethodChannel.MethodCallHandler {

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "com.test.flv")
            channel.setMethodCallHandler(TestPlugin(registrar, channel))
        }
    }

    val mediaCodec = MediaCodec.createDecoderByType("video/avc")

    override fun onMethodCall(p0: MethodCall, p1: MethodChannel.Result) {
        when (p0.method) {
            "parse" -> {

            }
            else -> {
                p1.notImplemented()
            }
        }
    }

    fun onFrame(byteArray: ByteArray, offset: Int, length: Int) {
        val mSurfaceTexture = SurfaceTexture(0)
        val mSurface = Surface(mSurfaceTexture)
        val inputBuffers = mediaCodec.inputBuffers
        val inputBufferIndex = mediaCodec.dequeueInputBuffer(-1)
        if (inputBufferIndex >= 0) {
            val inputBuffer = inputBuffers[inputBufferIndex]
            inputBuffer.clear()
            inputBuffer.put(byteArray, offset, length)
            mediaCodec.queueInputBuffer(inputBufferIndex, 0, length, 1000000 / 23, 0)
        }

        val bufferInfo = MediaCodec.BufferInfo()
        var outputBufferIndex = mediaCodec.dequeueOutputBuffer(bufferInfo, 0)
        while (outputBufferIndex >= 0) {
            mediaCodec.releaseOutputBuffer(outputBufferIndex, true)
            outputBufferIndex = mediaCodec.dequeueOutputBuffer(bufferInfo, 0)
        }
        mSurface.release()
        mSurfaceTexture.release()
    }

}