import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return const Left(AuthFailure('error_empty_credentials'));
    }
    return repository.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }
}
