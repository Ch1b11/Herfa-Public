import 'package:flutter/material.dart';

import '../../../../core/widgets/app_action_button.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../l10n/app_localizations.dart';

enum AuthUserRole { customer, provider }

class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.isSelected = false,
    this.onTap,
    this.onLoginTap,
    this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return AppContentCard(
      onTap: onTap,
      borderRadius: 18.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
      backgroundColor: isSelected
          ? iconColor.withValues(alpha: 0.1)
          : theme.cardColor,
      border: isSelected
          ? Border.all(color: iconColor, width: 2.0)
          : Border.all(color: theme.dividerColor, width: 1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 28,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        height: 1.4,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onLoginTap != null || onRegisterTap != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                if (onLoginTap != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onLoginTap,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: iconColor),
                      ),
                      child: Text(
                        l10n?.login ?? 'تسجيل الدخول',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                if (onLoginTap != null && onRegisterTap != null)
                  const SizedBox(width: 12),
                if (onRegisterTap != null)
                  Expanded(
                    child: AppActionButton(
                      label: l10n?.registerAction ?? 'تسجيل',
                      isFilled: true,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onTap: onRegisterTap,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
