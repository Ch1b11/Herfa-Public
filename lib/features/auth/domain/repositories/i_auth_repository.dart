import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class IAuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    bool rememberMe = true,
  });

  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    UserRole? role,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User?>> checkAuthStatus();
}
