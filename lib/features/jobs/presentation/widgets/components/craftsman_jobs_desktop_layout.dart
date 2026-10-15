import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:herfa/features/jobs/domain/entities/job.dart';
import 'package:herfa/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:herfa/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:herfa/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:herfa/features/jobs/presentation/models/craftsman_jobs_view_data.dart';
import '../craftsman_job_card.dart';
import '../craftsman_jobs_shared.dart';
import '../job_card_skeleton.dart';

class CraftsmanJobsDesktopLayout extends StatelessWidget {
  const CraftsmanJobsDesktopLayout({
    super.key,
    required this.tab,
    required this.onTabChanged,
  });

  final CraftsmanJobsTab tab;
  final ValueChanged<CraftsmanJobsTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    JobsBloc? bloc;
    try {
      bloc = context.read<JobsBloc>();
    } catch (_) {
      bloc = null;
    }

    if (bloc == null) {
      return _buildLayout(context, null);
    }

    return BlocBuilder<JobsBloc, JobsState>(
      bloc: bloc,
      builder: (context, state) => _buildLayout(context, state),
    );
  }

  Widget _buildLayout(BuildContext context, JobsState? state) {
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalPadding = (screenSize.width * 0.07).clamp(32.0, 64.0);
    final topPadding = (screenSize.height * 0.025).clamp(20.0, 32.0);
    final sectionSpacing = (screenSize.height * 0.022).clamp(20.0, 26.0);
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 100.0;

    final int activeCount;
    final int incomingCount;
    final int completedCount;
    final List<CraftsmanJobItem> displayJobs;
    final bool isLoading = state is JobsLoading;

    if (state is JobsLoaded) {
      final all = state.jobs;
      final active = all
          .where((j) =>
              j.status == JobStatus.inProgress ||
              j.status == JobStatus.onTheWay ||
              j.status == JobStatus.scheduled)
          .toList();
      final incoming = state.availableBroadcasts.isNotEmpty
          ? state.availableBroadcasts
          : all.where((j) => j.status == JobStatus.pending).toList();
      final completed =
          all.where((j) => j.status == JobStatus.completed).toList();

      activeCount = active.length;
      incomingCount = incoming.length;
      completedCount = completed.length;

      final List<Job> currentFiltered;
      switch (tab) {
        case CraftsmanJobsTab.active:
          currentFiltered = active;
          break;
        case CraftsmanJobsTab.incoming:
          currentFiltered = incoming;
          break;
        case CraftsmanJobsTab.completed:
          currentFiltered = completed;
          break;
      }
      displayJobs = currentFiltered.map(CraftsmanJobItem.fromJob).toList();
    } else {
      activeCount = craftsmanActiveJobs.length;
      incomingCount = craftsmanIncomingJobs.length;
      completedCount = craftsmanCompletedJobs.length;
      displayJobs = jobsForTab(tab);
    }

    return FocusScope(
      autofocus: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            try {
              context.read<JobsBloc>().add(const FetchCraftsmanJobs(forceRefresh: true));
            } catch (_) {}
            await Future<void>.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsetsDirectional.only(
              start: horizontalPadding,
              end: horizontalPadding,
              top: topPadding,
              bottom: bottomPadding,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CraftsmanJobsHeader(
                      activeCount: activeCount,
                      incomingCount: incomingCount,
                      completedCount: completedCount,
                    ),
                    SizedBox(height: sectionSpacing),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              CraftsmanJobsTabBar(
                                selected: tab,
                                onChanged: onTabChanged,
                              ),
                              SizedBox(height: sectionSpacing),
                              const CraftsmanJobsQuickLinks(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 7,
                          child: isLoading
                              ? const CraftsmanJobsListSkeleton(
                                  itemCount: 3,
                                  spacing: 12.0,
                                )
                              : displayJobs.isEmpty
                                  ? const CraftsmanJobsEmptyState()
                                  : Column(
                                      children: displayJobs
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final jobItem = entry.value;
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: entry.key ==
                                                    displayJobs.length - 1
                                                ? 0
                                                : sectionSpacing * 0.7,
                                          ),
                                          child: CraftsmanJobCard(
                                            job: jobItem,
                                            onAccept: tab ==
                                                    CraftsmanJobsTab.incoming
                                                ? () {
                                                    try {
                                                      context
                                                          .read<JobsBloc>()
                                                          .add(
                                                            AcceptJob(
                                                              jobItem
                                                                  .orderId
                                                                  .replaceFirst(
                                                                      '#', ''),
                                                            ),
                                                          );
                                                    } catch (_) {}
                                                  }
                                                : null,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
