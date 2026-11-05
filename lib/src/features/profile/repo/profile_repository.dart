import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:seeker/src/core/network/api_client.dart';

class UserProfile extends Equatable {
  final String username;
  final String email;
  final DateTime? createdAt;

  const UserProfile({
    required this.username,
    required this.email,
    this.createdAt,
  });

  @override
  List<Object?> get props => [username, email, createdAt];

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString())
          ?.toLocal(),
    );
  }
}

class ProfileException implements Exception {
  final String message;

  const ProfileException(this.message);

  @override
  String toString() => message;
}

class ProfileRepository {
  static Future<UserProfile> get() async {
    try {
      final response = await ApiClient.get('/api/users/me');

      debugPrint('profile status: ${response.statusCode}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('profile body: ${response.body}');
        throw ProfileException(
          ApiClient.errorMessage(response, 'Can not load profile'),
        );
      }

      final data = json.decode(response.body);
      if (data is! Map) {
        throw const ProfileException('Unexpected response from the server');
      }

      return UserProfile.fromJson(Map<String, dynamic>.from(data));
    } on SocketException catch (e) {
      debugPrint('profile socket error: $e');
      throw ProfileException(ApiClient.networkErrorMessage);
    } on http.ClientException catch (e) {
      debugPrint('profile client error: $e');
      throw ProfileException(ApiClient.networkErrorMessage);
    } on TimeoutException {
      throw const ProfileException('Server took too long to respond');
    } on FormatException {
      throw const ProfileException('Unexpected response from the server');
    }
  }
}
