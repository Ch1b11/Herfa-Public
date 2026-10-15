import 'package:flutter/material.dart';

import '../soundwave_logo.dart';

class IntroTabletLayout extends StatelessWidget {
  final VoidCallback? onCompleted;

  const IntroTabletLayout({super.key, this.onCompleted});

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
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Continuous Soundwave / Sonar Ripple Animation
                const SoundwaveLogo(
                  logoSize: 96.0,
                  maxWaveSize: 360.0,
                ),

                const SizedBox(height: 24),

                // Brand Title
                Text(
                  'HERFA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.4,
                    color: primaryTextColor,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  'SMART HOME SERVICES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4.0,
                    color: secondaryTextColor,
                  ),
                ),

                const SizedBox(height: 36),

                // Bottom Indicator: Three small dots (Theme Primary, Theme Secondary, Muted Theme Primary)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
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
