import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({required String email, required String password});
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? role,
  });
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  Never _parseDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.error is SocketException ||
        (e.type == DioExceptionType.unknown &&
            e.message != null &&
            e.message!.contains('SocketException'))) {
      throw ServerException('error_connection_failed');
    }

    final response = e.response;
    if (response != null && response.data != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final List<String> extractedMessages = [];

        // NestJS ZodValidationPipe format: data['error']['details'] = { "email": ["Invalid email"] }
        if (data.containsKey('error') && data['error'] is Map<String, dynamic>) {
          final errorObj = data['error'] as Map<String, dynamic>;
          if (errorObj.containsKey('details') && errorObj['details'] is Map<String, dynamic>) {
            final details = errorObj['details'] as Map<String, dynamic>;
            for (var msgs in details.values) {
              if (msgs is List) {
                extractedMessages.addAll(msgs.map((m) => m.toString()));
              } else if (msgs is String) {
                extractedMessages.add(msgs);
              }
            }
          }
        }

        // Standard NestJS Pipe format: data['message'] = ["..."] or "..."
        if (extractedMessages.isEmpty && data.containsKey('message')) {
          final messageData = data['message'];
          if (messageData is List) {
            extractedMessages.addAll(messageData.map((m) => m.toString()));
          } else if (messageData is String && messageData.isNotEmpty) {
            extractedMessages.add(messageData);
          }
        }

        if (extractedMessages.isNotEmpty) {
          final firstMsg = extractedMessages.first;
          final lower = firstMsg.toLowerCase();

          if (lower.contains('email') && (lower.contains('invalid') || lower.contains('format'))) {
            throw AuthException('error_invalid_credentials');
          }
          if (lower.contains('password') &&
              (lower.contains('short') || lower.contains('8') || lower.contains('min') || lower.contains('longer'))) {
            throw AuthException('error_password_too_short');
          }
          if (lower.contains('firstname') || lower.contains('lastname') || lower.contains('name')) {
            throw AuthException('error_invalid_name');
          }
          if (lower.contains('phone') || lower.contains('mobile')) {
            throw AuthException('error_invalid_egyptian_phone');
          }
          if (lower.contains('exists') || lower.contains('already')) {
            throw AuthException('error_user_already_exists');
          }

          throw AuthException(firstMsg);
        }
      }
    }

    if (response?.statusCode == 401) {
      throw AuthException('error_invalid_credentials');
    } else if (response?.statusCode == 409) {
      throw AuthException('error_user_already_exists');
    }

    throw ServerException(e.message ?? 'error_server_failed');
  }

  @override
  Future<AuthResponseModel> login({required String email, required String password}) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<AuthResponseModel>.fromJson(
        response.data,
        (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse.data;
    } on DioException catch (e) {
      _parseDioException(e);
    } catch (e) {
      if (e is AuthException || e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? role,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      };

      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }
      if (role != null) {
        data['role'] = role;
      }

      final response = await dio.post('/auth/register', data: data);

      final apiResponse = ApiResponse<AuthResponseModel>.fromJson(
        response.data,
        (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse.data;
    } on DioException catch (e) {
      _parseDioException(e);
    } catch (e) {
      if (e is AuthException || e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } on DioException catch (e) {
      _parseDioException(e);
    } catch (e) {
      if (e is AuthException || e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
