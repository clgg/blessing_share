package com.clg.wechat_open_share

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** Flutter plugin: MethodChannel → official WeChat OpenSDK. */
class WechatOpenSharePlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    EventChannel.StreamHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var applicationContext: Context? = null
    private var activity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        methodChannel = MethodChannel(
            binding.binaryMessenger,
            "com.clg.wechat_open_share/methods",
        )
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(
            binding.binaryMessenger,
            "com.clg.wechat_open_share/events",
        )
        eventChannel.setStreamHandler(this)

        WechatShareApi.responseListener = { type, errCode, errStr ->
            eventSink?.success(
                mapOf(
                    "type" to type,
                    "errCode" to errCode,
                    "errStr" to errStr,
                ),
            )
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        WechatShareApi.responseListener = null
        applicationContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val context = applicationContext
        if (context == null) {
            result.error("NO_CONTEXT", "Plugin not attached", null)
            return
        }

        when (call.method) {
            "register" -> {
                val appId = call.argument<String>("appId")
                if (appId.isNullOrBlank()) {
                    result.error("INVALID_ARGS", "appId required", null)
                    return
                }
                result.success(WechatShareApi.register(context, appId))
            }

            "isWeChatInstalled" -> result.success(WechatShareApi.isInstalled())

            "shareImage" -> {
                val path = call.argument<String>("imagePath")
                if (path.isNullOrBlank()) {
                    result.error("INVALID_ARGS", "imagePath required", null)
                    return
                }
                val scene = WechatShareApi.sceneFrom(call.argument("scene"))
                val ok = WechatShareApi.shareImage(
                    context,
                    path,
                    scene,
                    call.argument("title"),
                    call.argument("description"),
                )
                result.success(ok)
            }

            "shareText" -> {
                val text = call.argument<String>("text")
                if (text.isNullOrBlank()) {
                    result.error("INVALID_ARGS", "text required", null)
                    return
                }
                val scene = WechatShareApi.sceneFrom(call.argument("scene"))
                result.success(WechatShareApi.shareText(text, scene))
            }

            "shareWebpage" -> {
                val url = call.argument<String>("url")
                if (url.isNullOrBlank()) {
                    result.error("INVALID_ARGS", "url required", null)
                    return
                }
                val scene = WechatShareApi.sceneFrom(call.argument("scene"))
                result.success(
                    WechatShareApi.shareWebpage(
                        context,
                        url,
                        scene,
                        call.argument("title"),
                        call.argument("description"),
                        call.argument("thumbPath"),
                    ),
                )
            }

            else -> result.notImplemented()
        }
    }

    companion object {
        /**
         * Forward WeChat callback intent from host `{package}.wxapi.WXEntryActivity`.
         */
        @JvmStatic
        fun handleIntent(activity: Activity, intent: Intent?) {
            WechatShareApi.handleIntent(
                intent,
                object : IWXAPIEventHandler {
                    override fun onReq(req: BaseReq?) {
                        WechatShareApi.onReq(req)
                        activity.finish()
                    }

                    override fun onResp(resp: BaseResp) {
                        WechatShareApi.onResp(resp)
                        activity.finish()
                    }
                },
            )
        }
    }
}
