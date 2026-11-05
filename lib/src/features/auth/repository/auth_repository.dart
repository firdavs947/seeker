import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:seeker/src/core/network/api_client.dart';
import 'package:seeker/src/core/network/token_storage.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  static Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiClient.baseUrl}/api/auth/local/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'username': username,
              'password': password,
            }),
          )
          .timeout(ApiClient.timeout);

      debugPrint('register status: ${response.statusCode}');
      debugPrint('register body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException(
          ApiClient.errorMessage(response, 'Registration failed'),
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final jwt = data['jwt'] as String?;

      // Если в Strapi включено подтверждение почты, jwt не приходит
      if (jwt == null) {
        throw const AuthException(
          'Account created. Please confirm your email, then sign in.',
        );
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
      debugPrint('register socket error: $e');
      throw AuthException(ApiClient.networkErrorMessage);
    } on http.ClientException catch (e) {
      debugPrint('register client error: $e');
      throw AuthException(ApiClient.networkErrorMessage);
    } on TimeoutException {
      throw const AuthException('Server took too long to respond');
    }
  }
}


