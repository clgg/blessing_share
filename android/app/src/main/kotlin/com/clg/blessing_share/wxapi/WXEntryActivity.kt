package com.clg.blessing_share.wxapi

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.clg.wechat_open_share.WechatOpenSharePlugin

/**
 * Required by WeChat OpenSDK: must live in `{applicationId}.wxapi.WXEntryActivity`.
 * Forwards the callback intent into the [wechat_open_share] plugin.
 */
class WXEntryActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WechatOpenSharePlugin.handleIntent(this, intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        WechatOpenSharePlugin.handleIntent(this, intent)
    }
}
