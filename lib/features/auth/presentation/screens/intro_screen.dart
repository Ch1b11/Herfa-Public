import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout_manager/adaptive_layout_manager.dart';
import '../widgets/components/intro_desktop_layout.dart';
import '../widgets/components/intro_mobile_layout.dart';
import '../widgets/components/intro_tablet_layout.dart';

class IntroScreen extends StatefulWidget {
  final VoidCallback? onTimeout;
  final Duration duration;

  const IntroScreen({
    super.key,
    this.onTimeout,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      if (mounted) {
        _handleCompleted();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleCompleted() {
    _timer?.cancel();
    if (widget.onTimeout != null) {
      widget.onTimeout!();
    } else if (mounted) {
      context.goNamed('register-role');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AdaptiveLayoutManager(
          mobileLayout: (context) => IntroMobileLayout(
            onCompleted: _handleCompleted,
          ),
          tabletLayout: (context) => IntroTabletLayout(
            onCompleted: _handleCompleted,
          ),
          desktopLayout: (context) => IntroDesktopLayout(
            onCompleted: _handleCompleted,
          ),
        ),
      ),
    );
  }
}
