import 'package:seeker/src/features/profile/repo/profile_repository.dart';

/// Контракт источника профиля пользователя.
///
/// Блок зависит от абстракции, а не от Strapi напрямую: в юнит-тестах
/// сетевые вызовы полностью подменяются моком.
abstract interface class ProfileService {
  Future<UserProfile> fetch();
}

/// Реализация поверх существующего [ProfileRepository].
class StrapiProfileService implements ProfileService {
  const StrapiProfileService();

  @override
  Future<UserProfile> fetch() => ProfileRepository.get();
}
