import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:seeker/src/core/network/api_client.dart';
import 'package:seeker/src/core/network/token_storage.dart';

class SigninExseption implements Exception {
  final String message;

  const SigninExseption(this.message);

  @override
  String toString() => message;
}

class SigninRepository {
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiClient.baseUrl}/api/auth/local'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'identifier': email, 'password': password}),
          )
          .timeout(ApiClient.timeout);

      debugPrint('login status: ${response.statusCode}');
      debugPrint('login body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SigninExseption(
          ApiClient.errorMessage(response, 'Sign in failed'),
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final jwt = data['jwt'] as String?;
      if (jwt == null) {
        throw const SigninExseption('Sign in failed: no token received');
      }

      await TokenStorage.save(
        jwt: jwt,
        refreshToken: data['refreshToken'] as String?,
      );

      final user = data['user'] as Map<String, dynamic>?;
      if (user != null) {
        await TokenStorage.saveUser(
          id: user['id'].toString(),
          documentId: user['documentId']?.toString(),
        );
      }
    } on SocketException catch (e) {
      debugPrint('login socket error: $e');
      throw SigninExseption(ApiClient.networkErrorMessage);
    } on http.ClientException catch (e) {
      debugPrint('login client error: $e');
      throw SigninExseption(ApiClient.networkErrorMessage);
    } on TimeoutException {
      throw const SigninExseption('Server took too long to respond');
    }
  }
}
