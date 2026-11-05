import 'package:pilipala/http/constants.dart';
import 'package:pilipala/http/init.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'dart:io';
import 'package:pilipala/utils/macos_integration.dart';

class SetCookie {
  static onSet() async {
    var cookies = await _getCookies(HttpString.baseUrl);
    await Request.cookieManager.cookieJar
        .saveFromResponse(Uri.parse(HttpString.baseUrl), cookies);
    var cookieString =
        cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    if (cookieString.isNotEmpty) {
      Request.dio.options.headers['cookie'] = cookieString;
    }

    cookies = await _getCookies(HttpString.apiBaseUrl);
    await Request.cookieManager.cookieJar
        .saveFromResponse(Uri.parse(HttpString.apiBaseUrl), cookies);

    cookies = await _getCookies(HttpString.tUrl);
    await Request.cookieManager.cookieJar
        .saveFromResponse(Uri.parse(HttpString.tUrl), cookies);
  }

  static Future<List<Cookie>> _getCookies(String url) {
    if (Platform.isMacOS) return MacOSIntegration.getCookies(url);
    return WebviewCookieManager().getCookies(url);
  }
}
