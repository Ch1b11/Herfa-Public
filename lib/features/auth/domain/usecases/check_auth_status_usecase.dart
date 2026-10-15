import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class CheckAuthStatusUseCase {
  final IAuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<Either<Failure, User?>> call() async {
    return repository.checkAuthStatus();
  }
}
