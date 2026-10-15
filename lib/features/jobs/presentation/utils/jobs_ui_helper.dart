import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/job.dart';

class JobsUiHelper {
  JobsUiHelper._();

  static String getStatusLabel(JobStatus status, {bool isArabic = true}) {
    switch (status) {
      case JobStatus.scheduled:
        return isArabic ? 'مجدول' : 'Scheduled';
      case JobStatus.onTheWay:
        return isArabic ? 'في الطريق' : 'On the way';
      case JobStatus.inProgress:
        return isArabic ? 'قيد التنفيذ' : 'In Progress';
      case JobStatus.pending:
        return isArabic ? 'معلق' : 'Pending';
      case JobStatus.completed:
        return isArabic ? 'منجز' : 'Completed';
    }
  }

  static Color getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.scheduled:
        return AppColors.info;
      case JobStatus.onTheWay:
        return AppColors.warning;
      case JobStatus.inProgress:
        return AppColors.primary;
      case JobStatus.pending:
        return AppColors.danger;
      case JobStatus.completed:
        return AppColors.success;
    }
  }

  static IconData getStatusIcon(JobStatus status) {
    switch (status) {
      case JobStatus.scheduled:
        return Icons.event_available_rounded;
      case JobStatus.onTheWay:
        return Icons.directions_car_rounded;
      case JobStatus.inProgress:
        return Icons.build_circle_rounded;
      case JobStatus.pending:
        return Icons.hourglass_top_rounded;
      case JobStatus.completed:
        return Icons.task_alt_rounded;
    }
  }

  static String formatPrice(double price, {bool isArabic = true}) {
    final formatted = price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
    return isArabic ? '$formatted ج.م' : '$formatted EGP';
  }
}
