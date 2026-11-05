import 'dart:io';

import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Small native integrations missing from the upstream mobile plugins.
class MacOSIntegration {
  static const _channel = MethodChannel('com.hclchcl.pilipala/macos');

  static void initializeWebView() {
    if (Platform.isMacOS) {
      WebViewPlatform.instance = WebKitWebViewPlatform();
    }
  }

  static Future<List<Cookie>> getCookies(String url) async {
    final values = await _channel.invokeListMethod<dynamic>(
      'getCookies',
      {'url': url},
    );
    return (values ?? []).map((value) {
      final data = Map<String, dynamic>.from(value as Map);
      final cookie = Cookie(data['name'] as String, data['value'] as String)
        ..domain = data['domain'] as String
        ..path = data['path'] as String
        ..secure = data['secure'] as bool
        ..httpOnly = data['httpOnly'] as bool;
      final expires = data['expires'] as int?;
      if (expires != null) {
        cookie.expires =
            DateTime.fromMillisecondsSinceEpoch(expires, isUtc: true);
      }
      return cookie;
    }).toList();
  }

  /// Returns null when the user cancels the native save dialog.
  static Future<String?> saveImage(Uint8List bytes, String name) {
    return _channel.invokeMethod<String>('saveImage', {
      'bytes': bytes,
      'name': name,
    });
  }
}
