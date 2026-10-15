import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

enum SocialAuthType { google, whatsapp }

class SocialAuthButton extends StatelessWidget {
  final SocialAuthType type;
  final VoidCallback? onTap;

  const SocialAuthButton({
    super.key,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final isGoogle = type == SocialAuthType.google;
    final label = isGoogle
        ? (l10n?.google ?? 'Google')
        : (l10n?.whatsapp ?? 'WhatsApp');

    final textColor = theme.colorScheme.onSurface;
    final borderColor = theme.dividerColor;
    final bgColor = theme.cardColor;

    Widget iconWidget;
    if (isGoogle) {
      iconWidget = const Text(
        'G',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.googleBlue,
        ),
      );
    } else {
      iconWidget = const Icon(
        Icons.chat_bubble_outline_rounded,
        size: 19,
        color: AppColors.whatsAppGreen,
      );
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              iconWidget,
            ],
          ),
        ),
      ),
    );
  }
}
