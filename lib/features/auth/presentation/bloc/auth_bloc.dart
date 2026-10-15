import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/auth_event_bus.dart';
import '../../../../core/services/session_manager.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final AuthEventBus? authEventBus;
  final SessionManager? sessionManager;
  StreamSubscription<AuthEventType>? _authEventBusSubscription;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    this.authEventBus,
    this.sessionManager,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionExpiredRequested>(_onSessionExpiredRequested);
    on<AuthUserUpdated>((event, emit) => emit(AuthAuthenticated(event.user)));

    _authEventBusSubscription = authEventBus?.stream.listen((event) {
      if (event == AuthEventType.unauthorized) {
        add(const SessionExpiredRequested());
      }
    });
  }

  Future<void> checkInitialAuth() async {
    add(const CheckAuthStatusRequested());
    await stream
        .firstWhere((state) => state is! AuthInitial && state is! AuthLoading)
        .timeout(const Duration(seconds: 3), onTimeout: () => state);
  }

  Future<void> _onCheckAuthStatusRequested(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await checkAuthStatusUseCase();
      result.fold(
        (failure) => emit(AuthUnauthenticated()),
        (user) {
          if (user != null) {
            emit(AuthAuthenticated(user));
          } else {
            emit(AuthUnauthenticated());
          }
        },
      );
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await loginUseCase(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await registerUseCase(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        role: event.role,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await logoutUseCase();
      try {
        await sessionManager?.clearSession();
      } catch (_) {}

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) => emit(AuthUnauthenticated()),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSessionExpiredRequested(
    SessionExpiredRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await sessionManager?.clearSession();
    } catch (_) {}
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authEventBusSubscription?.cancel();
    return super.close();
  }
}
