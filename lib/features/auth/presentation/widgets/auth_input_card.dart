import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuthInputCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AuthInputCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOled = theme.scaffoldBackgroundColor == AppColors.oledBackground;

    // Strict Background Hierarchy
    final cardBg = isOled ? AppColors.oledCard : theme.cardColor;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1,
        ),
        boxShadow: [
          if (!isDark && !isOled)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: child,
    );
  }
}
