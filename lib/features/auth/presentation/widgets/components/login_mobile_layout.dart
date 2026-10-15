import 'package:flutter/material.dart';

import '../../../../../core/utils/error_translator.dart';
import '../../../../../core/widgets/app_action_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/keyboard_safe_wrapper.dart';
import '../../../../../l10n/app_localizations.dart';
import '../auth_input_card.dart';
import '../social_auth_button.dart';
import '../whatsapp_otp_button.dart';

class LoginMobileLayout extends StatefulWidget {
  final Function(String email, String password, bool rememberMe)? onLoginPressed;
  final VoidCallback? onForgotPasswordPressed;
  final VoidCallback? onRegisterCustomerPressed;
  final VoidCallback? onRegisterCraftsmanPressed;
  final VoidCallback? onGoogleAuthPressed;
  final VoidCallback? onWhatsAppAuthPressed;
  final bool isLoading;

  const LoginMobileLayout({
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
  State<LoginMobileLayout> createState() => _LoginMobileLayoutState();
}

class _LoginMobileLayoutState extends State<LoginMobileLayout> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLoginPressed?.call(
        _emailController.text.trim(),
        _passwordController.text,
        _rememberMe,
      );
    }
  }

  void _handleRegisterCustomer() {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onRegisterCustomerPressed?.call();
  }

  void _handleRegisterCraftsman() {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onRegisterCraftsmanPressed?.call();
  }

  void _handleForgotPassword() {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onForgotPasswordPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    final dividerColor = theme.dividerColor;

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
                l10n.loginTitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginSubtitle,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 32),

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

              // Field 2: Password
              AppTextField(
                controller: _passwordController,
                labelText: l10n.password,
                hint: l10n.passwordHint,
                enabled: !widget.isLoading,
                obscure: true,
                floatingLabel: true,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.translateError('error_empty_credentials');
                  }
                  if (value.length < 8) {
                    return context.translateError('error_password_too_short');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // Controls: Checkbox "Remember me", "Forgot password?"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _rememberMe = !_rememberMe;
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.rememberMe,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  TextButton(
                    onPressed: _handleForgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.forgotPassword,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Primary Action: Login
              AppActionButton(
                label: l10n.login,
                isFilled: true,
                width: double.infinity,
                isLoading: widget.isLoading,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onTap: _handleLogin,
              ),

              const SizedBox(height: 32),

              // Social Auth Bridge Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: dividerColor,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.orLoginWith,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: dividerColor,
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Social Auth Buttons
              WhatsAppOtpButton(
                onTap: widget.isLoading ? null : widget.onWhatsAppAuthPressed,
                isLoading: false,
              ),
              const SizedBox(height: 12),
              SocialAuthButton(
                type: SocialAuthType.google,
                onTap: widget.onGoogleAuthPressed,
              ),

              const SizedBox(height: 36),

              // Footer: Don't have an account? Create account as Customer or Craftsman/Provider
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${l10n.dontHaveAnAccount} ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                    Text(
                      l10n.createAccountPrefix,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleRegisterCustomer,
                      child: Text(
                        l10n.registerAsCustomer,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      l10n.orText,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleRegisterCraftsman,
                      child: Text(
                        l10n.registerAsCraftsman,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
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
