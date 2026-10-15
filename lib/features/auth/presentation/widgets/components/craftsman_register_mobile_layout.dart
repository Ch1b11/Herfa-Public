import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/error_translator.dart';
import '../../../../../core/widgets/app_action_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/keyboard_safe_wrapper.dart';
import '../../../../../l10n/app_localizations.dart';
import '../auth_input_card.dart';

class CraftsmanRegisterMobileLayout extends StatefulWidget {
  final Function(
    String firstName,
    String lastName,
    String email,
    String phone,
    String password,
  )? onRegisterPressed;
  final VoidCallback? onLoginPressed;
  final bool isLoading;

  const CraftsmanRegisterMobileLayout({
    super.key,
    this.onRegisterPressed,
    this.onLoginPressed,
    this.isLoading = false,
  });

  @override
  State<CraftsmanRegisterMobileLayout> createState() =>
      _CraftsmanRegisterMobileLayoutState();
}

class _CraftsmanRegisterMobileLayoutState
    extends State<CraftsmanRegisterMobileLayout> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      widget.onRegisterPressed?.call(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _handleLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.onLoginPressed != null) {
      widget.onLoginPressed!();
    } else if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.pushNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return KeyboardSafeWrapper(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: AuthInputCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Header: Title & Subtitle
              Text(
                l10n.technician,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.technicianSubtitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _firstNameController,
                      labelText: l10n.firstName,
                      hint: l10n.firstNameHint,
                      floatingLabel: true,
                      enabled: !widget.isLoading,
                      prefixIcon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty || val.trim().length < 2) {
                          return context.translateError('error_invalid_name');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _lastNameController,
                      labelText: l10n.lastName,
                      hint: l10n.lastNameHint,
                      floatingLabel: true,
                      enabled: !widget.isLoading,
                      prefixIcon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty || val.trim().length < 2) {
                          return context.translateError('error_invalid_name');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              AppTextField(
                controller: _emailController,
                labelText: l10n.email,
                hint: l10n.emailHint,
                floatingLabel: true,
                enabled: !widget.isLoading,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return context.translateError('error_empty_credentials');
                  }
                  if (!val.contains('@') || !val.contains('.')) {
                    return context.translateError('error_invalid_credentials');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Field 2: Mobile Number
              AppTextField(
                controller: _phoneController,
                labelText: l10n.mobileNumber,
                hint: l10n.mobileNumberHint,
                floatingLabel: true,
                enabled: !widget.isLoading,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return context.translateError('error_invalid_egyptian_phone');
                  }
                  final phoneRegex = RegExp(r'^(?:\+20|0)?1[0125]\d{8}$');
                  if (!phoneRegex.hasMatch(val.trim())) {
                    return context.translateError('error_invalid_egyptian_phone');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Field 5: Password
              AppTextField(
                controller: _passwordController,
                labelText: l10n.password,
                hint: l10n.passwordHint,
                enabled: !widget.isLoading,
                obscure: true,
                floatingLabel: true,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleRegister(),
                validator: (val) {
                  if (val == null || val.isEmpty || val.length < 8) {
                    return context.translateError('error_password_too_short');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Primary Action Button
              AppActionButton(
                label: l10n.getStarted,
                isFilled: true,
                width: double.infinity,
                isLoading: widget.isLoading,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onTap: _handleRegister,
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAnAccount,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleLogin,
                      child: Text(
                        l10n.login,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
