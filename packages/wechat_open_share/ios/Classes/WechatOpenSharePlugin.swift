import Flutter
import UIKit

#if canImport(WechatOpenSDK)
import WechatOpenSDK
#endif

/// iOS bridge to official WeChat OpenSDK.
/// Host app must set Universal Link + URL Scheme (AppId) before register works.
public class WechatOpenSharePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = WechatOpenSharePlugin()
    let method = FlutterMethodChannel(
      name: "com.clg.wechat_open_share/methods",
      binaryMessenger: registrar.messenger()
    )
    method.setMethodCallHandler(instance.handle)
    let events = FlutterEventChannel(
      name: "com.clg.wechat_open_share/events",
      binaryMessenger: registrar.messenger()
    )
    events.setStreamHandler(instance)
    registrar.addApplicationDelegate(instance)
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "register":
      register(call: call, result: result)
    case "isWeChatInstalled":
      #if canImport(WechatOpenSDK)
      result(WXApi.isWXAppInstalled())
      #else
      result(false)
      #endif
    case "shareImage":
      shareImage(call: call, result: result)
    case "shareText":
      shareText(call: call, result: result)
    case "shareWebpage":
      shareWebpage(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func wxScene(_ name: String?) -> Int32 {
    // WXSceneSession = 0, WXSceneTimeline = 1
    return name == "timeline" ? 1 : 0
  }

  private func register(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let appId = args["appId"] as? String, !appId.isEmpty else {
      result(FlutterError(code: "INVALID_ARGS", message: "appId required", details: nil))
      return
    }
    let link = (args["universalLink"] as? String) ?? ""
    #if canImport(WechatOpenSDK)
    let ok = WXApi.registerApp(appId, universalLink: link)
    result(ok)
    #else
    result(
      FlutterError(
        code: "SDK_MISSING",
        message: "WechatOpenSDK pod not linked. Add ios/ and run pod install.",
        details: nil
      )
    )
    #endif
  }

  private func shareImage(call: FlutterMethodCall, result: @escaping FlutterResult) {
    #if canImport(WechatOpenSDK)
    guard let args = call.arguments as? [String: Any],
          let path = args["imagePath"] as? String,
          let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
      result(FlutterError(code: "INVALID_ARGS", message: "imagePath required", details: nil))
      return
    }
    let imageObject = WXImageObject()
    imageObject.imageData = data
    let message = WXMediaMessage()
    message.mediaObject = imageObject
    if let title = args["title"] as? String { message.title = title }
    if let description = args["description"] as? String { message.description = description }
    if let image = UIImage(contentsOfFile: path),
       var thumb = image.jpegData(compressionQuality: 0.5) {
      var q: CGFloat = 0.4
      while thumb.count > 32 * 1024 && q > 0.05 {
        q -= 0.05
        if let next = image.jpegData(compressionQuality: q) { thumb = next }
      }
      message.thumbData = thumb
    }
    let req = SendMessageToWXReq()
    req.bText = false
    req.message = message
    req.scene = wxScene(args["scene"] as? String)
    WXApi.send(req) { ok in result(ok) }
    #else
    result(false)
    #endif
  }

  private func shareText(call: FlutterMethodCall, result: @escaping FlutterResult) {
    #if canImport(WechatOpenSDK)
    guard let args = call.arguments as? [String: Any],
          let text = args["text"] as? String, !text.isEmpty else {
      result(FlutterError(code: "INVALID_ARGS", message: "text required", details: nil))
      return
    }
    let req = SendMessageToWXReq()
    req.bText = true
    req.text = text
    req.scene = wxScene(args["scene"] as? String)
    WXApi.send(req) { ok in result(ok) }
    #else
    result(false)
    #endif
  }

  private func shareWebpage(call: FlutterMethodCall, result: @escaping FlutterResult) {
    #if canImport(WechatOpenSDK)
    guard let args = call.arguments as? [String: Any],
          let url = args["url"] as? String, !url.isEmpty else {
      result(FlutterError(code: "INVALID_ARGS", message: "url required", details: nil))
      return
    }
    let webpage = WXWebpageObject()
    webpage.webpageUrl = url
    let message = WXMediaMessage()
    message.mediaObject = webpage
    message.title = (args["title"] as? String) ?? ""
    message.description = (args["description"] as? String) ?? ""
    if let thumbPath = args["thumbPath"] as? String,
       let thumbData = try? Data(contentsOf: URL(fileURLWithPath: thumbPath)) {
      message.thumbData = thumbData
    }
    let req = SendMessageToWXReq()
    req.bText = false
    req.message = message
    req.scene = wxScene(args["scene"] as? String)
    WXApi.send(req) { ok in result(ok) }
    #else
    result(false)
    #endif
  }
}

#if canImport(WechatOpenSDK)
extension WechatOpenSharePlugin: WXApiDelegate {
  public func onReq(_ req: BaseReq) {}

  public func onResp(_ resp: BaseResp) {
    let type: String
    switch resp {
    case is SendMessageToWXResp: type = "share"
    case is SendAuthResp: type = "auth"
    default: type = "unknown"
    }
    eventSink?([
      "type": type,
      "errCode": resp.errCode,
      "errStr": resp.errStr as Any,
    ])
  }
}
#endif

extension WechatOpenSharePlugin {
  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    #if canImport(WechatOpenSDK)
    return WXApi.handleOpenUniversalLink(userActivity, delegate: self)
    #else
    return false
    #endif
  }

  public func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    #if canImport(WechatOpenSDK)
    return WXApi.handleOpen(url, delegate: self)
    #else
    return false
    #endif
  }
}
