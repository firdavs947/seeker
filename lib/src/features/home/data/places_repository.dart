import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:seeker/src/core/network/api_client.dart';
import 'package:seeker/src/features/home/model/place.dart';

/// Ошибка получения списка мест с текстом, пригодным для показа пользователю.
class PlaceException implements Exception {
  final String message;

  const PlaceException(this.message);

  @override
  String toString() => message;
}

/// Контракт источника мест.
///
/// Блоки зависят от этой абстракции, а не от Strapi напрямую: это позволяет
/// подменять источник в юнит-тестах без реальных сетевых вызовов.
abstract interface class PlacesRepository {
  Future<List<Place>> fetch();
}

/// Реализация поверх REST API Strapi (коллекция `places`).
class StrapiPlacesRepository implements PlacesRepository {
  const StrapiPlacesRepository();

  static const String _endpoint = '/api/places';

  @override
  Future<List<Place>> fetch() async {
    try {
      final response = await ApiClient.get(
        '$_endpoint?populate=Images&pagination%5BpageSize%5D=100',
      );

      debugPrint('places status: ${response.statusCode}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('places body: ${response.body}');

        if (response.statusCode == 403) {
          throw const PlaceException(
            'No access to places. Allow "find" for this collection in Strapi roles.',
          );
        }
        if (response.statusCode == 404) {
          throw const PlaceException(
            'Collection not found. Check _endpoint in StrapiPlacesRepository.',
          );
        }
        throw PlaceException(
          ApiClient.errorMessage(response, 'Can not load places'),
        );
      }

      final body = json.decode(response.body);
      final raw = body is Map ? body['data'] : body;
      if (raw is! List) return const [];

      final places = <Place>[
        for (final item in raw)
          if (item is Map)
            Place.fromJson(
              Map<String, dynamic>.from(item),
              baseUrl: ApiClient.baseUrl,
            ),
      ].where((p) => p.name.trim().isNotEmpty).toList();

      for (final p in places) {
        debugPrint('place: ${p.name} | images: ${p.images}');
      }
      return places;
    } on SocketException catch (e) {
      debugPrint('places socket error: $e');
      throw PlaceException(ApiClient.networkErrorMessage);
    } on http.ClientException catch (e) {
      debugPrint('places client error: $e');
      throw PlaceException(ApiClient.networkErrorMessage);
    } on TimeoutException {
      throw const PlaceException('Server took too long to respond');
    } on FormatException {
      throw const PlaceException('Unexpected response from the server');
    }
  }
}
