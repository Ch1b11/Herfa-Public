import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout_manager/adaptive_layout_manager.dart';
import '../../../../core/utils/error_translator.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/components/login_desktop_layout.dart';
import '../widgets/components/login_mobile_layout.dart';
import '../widgets/components/login_tablet_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            SnackBarUtils.showError(context, context.translateError(state.message));
          } else if (state is AuthAuthenticated) {
            final l10n = AppLocalizations.of(context);
            final message = l10n != null
                ? l10n.welcomeUser(state.user.firstName)
                : 'مرحباً بك، ${state.user.firstName}';
            SnackBarUtils.showSuccess(context, message);

            FocusManager.instance.primaryFocus?.unfocus();
            if (state.user.role == UserRole.provider) {
              context.go('/provider-dashboard');
            } else {
              context.go('/customer-dashboard');
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          void handleLogin(String email, String password, bool rememberMe) {
            FocusManager.instance.primaryFocus?.unfocus();
            context.read<AuthBloc>().add(
                  LoginRequested(
                    email: email,
                    password: password,
                    rememberMe: rememberMe,
                  ),
                );
          }

          void handleRegisterCustomer() {
            FocusManager.instance.primaryFocus?.unfocus();
            context.pushNamed('register-customer');
          }

          void handleRegisterCraftsman() {
            FocusManager.instance.primaryFocus?.unfocus();
            context.pushNamed('register-craftsman');
          }

          return AdaptiveLayoutManager(
            mobileLayout: (context) => LoginMobileLayout(
              isLoading: isLoading,
              onLoginPressed: handleLogin,
              onRegisterCustomerPressed: handleRegisterCustomer,
              onRegisterCraftsmanPressed: handleRegisterCraftsman,
            ),
            tabletLayout: (context) => LoginTabletLayout(
              isLoading: isLoading,
              onLoginPressed: handleLogin,
              onRegisterCustomerPressed: handleRegisterCustomer,
              onRegisterCraftsmanPressed: handleRegisterCraftsman,
            ),
            desktopLayout: (context) => LoginDesktopLayout(
              isLoading: isLoading,
              onLoginPressed: handleLogin,
              onRegisterCustomerPressed: handleRegisterCustomer,
              onRegisterCraftsmanPressed: handleRegisterCraftsman,
            ),
          );
        },
      );
  }
}
