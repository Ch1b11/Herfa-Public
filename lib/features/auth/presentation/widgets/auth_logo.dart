import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  final double size;
  final bool showTitle;
  final String? subtitle;
  final double titleFontSize;

  const AuthLogo({
    super.key,
    this.size = 80.0,
    this.showTitle = true,
    this.subtitle,
    this.titleFontSize = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Icon Asset
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: size * 0.25,
                offset: Offset(0, size * 0.08),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.28),
            child: Image.asset(
              'assets/icons/herfa_logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (showTitle) ...[
          const SizedBox(height: 16),
          Text(
            'HERFA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: titleFontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: primaryTextColor,
            ),
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: secondaryTextColor,
            ),
          ),
        ],
      ],
    );
  }
}
