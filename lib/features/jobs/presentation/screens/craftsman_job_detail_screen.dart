import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/layout_manager/adaptive_layout_manager.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/keyboard_safe_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../models/craftsman_job_detail_view_data.dart';
import '../widgets/components/craftsman_job_detail_desktop_layout.dart';
import '../widgets/components/craftsman_job_detail_mobile_layout.dart';
import '../widgets/components/craftsman_job_detail_tablet_layout.dart';

class CraftsmanJobDetailScreen extends StatefulWidget {
  const CraftsmanJobDetailScreen({super.key, this.jobId});

  final String? jobId;

  @override
  State<CraftsmanJobDetailScreen> createState() =>
      _CraftsmanJobDetailScreenState();
}

class _CraftsmanJobDetailScreenState extends State<CraftsmanJobDetailScreen> {
  late int _completedSteps = craftsmanDefaultJobDetail.completedSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final detail = craftsmanDefaultJobDetail;

    final content = AdaptiveLayoutManager(
      mobileLayout: (context) => CraftsmanJobDetailMobileLayout(
        detail: detail,
        completedSteps: _completedSteps,
        onCompleteStep: _completeStep,
      ),
      tabletLayout: (context) => CraftsmanJobDetailTabletLayout(
        detail: detail,
        completedSteps: _completedSteps,
      ),
      desktopLayout: (context) => CraftsmanJobDetailDesktopLayout(
        detail: detail,
        completedSteps: _completedSteps,
      ),
    );

    final wrappedContent = _wrapWithBlocIfNeeded(content);

    if (Scaffold.maybeOf(context) != null) {
      return KeyboardSafeWrapper(child: wrappedContent);
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
                context.goNamed('craftsman-jobs');
              }
            },
          ),
          title: Text(
            l10n.craftsmanDetailScreenTitle,
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
    final id = widget.jobId;
    if (id == null) return child;
    try {
      context.read<JobsBloc>();
      return child;
    } catch (_) {
      if (sl.isRegistered<JobsBloc>()) {
        return BlocProvider(
          create: (context) => sl<JobsBloc>()..add(FetchJobDetail(jobId: id)),
          child: child,
        );
      }
      return child;
    }
  }

  void _completeStep() {
    if (_completedSteps >= craftsmanDefaultJobDetail.totalSteps) return;
    setState(() => _completedSteps++);
    SnackBarUtils.showSuccess(
      context,
      AppLocalizations.of(context)!.craftsmanActiveJobStepDoneToast,
    );
  }
}
