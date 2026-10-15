import 'package:flutter/material.dart';
import 'otp_verification_mobile_layout.dart';

class OtpVerificationTabletLayout extends StatelessWidget {
  final ValueChanged<String>? onVerify;
  final VoidCallback? onResend;
  final bool isLoading;
  final String? phoneNumber;

  const OtpVerificationTabletLayout({
    super.key,
    this.onVerify,
    this.onResend,
    this.isLoading = false,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: OtpVerificationMobileLayout(
          onVerify: onVerify,
          onResend: onResend,
          isLoading: isLoading,
          phoneNumber: phoneNumber,
        ),
      ),
    );
  }
}
