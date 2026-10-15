import 'package:flutter/material.dart';

class SoundwaveLogo extends StatefulWidget {
  final double logoSize;

  final double maxWaveSize;

  const SoundwaveLogo({
    super.key,
    this.logoSize = 80.0,
    this.maxWaveSize = 220.0,
  });

  @override
  State<SoundwaveLogo> createState() => _SoundwaveLogoState();
}

class _SoundwaveLogoState extends State<SoundwaveLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Stagger 3 wave offsets evenly across the normalized [0, 1] timeline
  static const List<double> _waveOffsets = [0.0, 0.33, 0.66];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseBorderColor = theme.colorScheme.primary.withValues(
      alpha: isDark ? 0.35 : 0.25,
    );

    final baseFillColor = theme.colorScheme.primary.withValues(
      alpha: isDark ? 0.08 : 0.05,
    );

    return SizedBox(
      width: widget.maxWaveSize,
      height: widget.maxWaveSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 3 Staggered continuous soundwave circles
              for (final offset in _waveOffsets) ...[
                Builder(
                  builder: (context) {
                    final rawProgress = (_controller.value + offset) % 1.0;
                    final curvedProgress =
                        Curves.easeOutCubic.transform(rawProgress);

                    // Scale from right behind the logo out to maximum wave boundary
                    final scale = 0.45 + (curvedProgress * 0.55);
                    final currentSize = widget.maxWaveSize * scale;

                    // Fade out smoothly as wave expands
                    final opacity = (1.0 - curvedProgress).clamp(0.0, 1.0);

                    return Container(
                      width: currentSize,
                      height: currentSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: baseFillColor.withValues(
                          alpha: 0.12 * opacity,
                        ),
                        border: Border.all(
                          color: baseBorderColor.withValues(
                            alpha: 0.65 * opacity,
                          ),
                          width: 1.2,
                        ),
                      ),
                    );
                  },
                ),
              ],

              // Central HERFA App Icon Asset
              Container(
                width: widget.logoSize,
                height: widget.logoSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.logoSize * 0.28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(
                        alpha: isDark ? 0.35 : 0.25,
                      ),
                      blurRadius: widget.logoSize * 0.35,
                      offset: Offset(0, widget.logoSize * 0.1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.logoSize * 0.28),
                  child: Image.asset(
                    'assets/icons/herfa_logo.png',
                    width: widget.logoSize,
                    height: widget.logoSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
