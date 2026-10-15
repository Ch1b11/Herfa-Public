import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../core/widgets/app_skeleton.dart';

/// Pixel-accurate skeleton card mirroring [CraftsmanJobCard].
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return SkeletonLoader(
      child: AppContentCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBox(
                  width: 42,
                  height: 42,
                  borderRadius: 13,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140, height: 15, borderRadius: 4),
                      SizedBox(height: 5),
                      SkeletonBox(width: 90, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SkeletonBox(
                  width: 64,
                  height: 22,
                  borderRadius: 8,
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
              child: const Row(
                children: [
                  SkeletonBox(width: 70, height: 14, borderRadius: 4),
                  SizedBox(width: 12),
                  SkeletonBox(width: 55, height: 14, borderRadius: 4),
                  Spacer(),
                  SkeletonBox(width: 65, height: 15, borderRadius: 4),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                SkeletonBox(width: 13, height: 13, borderRadius: 3),
                SizedBox(width: 6),
                SkeletonBox(width: 120, height: 12, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                SkeletonBox(width: 75, height: 12, borderRadius: 3),
                Spacer(),
                SkeletonBox(width: 25, height: 12, borderRadius: 3),
              ],
            ),
            const SizedBox(height: 6),
            const SkeletonBox(
              width: double.infinity,
              height: 6,
              borderRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

/// A vertical list of [JobCardSkeleton] items used during the Jobs loading state.
class CraftsmanJobsListSkeleton extends StatelessWidget {
  final int itemCount;
  final double spacing;

  const CraftsmanJobsListSkeleton({
    super.key,
    this.itemCount = 3,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index == itemCount - 1 ? 0 : spacing,
          ),
          child: const JobCardSkeleton(),
        ),
      ),
    );
  }
}
