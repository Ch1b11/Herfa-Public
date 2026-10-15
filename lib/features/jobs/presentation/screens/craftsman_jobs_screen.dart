import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/layout_manager/adaptive_layout_manager.dart';
import '../../../../core/widgets/keyboard_safe_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../models/craftsman_jobs_view_data.dart';
import '../widgets/components/craftsman_jobs_desktop_layout.dart';
import '../widgets/components/craftsman_jobs_mobile_layout.dart';
import '../widgets/components/craftsman_jobs_tablet_layout.dart';

class CraftsmanJobsScreen extends StatefulWidget {
  const CraftsmanJobsScreen({super.key});

  @override
  State<CraftsmanJobsScreen> createState() => _CraftsmanJobsScreenState();
}

class _CraftsmanJobsScreenState extends State<CraftsmanJobsScreen> {
  CraftsmanJobsTab _tab = CraftsmanJobsTab.active;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<JobsBloc>().add(const FetchCraftsmanJobs());
        } catch (_) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final content = AdaptiveLayoutManager(
      mobileLayout: (context) =>
          CraftsmanJobsMobileLayout(tab: _tab, onTabChanged: _onTabChanged),
      tabletLayout: (context) =>
          CraftsmanJobsTabletLayout(tab: _tab, onTabChanged: _onTabChanged),
      desktopLayout: (context) =>
          CraftsmanJobsDesktopLayout(tab: _tab, onTabChanged: _onTabChanged),
    );

    final wrappedContent = _wrapWithBlocIfNeeded(content);

    if (Scaffold.maybeOf(context) != null) {
      return wrappedContent;
    }

    return KeyboardSafeWrapper(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_back_rounded,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('craftsman-dashboard');
              }
            },
          ),
          title: Text(
            l10n.craftsmanJobsScreenTitle,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        body: SafeArea(child: wrappedContent),
      ),
    );
  }

  Widget _wrapWithBlocIfNeeded(Widget child) {
    try {
      context.read<JobsBloc>();
      return child;
    } catch (_) {
      if (sl.isRegistered<JobsBloc>()) {
        return BlocProvider(
          create: (context) => sl<JobsBloc>()..add(const FetchCraftsmanJobs()),
          child: child,
        );
      }
      return child;
    }
  }

  void _onTabChanged(CraftsmanJobsTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
  }
}
