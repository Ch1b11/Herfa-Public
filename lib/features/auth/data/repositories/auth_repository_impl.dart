import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final authResponse = await remoteDataSource.login(email: email, password: password);
      if (rememberMe) {
        await localDataSource.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        await localDataSource.saveUser(authResponse.user);
      } else {
        // Session-only: save accessToken for active in-memory API requests,
        // but do not persist refreshToken or cached user profile.
        await localDataSource.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: '',
        );
        await localDataSource.clearUser();
      }
      return Right(authResponse.user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    UserRole? role,
  }) async {
    try {
      final authResponse = await remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role?.name,
      );
      await localDataSource.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      await localDataSource.saveUser(authResponse.user);
      return Right(authResponse.user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAll();
      return const Right(null);
    } on ServerException catch (e) {
      // Even if remote logout fails (e.g. token expired anyway), 
      // we still want to clear local tokens to ensure a clean state
      await localDataSource.clearAll();
      return Left(ServerFailure(e.message));
    } catch (e) {
      await localDataSource.clearAll();
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> checkAuthStatus() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      final hasRefreshToken =
          refreshToken != null && refreshToken.trim().isNotEmpty;

      // If no valid refresh token exists, the user either did not opt into "Remember Me"
      // or has no session. Explicitly wipe any orphaned tokens and user data.
      if (!hasRefreshToken) {
        await localDataSource.clearTokens();
        await localDataSource.clearUser();
        return const Right(null);
      }

      final user = await localDataSource.getUser();
      if (user != null) {
        return Right(user);
      }

      // If refresh token exists but cached user is missing or corrupted, wipe orphaned tokens and user data.
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
