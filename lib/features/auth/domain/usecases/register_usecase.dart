import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    UserRole? role,
  }) async {
    // 8-character minimum password rule
    if (password.length < 8) {
      return const Left(AuthFailure('error_password_too_short'));
    }

    // Egyptian phone number format validation (+201[0-2,5]\d{8} or 01[0-2,5]\d{8})
    if (phone != null && phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^(?:\+20|0)?1[0125]\d{8}$');
      if (!phoneRegex.hasMatch(phone)) {
        return const Left(AuthFailure('error_invalid_egyptian_phone'));
      }
    }

    return repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      role: role,
    );
  }
}
