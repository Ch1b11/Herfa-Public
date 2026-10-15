import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/utils/snackbar_utils.dart';
import '../../data/datasources/jobs_local_data_source.dart';
import '../../domain/entities/job.dart';
import '../../../../core/widgets/app_action_button.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/craftsman_job_detail_view_data.dart';

/// Client identity card with call + chat shortcuts.
class CraftsmanJobDetailClientCard extends StatelessWidget {
  const CraftsmanJobDetailClientCard({super.key, required this.detail});

  final CraftsmanJobDetailData detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return AppContentCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.person_rounded,
            title: l10n.craftsmanDetailClientSection,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 23,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.client(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail.issue(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InlineAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: l10n.craftsmanDetailOpenChat,
                  color: theme.colorScheme.primary,
                  onTap: () {
                    String targetJobId =
                        detail.orderId.replaceFirst('#', '').trim();
                    if (di.sl.isRegistered<IJobsLocalDataSource>()) {
                      final localDataSource = di.sl<IJobsLocalDataSource>();
                      final cached = localDataSource.getCachedJob(targetJobId);
                      if (cached != null && cached.id.isNotEmpty) {
                        targetJobId = cached.id.replaceFirst('#', '').trim();
                      } else {
                        final inProgress = localDataSource.getCachedJobs(
                            status: JobStatus.inProgress);
                        if (inProgress.isNotEmpty &&
                            inProgress.first.id.isNotEmpty) {
                          targetJobId =
                              inProgress.first.id.replaceFirst('#', '').trim();
                        }
                      }
                    }
                    context.pushNamed(
                      'chat',
                      pathParameters: {
                        'jobId': targetJobId,
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InlineAction(
                  icon: Icons.call_rounded,
                  label: l10n.craftsmanDetailContactClient,
                  color: AppColors.secondary,
                  onTap: () => SnackBarUtils.showInfo(
                    context,
                    l10n.craftsmanDetailContactClient,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 17,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detail.address(l10n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Arrival window, distance and navigation action.
class CraftsmanJobDetailLocationCard extends StatelessWidget {
  const CraftsmanJobDetailLocationCard({super.key, required this.detail});

  final CraftsmanJobDetailData detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return AppContentCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.map_rounded,
            title: l10n.craftsmanDetailLocationSection,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.schedule_rounded,
                  label: l10n.craftsmanDetailArrivalWindow,
                  value: detail.arrival(l10n),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  icon: Icons.near_me_rounded,
                  label: l10n.craftsmanDetailDistanceLabel,
                  value: detail.distance(l10n),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 96,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 34,
                  color: textSecondary.withValues(alpha: 0.5),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.my_location_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppActionButton(
            label: l10n.craftsmanDetailNavigate,
            isFilled: false,
            leadingIcon: Icon(
              Icons.navigation_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            onTap: () =>
                SnackBarUtils.showInfo(context, l10n.craftsmanDetailNavigate),
          ),
        ],
      ),
    );
  }
}

/// Vertical, numbered workflow timeline.
class CraftsmanJobDetailWorkflowCard extends StatelessWidget {
  const CraftsmanJobDetailWorkflowCard({super.key, required this.detail});

  final CraftsmanJobDetailData detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final steps = detail.workflowSteps(l10n);

    return AppContentCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.timeline_rounded,
            title: l10n.craftsmanDetailWorkflowSection,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                l10n.craftsmanActiveJobProgress,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${detail.completedSteps}/${detail.totalSteps}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: detail.progress,
              minHeight: 7,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final isCompleted = index < detail.completedSteps;
            final isActive = index == detail.completedSteps;
            final isLast = index == steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : (isActive
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.18,
                                      )
                                    : Colors.transparent),
                          border: Border.all(
                            color: isCompleted
                                ? theme.colorScheme.primary
                                : borderColor,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 15,
                                color: AppColors.pureWhite,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? theme.colorScheme.primary
                                      : textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            color: isCompleted
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.45,
                                  )
                                : borderColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: isCompleted || isActive
                              ? textPrimary
                              : textSecondary,
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Parts & materials list.
class CraftsmanJobDetailPartsCard extends StatelessWidget {
  const CraftsmanJobDetailPartsCard({super.key, required this.detail});

  final CraftsmanJobDetailData detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return AppContentCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.inventory_2_rounded,
            title: l10n.craftsmanDetailPartsSection,
          ),
          const SizedBox(height: 5),
          Text(
            l10n.craftsmanDetailPartsSubtitle,
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ...detail.parts.map(
            (part) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            part.name(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            part.meta(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      part.price(l10n),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            child: AppActionButton(
              label: l10n.craftsmanDetailAddPart,
              isFilled: false,
              leadingIcon: Icon(
                Icons.add_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              onTap: () => context.goNamed(
                'craftsman-quote-builder',
                pathParameters: {
                  'jobId': detail.orderId.replaceFirst('#', ''),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inspection status block.
class CraftsmanJobDetailInspectionCard extends StatelessWidget {
  const CraftsmanJobDetailInspectionCard({super.key, required this.detail});

  final CraftsmanJobDetailData detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = theme.colorScheme.onSurface;
    final cleared = detail.inspectionCleared;
    final accent = cleared ? AppColors.success : AppColors.warning;

    return AppContentCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.fact_check_rounded,
            title: l10n.craftsmanDetailInspectionSection,
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  cleared ? Icons.check_circle_rounded : Icons.pending_outlined,
                  size: 19,
                  color: accent,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cleared
                            ? l10n.craftsmanDetailInspectionCleared
                            : l10n.craftsmanDetailInspectionWaiting,
                        style: TextStyle(
                          color: accent,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cleared
                            ? l10n.craftsmanDetailInspectionClearedDesc
                            : l10n.craftsmanDetailInspectionWaitingDesc,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Earnings breakdown + warranty notice + finish action.
class CraftsmanJobDetailPriceCard extends StatefulWidget {
  const CraftsmanJobDetailPriceCard({super.key, required this.detail});

  final CraftsmanJobDetailData detail;

  @override
  State<CraftsmanJobDetailPriceCard> createState() =>
      _CraftsmanJobDetailPriceCardState();
}

class _CraftsmanJobDetailPriceCardState
    extends State<CraftsmanJobDetailPriceCard> {
  bool _isFinishing = false;

  void _finishJob() {
    setState(() => _isFinishing = true);
    SnackBarUtils.showSuccess(
      context,
      AppLocalizations.of(context)!.craftsmanDetailFinishToast,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final rows = craftsmanBreakdown(l10n);

    return AppContentCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.payments_rounded,
            title: l10n.craftsmanDetailPriceSection,
          ),
          const SizedBox(height: 14),
          ...rows.map((row) {
            if (row.isTotal) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.label,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        row.value,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ),
                  Text(
                    row.value,
                    style: TextStyle(
                      color: row.isDeduction ? AppColors.danger : textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.craftsmanDetailWarrantyBadge,
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.craftsmanDetailWarrantyDesc,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppActionButton(
            label: _isFinishing
                ? l10n.craftsmanJobsStatusCompleted
                : l10n.craftsmanDetailFinishJob,
            isFilled: !_isFinishing,
            isPrimaryBorder: _isFinishing,
            leadingIcon: _isFinishing
                ? null
                : Icon(
                    Icons.task_alt_rounded,
                    size: 18,
                    color: theme.colorScheme.onPrimary,
                  ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            onTap: _isFinishing ? null : _finishJob,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 19, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineAction extends StatelessWidget {
  const _InlineAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
