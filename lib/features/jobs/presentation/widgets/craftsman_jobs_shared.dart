import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/craftsman_jobs_view_data.dart';

/// Segmented tab switcher shared by every jobs layout.
class CraftsmanJobsTabBar extends StatelessWidget {
  const CraftsmanJobsTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final CraftsmanJobsTab selected;
  final ValueChanged<CraftsmanJobsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: CraftsmanJobsTab.values.map((tab) {
          final isSelected = tab == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    craftsmanJobsTabLabel(l10n, tab),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? AppColors.pureWhite : textSecondary,
                      fontSize: 12.5,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Header block: title, subtitle and live job counters.
class CraftsmanJobsHeader extends StatelessWidget {
  final int? activeCount;
  final int? incomingCount;
  final int? completedCount;

  const CraftsmanJobsHeader({
    super.key,
    this.activeCount,
    this.incomingCount,
    this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.craftsmanJobsScreenTitle,
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.craftsmanJobsSubtitle,
          style: TextStyle(color: textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _CountTile(
                label: l10n.craftsmanJobsTabActive,
                value: '${activeCount ?? craftsmanActiveJobs.length}',
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _CountTile(
                label: l10n.craftsmanJobsTabIncoming,
                value: '${incomingCount ?? craftsmanIncomingJobs.length}',
                color: AppColors.secondary,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _CountTile(
                label: l10n.craftsmanJobsTabCompleted,
                value: '${completedCount ?? craftsmanCompletedJobs.length}',
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shown when a tab has nothing in it yet.
class CraftsmanJobsEmptyState extends StatelessWidget {
  const CraftsmanJobsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return AppContentCard(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 28,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.craftsmanJobsEmptyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l10n.craftsmanJobsEmptyDesc,
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// Quick shortcut row that links the other craftsman screens.
class CraftsmanJobsQuickLinks extends StatelessWidget {
  const CraftsmanJobsQuickLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _QuickLink(
            icon: Icons.account_balance_wallet_rounded,
            label: l10n.craftsmanNavEarnings,
            onTap: () => context.goNamed('craftsman-earnings'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickLink(
            icon: Icons.badge_rounded,
            label: l10n.craftsmanNavProfile,
            onTap: () => context.pushNamed('craftsman-profile'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickLink(
            icon: Icons.dashboard_rounded,
            label: l10n.craftsmanNavDashboard,
            onTap: () => context.goNamed('craftsman-dashboard'),
          ),
        ),
      ],
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;

    return AppContentCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 21, color: theme.colorScheme.primary),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
