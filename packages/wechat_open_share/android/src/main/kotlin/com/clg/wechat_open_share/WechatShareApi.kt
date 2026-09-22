package com.clg.wechat_open_share

import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage
import com.tencent.mm.opensdk.modelmsg.WXTextObject
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import android.content.Context
import android.content.Intent

/**
 * Holds the official [IWXAPI] instance and share helpers.
 * Host app's `{applicationId}.wxapi.WXEntryActivity` must forward intents here.
 */
object WechatShareApi {
    @Volatile
    private var api: IWXAPI? = null

    @Volatile
    var responseListener: ((type: String, errCode: Int, errStr: String?) -> Unit)? = null

    fun register(context: Context, appId: String): Boolean {
        val created = WXAPIFactory.createWXAPI(context.applicationContext, appId, true)
        val ok = created.registerApp(appId)
        api = created
        return ok
    }

    fun isInstalled(): Boolean = api?.isWXAppInstalled == true

    fun apiOrNull(): IWXAPI? = api

    fun handleIntent(intent: Intent?, handler: IWXAPIEventHandler): Boolean {
        val wx = api ?: return false
        return wx.handleIntent(intent, handler)
    }

    fun onResp(resp: BaseResp) {
        val type = when (resp.type) {
            com.tencent.mm.opensdk.constants.ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX -> "share"
            com.tencent.mm.opensdk.constants.ConstantsAPI.COMMAND_SENDAUTH -> "auth"
            else -> "unknown"
        }
        responseListener?.invoke(type, resp.errCode, resp.errStr)
    }

    @Suppress("UNUSED_PARAMETER")
    fun onReq(req: BaseReq?) {
        // Host may extend for open-tag / launch; share-only plugin ignores.
    }

    fun shareImage(
        context: Context,
        imagePath: String,
        scene: Int,
        title: String?,
        description: String?,
    ): Boolean {
        val wx = api ?: return false
        if (!wx.isWXAppInstalled) return false
        return ImageShareHelper.shareImage(context, wx, imagePath, scene, title, description)
    }

    fun shareText(text: String, scene: Int): Boolean {
        val wx = api ?: return false
        if (!wx.isWXAppInstalled) return false
        val obj = WXTextObject().apply { this.text = text }
        val msg = WXMediaMessage(obj).apply {
            this.description = text.take(1024)
        }
        val req = SendMessageToWX.Req().apply {
            transaction = "text_${System.currentTimeMillis()}"
            message = msg
            this.scene = scene
        }
        return wx.sendReq(req)
    }

    fun shareWebpage(
        context: Context,
        url: String,
        scene: Int,
        title: String?,
        description: String?,
        thumbPath: String?,
    ): Boolean {
        val wx = api ?: return false
        if (!wx.isWXAppInstalled) return false
        val webpage = WXWebpageObject().apply { webpageUrl = url }
        val msg = WXMediaMessage(webpage).apply {
            this.title = title ?: ""
            this.description = description ?: ""
            if (!thumbPath.isNullOrBlank()) {
                thumbData = ImageShareHelper.compressThumbnail(thumbPath)
            }
        }
        val req = SendMessageToWX.Req().apply {
            transaction = "web_${System.currentTimeMillis()}"
            message = msg
            this.scene = scene
        }
        return wx.sendReq(req)
    }

    fun sceneFrom(name: String?): Int = when (name) {
        "timeline" -> SendMessageToWX.Req.WXSceneTimeline
        else -> SendMessageToWX.Req.WXSceneSession
    }
}
