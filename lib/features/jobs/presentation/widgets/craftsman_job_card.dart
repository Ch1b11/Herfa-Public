import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/craftsman_jobs_view_data.dart';

/// Colour tokens for a job status pill.
({Color fg, Color bg}) craftsmanStatusColors(
  BuildContext context,
  CraftsmanJobStatus status,
) {
  final theme = Theme.of(context);
  switch (status) {
    case CraftsmanJobStatus.completed:
      return (
        fg: AppColors.success,
        bg: AppColors.success.withValues(alpha: 0.12),
      );
    case CraftsmanJobStatus.onTheWay:
      return (fg: AppColors.info, bg: AppColors.info.withValues(alpha: 0.12));
    case CraftsmanJobStatus.inProgress:
      return (
        fg: theme.colorScheme.primary,
        bg: theme.colorScheme.primary.withValues(alpha: 0.12),
      );
    case CraftsmanJobStatus.scheduled:
      return (
        fg: AppColors.warning,
        bg: AppColors.warning.withValues(alpha: 0.14),
      );
    case CraftsmanJobStatus.pending:
      return (
        fg: AppColors.secondary,
        bg: AppColors.secondary.withValues(alpha: 0.12),
      );
  }
}

IconData craftsmanStatusIcon(CraftsmanJobStatus status) {
  switch (status) {
    case CraftsmanJobStatus.completed:
      return Icons.check_circle_rounded;
    case CraftsmanJobStatus.onTheWay:
      return Icons.directions_car_rounded;
    case CraftsmanJobStatus.inProgress:
      return Icons.handyman_rounded;
    case CraftsmanJobStatus.scheduled:
      return Icons.event_rounded;
    case CraftsmanJobStatus.pending:
      return Icons.inbox_rounded;
  }
}

class CraftsmanJobCard extends StatelessWidget {
  const CraftsmanJobCard({
    super.key,
    required this.job,
    this.onAccept,
    this.isPendingSync,
  });

  final CraftsmanJobItem job;
  final VoidCallback? onAccept;
  final bool? isPendingSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    final statusColors = craftsmanStatusColors(context, job.status);
    final progress = job.totalSteps > 0
        ? job.progressStep / job.totalSteps
        : 0.0;

    return AppContentCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.pushNamed(
        'craftsman-job-detail',
        pathParameters: {'jobId': job.orderId.replaceFirst('#', '')},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColors.bg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  craftsmanStatusIcon(job.status),
                  size: 20,
                  color: statusColors.fg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.issue(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      job.client(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (sl.isRegistered<SyncService>()) ...[
                ValueListenableBuilder<int>(
                  valueListenable: sl<SyncService>().pendingMutationsCount,
                  builder: (context, count, child) {
                    final isPending = isPendingSync ??
                        sl<SyncService>().isJobPending(job.orderId);
                    if (!isPending) return const SizedBox.shrink();
                    return _buildPendingBadge(context, l10n);
                  },
                ),
              ] else if (isPendingSync == true) ...[
                _buildPendingBadge(context, l10n),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColors.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.statusLabel(l10n),
                  style: TextStyle(
                    color: statusColors.fg,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                _MetaChip(icon: Icons.tag_rounded, label: job.orderId),
                const SizedBox(width: 12),
                _MetaChip(
                  icon: Icons.near_me_rounded,
                  label: job.distance(l10n),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    job.price(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (job.dayLabelKey.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: textSecondary,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    '${job.dayLabel(l10n)} • ${job.slotLabel(l10n)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (job.hasProgress) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.craftsmanActiveJobProgress,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${job.progressStep}/${job.totalSteps}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          if (job.status == CraftsmanJobStatus.pending && onAccept != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 16),
                label: Text(
                  l10n.craftsmanIncomingAccept,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                onPressed: onAccept,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingBadge(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              size: 11,
              color: AppColors.warningDark,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.unsyncedBadge,
              style: const TextStyle(
                color: AppColors.warningDark,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: textSecondary),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
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
    );
  }
}
