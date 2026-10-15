import 'package:flutter/material.dart';

import '../../../../core/layout_manager/adaptive_layout_manager.dart';
import '../widgets/components/otp_verification_desktop_layout.dart';
import '../widgets/components/otp_verification_mobile_layout.dart';
import '../widgets/components/otp_verification_tablet_layout.dart';

class OtpVerificationScreen extends StatelessWidget {
  final ValueChanged<String>? onVerify;
  final VoidCallback? onResend;
  final bool isLoading;
  final String? phoneNumber;

  const OtpVerificationScreen({
    super.key,
    this.onVerify,
    this.onResend,
    this.isLoading = false,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutManager(
      mobileLayout: (context) => OtpVerificationMobileLayout(
        onVerify: onVerify,
        onResend: onResend,
        isLoading: isLoading,
        phoneNumber: phoneNumber,
      ),
      tabletLayout: (context) => OtpVerificationTabletLayout(
        onVerify: onVerify,
        onResend: onResend,
        isLoading: isLoading,
        phoneNumber: phoneNumber,
      ),
      desktopLayout: (context) => OtpVerificationDesktopLayout(
        onVerify: onVerify,
        onResend: onResend,
        isLoading: isLoading,
        phoneNumber: phoneNumber,
      ),
    );
  }
}
