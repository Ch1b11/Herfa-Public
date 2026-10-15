import 'package:flutter/material.dart';
import 'customer_register_mobile_layout.dart';

class CustomerRegisterDesktopLayout extends StatelessWidget {
  final Function(
    String firstName,
    String lastName,
    String email,
    String phone,
    String password,
  )? onRegisterPressed;
  final VoidCallback? onLoginPressed;
  final bool isLoading;

  const CustomerRegisterDesktopLayout({
    super.key,
    this.onRegisterPressed,
    this.onLoginPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: CustomerRegisterMobileLayout(
          onRegisterPressed: onRegisterPressed,
          onLoginPressed: onLoginPressed,
          isLoading: isLoading,
        ),
      ),
    );
  }
}
