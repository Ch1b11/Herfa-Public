import 'package:flutter/material.dart';

import '../soundwave_logo.dart';

class IntroDesktopLayout extends StatelessWidget {
  final VoidCallback? onCompleted;

  const IntroDesktopLayout({super.key, this.onCompleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onCompleted,
      child: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 56.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Continuous Soundwave / Sonar Ripple Animation
                const SoundwaveLogo(
                  logoSize: 108.0,
                  maxWaveSize: 420.0,
                ),

                const SizedBox(height: 32),

                // Brand Title
                Text(
                  'HERFA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.6,
                    color: primaryTextColor,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'SMART HOME SERVICES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4.5,
                    color: secondaryTextColor,
                  ),
                ),

                const SizedBox(height: 44),

                // Bottom Indicator: Three small dots (Theme Primary, Theme Secondary, Muted Theme Primary)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
