import 'package:flutter/material.dart';
import 'login_mobile_layout.dart';

class LoginTabletLayout extends StatelessWidget {
  final Function(String email, String password, bool rememberMe)?
      onLoginPressed;
  final VoidCallback? onForgotPasswordPressed;
  final VoidCallback? onRegisterCustomerPressed;
  final VoidCallback? onRegisterCraftsmanPressed;
  final VoidCallback? onGoogleAuthPressed;
  final VoidCallback? onWhatsAppAuthPressed;
  final bool isLoading;

  const LoginTabletLayout({
    super.key,
    this.onLoginPressed,
    this.onForgotPasswordPressed,
    this.onRegisterCustomerPressed,
    this.onRegisterCraftsmanPressed,
    this.onGoogleAuthPressed,
    this.onWhatsAppAuthPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: LoginMobileLayout(
          onLoginPressed: onLoginPressed,
          onForgotPasswordPressed: onForgotPasswordPressed,
          onRegisterCustomerPressed: onRegisterCustomerPressed,
          onRegisterCraftsmanPressed: onRegisterCraftsmanPressed,
          onGoogleAuthPressed: onGoogleAuthPressed,
          onWhatsAppAuthPressed: onWhatsAppAuthPressed,
          isLoading: isLoading,
        ),
      ),
    );
  }
}
