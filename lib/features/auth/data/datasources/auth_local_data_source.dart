import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearTokens();
  Future<void> clearUser();
  Future<void> clearAll();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    try {
      await secureStorage.write(key: _accessTokenKey, value: accessToken);
      await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw CacheException('Failed to save tokens: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await secureStorage.write(key: _userKey, value: userJson);
    } catch (e) {
      throw CacheException('Failed to save user data: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userString = await secureStorage.read(key: _userKey);
      if (userString == null || userString.isEmpty) {
        return null;
      }
      final userMap = jsonDecode(userString) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException('Failed to get user data: $e');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await secureStorage.delete(key: _accessTokenKey);
      await secureStorage.delete(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException('Failed to clear tokens: $e');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await secureStorage.delete(key: _userKey);
    } catch (e) {
      throw CacheException('Failed to clear user data: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    await clearTokens();
    await clearUser();
  }

  @override
  Future<String?> getAccessToken() async {
    return secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return secureStorage.read(key: _refreshTokenKey);
  }
}
