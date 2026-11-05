import Cocoa
import FlutterMacOS
import WebKit

class MainFlutterWindow: NSWindow {
  private var integrationChannel: FlutterMethodChannel?
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    self.minSize = NSSize(width: 800, height: 600)
    self.setContentSize(NSSize(width: 1180, height: 760))
    self.center()

    let channel = FlutterMethodChannel(
      name: "com.hclchcl.pilipala/macos",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    integrationChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      let args = call.arguments as? [String: Any] ?? [:]
      switch call.method {
      case "getCookies":
        guard let rawURL = args["url"] as? String,
              let url = URL(string: rawURL), let host = url.host else {
          result(FlutterError(code: "invalid_url", message: "Invalid URL", details: nil))
          return
        }
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
          let values: [[String: Any]] = cookies.filter { cookie in
            let domain = cookie.domain.hasPrefix(".")
              ? String(cookie.domain.dropFirst()) : cookie.domain
            let domainMatches = host == domain ||
              (cookie.domain.hasPrefix(".") && host.hasSuffix("." + domain))
            let path = url.path.isEmpty ? "/" : url.path
            let pathMatches = path == cookie.path ||
              (path.hasPrefix(cookie.path) &&
               (cookie.path.hasSuffix("/") || path.dropFirst(cookie.path.count).hasPrefix("/")))
            return domainMatches && pathMatches && (!cookie.isSecure || url.scheme == "https")
          }.map { cookie in
            var value: [String: Any] = [
              "name": cookie.name, "value": cookie.value,
              "domain": cookie.domain, "path": cookie.path,
              "secure": cookie.isSecure, "httpOnly": cookie.isHTTPOnly
            ]
            if let expires = cookie.expiresDate {
              value["expires"] = Int64(expires.timeIntervalSince1970 * 1000)
            }
            return value
          }
          result(values)
        }
      case "saveImage":
        guard let window = self,
              let bytes = args["bytes"] as? FlutterStandardTypedData,
              let name = args["name"] as? String else {
          result(FlutterError(code: "invalid_image", message: "Missing image", details: nil))
          return
        }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = URL(fileURLWithPath: name).lastPathComponent
        panel.canCreateDirectories = true
        panel.beginSheetModal(for: window) { response in
          guard response == .OK, let url = panel.url else {
            result(nil)
            return
          }
          do {
            try bytes.data.write(to: url, options: .atomic)
            result(url.path)
          } catch {
            result(FlutterError(code: "save_failed", message: error.localizedDescription, details: nil))
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}
