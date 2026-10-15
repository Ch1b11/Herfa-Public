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
import '../widgets/components/customer_register_desktop_layout.dart';
import '../widgets/components/customer_register_mobile_layout.dart';
import '../widgets/components/customer_register_tablet_layout.dart';

class CustomerRegisterScreen extends StatelessWidget {
  const CustomerRegisterScreen({super.key});

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

          void handleRegister(
            String firstName,
            String lastName,
            String email,
            String phone,
            String password,
          ) {
            FocusManager.instance.primaryFocus?.unfocus();
            context.read<AuthBloc>().add(
                  RegisterRequested(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    phone: phone,
                    role: UserRole.customer,
                  ),
                );
          }

          void handleLogin() {
            FocusManager.instance.primaryFocus?.unfocus();
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          }

          return AdaptiveLayoutManager(
            mobileLayout: (context) => CustomerRegisterMobileLayout(
              isLoading: isLoading,
              onRegisterPressed: handleRegister,
              onLoginPressed: handleLogin,
            ),
            tabletLayout: (context) => CustomerRegisterTabletLayout(
              isLoading: isLoading,
              onRegisterPressed: handleRegister,
              onLoginPressed: handleLogin,
            ),
            desktopLayout: (context) => CustomerRegisterDesktopLayout(
              isLoading: isLoading,
              onRegisterPressed: handleRegister,
              onLoginPressed: handleLogin,
            ),
          );
        },
      );
  }
}
