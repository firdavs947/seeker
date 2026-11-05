import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:seeker/src/core/network/token_storage.dart';

class ApiClient {
  /// Переопределение адреса сервера (например, для запуска на реальном
  /// устройстве). Пусто — адрес выбирается автоматически по платформе.
  static const String _customBaseUrl = '';

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) return _customBaseUrl;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:1337';
    return 'http://localhost:1337';
  }

  static const timeout = Duration(seconds: 15);

  /// Сообщение для пользователя, когда сервер недоступен.
  /// В debug-сборке добавляет адрес, чтобы сразу было видно, куда стучимся.
  static String get networkErrorMessage => kDebugMode
      ? "Can't reach the server ($baseUrl). Is Strapi running?"
      : "Can't reach the server. Check your internet connection.";

  /// Достаёт текст ошибки из ответа Strapi.
  static String errorMessage(http.Response response, String fallback) {
    try {
      final data = json.decode(response.body);
      final message = data['error']?['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    } catch (_) {}
    return '$fallback (${response.statusCode})';
  }

  static void Function()? onSessionExpired;
  static Future<bool>? _refreshing;

  static Future<http.Response> get(String path) {
    return _send(
      (token) => http.get(Uri.parse('$baseUrl$path'), headers: _headers(token)),
    );
  }

  static Future<http.Response> post(String path, {Object? body}) {
    return _send(
      (token) => http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers(token),
        body: body == null ? null : json.encode(body),
      ),
    );
  }

  static Future<http.Response> put(String path, {Object? body}) {
    return _send(
      (token) => http.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers(token),
        body: body == null ? null : json.encode(body),
      ),
    );
  }

  static Future<http.Response> delete(String path) {
    return _send(
      (token) => http.delete(
        Uri.parse('$baseUrl$path'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
  }

  static Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> _send(
    Future<http.Response> Function(String? token) request,
  ) async {
    final token = await TokenStorage.readAccess();
    final response = await request(token).timeout(timeout);
    if (response.statusCode != 401) return response;

    debugPrint('api 401 body: ${response.body}');

    final refreshed = await _refresh();
    if (!refreshed) return response;

    final newToken = await TokenStorage.readAccess();
    return request(newToken).timeout(timeout);
  }

  static Future<bool> _refresh() {
    return _refreshing ??= _doRefresh()
        .then((ok) async {
          if (!ok) {
            debugPrint('refresh failed: session cleared');
            await TokenStorage.clear();
            onSessionExpired?.call();
          }
          return ok;
        })
        .whenComplete(() => _refreshing = null);
  }

  static Future<bool> _doRefresh() async {
    final refreshToken = await TokenStorage.readRefresh();
    debugPrint('refresh token saved: ${refreshToken != null}');
    if (refreshToken == null) return false;

    final response = await http
        .post(
          Uri.parse('$baseUrl/api/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refreshToken': refreshToken}),
        )
        .timeout(timeout);

    debugPrint('refresh status: ${response.statusCode}');

    if (response.statusCode >= 500) {
      throw http.ClientException('Server error ${response.statusCode}');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) return false;

    final data = json.decode(response.body);
    await TokenStorage.save(
      jwt: data['jwt'],
      refreshToken: data['refreshToken'] ?? refreshToken,
    );
    return true;
  }
}
