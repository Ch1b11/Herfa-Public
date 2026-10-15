import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_action_button.dart';
import '../../../../../l10n/app_localizations.dart';
import '../auth_input_card.dart';
import 'otp_verification_view.dart';

class OtpVerificationMobileLayout extends StatelessWidget {
  final ValueChanged<String>? onVerify;
  final VoidCallback? onResend;
  final bool isLoading;
  final String? phoneNumber;

  const OtpVerificationMobileLayout({
    super.key,
    this.onVerify,
    this.onResend,
    this.isLoading = false,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    String currentCode = '';

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: AuthInputCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.otpTitle,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.otpSubtitle}\n${phoneNumber ?? ""}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            OtpVerificationView(
              length: 6,
              isLoading: isLoading,
              onCompleted: (code) {
                currentCode = code;
                if (onVerify != null) {
                  onVerify!(code);
                }
              },
              onResend: () {
                if (onResend != null) {
                  onResend!();
                }
              },
            ),
            const SizedBox(height: 32),
            AppActionButton(
              label: l10n.otpVerifyAction,
              isFilled: true,
              width: double.infinity,
              isLoading: isLoading,
              padding: const EdgeInsets.symmetric(vertical: 16),
              onTap: () {
                if (currentCode.length == 6 && onVerify != null) {
                  onVerify!(currentCode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
