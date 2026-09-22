package com.clg.wechat_open_share

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Environment
import androidx.core.content.FileProvider
import com.tencent.mm.opensdk.modelmsg.SendMessageToWX
import com.tencent.mm.opensdk.modelmsg.WXImageObject
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage
import com.tencent.mm.opensdk.openapi.IWXAPI
import java.io.ByteArrayOutputStream
import java.io.File

/**
 * Image share via path + FileProvider (mirrors kkhc WxShareUtil approach).
 */
internal object ImageShareHelper {
    private const val WECHAT_PACKAGE = "com.tencent.mm"
    private const val WX_FILE_PROVIDER_SUPPORT_API = 0x27000D00
    private const val MAX_THUMB_BYTES = 32 * 1024

    fun shareImage(
        context: Context,
        wxApi: IWXAPI,
        imagePath: String,
        scene: Int,
        title: String?,
        description: String?,
    ): Boolean {
        val source = File(imagePath)
        if (!source.exists()) return false

        val (wxPath, thumbPath) = resolveSharePath(context, wxApi, source)
        val imageObj = WXImageObject().apply { this.imagePath = wxPath }
        val msg = WXMediaMessage(imageObj).apply {
            this.title = title
            this.description = description
            thumbData = compressThumbnail(thumbPath)
        }
        val req = SendMessageToWX.Req().apply {
            transaction = "img_${System.currentTimeMillis()}"
            message = msg
            this.scene = scene
        }
        return wxApi.sendReq(req)
    }

    fun compressThumbnail(imagePath: String): ByteArray {
        return try {
            val bitmap = BitmapFactory.decodeFile(imagePath) ?: return ByteArray(0)
            val size = 150
            val scaled = Bitmap.createScaledBitmap(bitmap, size, size, true)
            if (bitmap !== scaled && !bitmap.isRecycled) {
                bitmap.recycle()
            }
            var quality = 100
            var data: ByteArray
            do {
                val bos = ByteArrayOutputStream()
                scaled.compress(Bitmap.CompressFormat.JPEG, quality, bos)
                data = bos.toByteArray()
                quality -= 10
            } while (data.size > MAX_THUMB_BYTES && quality > 10)
            if (!scaled.isRecycled) scaled.recycle()
            data
        } catch (_: Exception) {
            ByteArray(0)
        }
    }

    private fun resolveSharePath(
        context: Context,
        wxApi: IWXAPI,
        sourceFile: File,
    ): Pair<String, String> {
        val shareFile = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            copyToAppPictures(context, sourceFile) ?: sourceFile
        } else {
            sourceFile
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N &&
            wxApi.wxAppSupportAPI >= WX_FILE_PROVIDER_SUPPORT_API
        ) {
            try {
                val authority = "${context.packageName}.wechat_open_share.fileprovider"
                val uri = FileProvider.getUriForFile(context, authority, shareFile)
                context.grantUriPermission(
                    WECHAT_PACKAGE,
                    uri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION,
                )
                return uri.toString() to shareFile.absolutePath
            } catch (_: Exception) {
                // fall through to absolute path
            }
        }
        return shareFile.absolutePath to shareFile.absolutePath
    }

    private fun copyToAppPictures(context: Context, source: File): File? {
        return try {
            val dir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)
                ?: return null
            if (!dir.exists()) dir.mkdirs()
            val dest = File(dir, "wx_share_${System.currentTimeMillis()}.jpg")
            source.inputStream().use { input ->
                dest.outputStream().use { output -> input.copyTo(output) }
            }
            dest
        } catch (_: Exception) {
            null
        }
    }
}
