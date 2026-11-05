import 'package:flutter/material.dart';

/// Место из Strapi. Поля совпадают с твоей коллекцией:
/// Name, ShortHistory, WorkTime, LocationLink, Images, Category.
class Place {
  final String id; // documentId (Strapi 5) или id
  final String name;
  final String category;
  final String shortHistory;
  final String workTime;
  final String locationLink;
  final List<String> images; // готовые ссылки

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.shortHistory,
    required this.workTime,
    required this.locationLink,
    this.images = const [],
  });

  /// Иконка по названию категории (подбирается по ключевым словам)
  IconData get icon => categoryIcon(category);

  /// Градиент-заглушка, пока нет фото (стабильный для одного названия)
  List<Color> get colors {
    final sum = name.codeUnits.fold<int>(0, (a, b) => a + b);
    return _palettes[sum % _palettes.length];
  }

  /// Принимает и Strapi 5 (плоский ответ), и Strapi 4 (attributes).
  /// [baseUrl] нужен, чтобы превратить /uploads/... в полную ссылку.
  factory Place.fromJson(Map<String, dynamic> json, {required String baseUrl}) {
    final a = json['attributes'] is Map
        ? Map<String, dynamic>.from(json['attributes'] as Map)
        : json;

    return Place(
      id: (json['documentId'] ?? json['id'] ?? '').toString(),
      name: (a['Name'] ?? '').toString(),
      category: (a['Category'] ?? '').toString(),
      shortHistory: _blocksToText(a['ShortHistory']),
      workTime: (a['WorkTime'] ?? '').toString(),
      locationLink: (a['LocationLink'] ?? '').toString(),
      images: _imageUrls(a['Images'], baseUrl),
    );
  }

  /// Для кеша (Hive): ссылки на фото уже полные
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'shortHistory': shortHistory,
    'workTime': workTime,
    'locationLink': locationLink,
    'images': images,
  };

  factory Place.fromCache(Map<String, dynamic> json) => Place(
    id: (json['id'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    category: (json['category'] ?? '').toString(),
    shortHistory: (json['shortHistory'] ?? '').toString(),
    workTime: (json['workTime'] ?? '').toString(),
    locationLink: (json['locationLink'] ?? '').toString(),
    images: [
      for (final i in (json['images'] as List? ?? const [])) i.toString(),
    ],
  );

  static List<String> _imageUrls(dynamic raw, String baseUrl) {
    dynamic list = raw;
    if (list is Map && list['data'] is List) list = list['data']; // Strapi 4
    if (list is! List) return const [];

    final out = <String>[];
    for (final m in list) {
      if (m is! Map) continue;
      final attrs = m['attributes'] is Map ? m['attributes'] as Map : m;
      final url = attrs['url']?.toString();
      if (url == null || url.isEmpty) continue;
      out.add(
        url.startsWith('http')
            ? url.replaceFirst(
                RegExp(r'^https?://(localhost|127\.0\.0\.1)(:\d+)?'),
                baseUrl,
              )
            : '$baseUrl$url',
      );
    }
    return out;
  }

  /// Rich text (Blocks) -> обычный текст с абзацами.
  static String _blocksToText(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw.trim();
    if (raw is! List) return '';

    final parts = <String>[];
    for (final b in raw) {
      if (b is! Map) continue;
      final children = b['children'];

      if (b['type'] == 'list' && children is List) {
        final items = [
          for (final li in children)
            if (li is Map) '• ${_inline(li['children'])}',
        ];
        parts.add(items.join('\n'));
      } else {
        final t = _inline(children).trim();
        if (t.isNotEmpty) parts.add(t);
      }
    }
    return parts.join('\n\n');
  }

  static String _inline(dynamic children) {
    if (children is! List) return '';
    final sb = StringBuffer();
    for (final c in children) {
      if (c is! Map) continue;
      if (c['type'] == 'text') {
        sb.write(c['text'] ?? '');
      } else {
        sb.write(_inline(c['children']));
      }
    }
    return sb.toString();
  }
}

const List<List<Color>> _palettes = [
  [Color(0xFF29B6F6), Color(0xFF26C6DA), Color(0xFFE6D3A8)],
  [Color(0xFF5E35B1), Color(0xFFE57373), Color(0xFFFFB74D)],
  [Color(0xFF00BCD4), Color(0xFF00ACC1), Color(0xFF00796B)],
  [Color(0xFF2E7D32), Color(0xFF00838F), Color(0xFF1565C0)],
  [Color(0xFF4FC3F7), Color(0xFF26A69A), Color(0xFF004D40)],
  [Color(0xFF66BB6A), Color(0xFF2E7D32), Color(0xFF1B5E20)],
];

/// Иконка по названию категории из Strapi (регистр не важен).
IconData categoryIcon(String category) {
  final c = category.toLowerCase();
  bool has(List<String> keys) => keys.any(c.contains);

  if (has(['all'])) return Icons.apps_rounded;
  if (has(['beach', 'sea', 'coast'])) return Icons.beach_access_rounded;
  if (has(['island'])) return Icons.directions_boat_rounded;
  if (has(['forest', 'park', 'nature', 'garden'])) return Icons.park_rounded;
  if (has(['mountain', 'hill', 'hike', 'volcano'])) {
    return Icons.terrain_rounded;
  }
  if (has(['lake', 'river', 'water', 'waterfall'])) return Icons.waves_rounded;
  if (has([
    'museum',
    'history',
    'temple',
    'church',
    'mosque',
    'monument',
    'castle',
    'palace',
  ])) {
    return Icons.account_balance_rounded;
  }
  if (has(['food', 'restaurant', 'cafe', 'bar'])) {
    return Icons.restaurant_rounded;
  }
  if (has(['hotel', 'hostel', 'stay'])) return Icons.hotel_rounded;
  if (has(['shop', 'market', 'mall', 'bazaar'])) {
    return Icons.storefront_rounded;
  }
  if (has(['city', 'town', 'street'])) return Icons.location_city_rounded;
  return Icons.place_rounded;
}

/// Демо-данные для главного экрана, пока API недоступен.
const List<Place> kPlaces = [
  Place(
    id: 'pak_meng',
    name: 'Pak Meng Beach',
    category: 'Beach',
    workTime: 'Open daily, 06:00 – 20:00',
    locationLink:
        'https://www.google.com/maps/search/?api=1&query=Pak+Meng+Beach',
    shortHistory:
        'A long, quiet beach with soft sand and shallow water, perfect for '
        'slow walks at sunrise.\n\nLocal restaurants line the shore and serve '
        'the catch of the day.',
  ),
  Place(
    id: 'doi_inthanon',
    name: 'Doi Inthanon',
    category: 'Mountain',
    workTime: 'Daily, 05:30 – 18:00',
    locationLink:
        'https://www.google.com/maps/search/?api=1&query=Doi+Inthanon',
    shortHistory:
        'The highest mountain in the country, wrapped in clouds and green '
        'forest.\n\nMisty trails, waterfalls and cool air make it a great '
        'escape from the heat.',
  ),
  Place(
    id: 'koh_mook',
    name: 'Koh Mook',
    category: 'Island',
    workTime: 'Boats run 08:00 – 17:00',
    locationLink: 'https://www.google.com/maps/search/?api=1&query=Koh+Mook',
    shortHistory:
        'A peaceful island that feels like a private one. Villagers live '
        'here with a simple way of life.\n\nMost visitors come for Farang '
        'Beach and Sabai Beach.',
  ),
  Place(
    id: 'koh_lao_liang',
    name: 'Koh Lao Liang',
    category: 'Island',
    workTime: 'Tours 09:00 – 16:00',
    locationLink:
        'https://www.google.com/maps/search/?api=1&query=Koh+Lao+Liang',
    shortHistory:
        'Rocky green hills fall straight into deep blue water. Boats stop '
        'here for snorkelling over bright coral.',
  ),
  Place(
    id: 'phi_phi',
    name: 'Phi Phi Islands',
    category: 'Beach',
    workTime: 'Daily, 08:00 – 18:00',
    locationLink:
        'https://www.google.com/maps/search/?api=1&query=Phi+Phi+Islands',
    shortHistory:
        'Limestone cliffs, turquoise lagoons and white beaches make this '
        'group of islands one of the most photographed places in the country.',
  ),
  Place(
    id: 'khao_sok',
    name: 'Khao Sok Forest',
    category: 'Forest',
    workTime: 'Daily, 07:00 – 17:00',
    locationLink: 'https://www.google.com/maps/search/?api=1&query=Khao+Sok+National+Park',
    shortHistory:
        'One of the oldest rainforests in the world, with towering '
        'limestone, jungle rivers and a huge lake.',
  ),
];
