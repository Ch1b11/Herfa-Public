import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user.dart';

/// Centralized UI helper for the Auth feature.
/// Provides static role mappers, colors, and presentation utilities.
class AuthUiHelper {
  AuthUiHelper._();

  /// Returns the localized label for a [UserRole].
  static String getRoleLabel(UserRole role, {bool isArabic = true}) {
    switch (role) {
      case UserRole.customer:
        return isArabic ? 'عميل' : 'Customer';
      case UserRole.provider:
        return isArabic ? 'حرفي معتمد' : 'Certified Craftsman';
      case UserRole.admin:
        return isArabic ? 'مدير النظام' : 'Administrator';
    }
  }

  /// Returns badge theme color for a [UserRole].
  static Color getRoleBadgeColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return AppColors.primary;
      case UserRole.provider:
        return AppColors.secondary;
      case UserRole.admin:
        return AppColors.warning;
    }
  }

  /// Returns icon for a [UserRole].
  static IconData getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.person_rounded;
      case UserRole.provider:
        return Icons.handyman_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  /// Validates email address format.
  static String? validateEmail(String? value, {String? requiredMsg, String? invalidMsg}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return invalidMsg ?? 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  /// Validates password strength (min 6 characters).
  static String? validatePassword(String? value, {String? requiredMsg, String? tooShortMsg}) {
    if (value == null || value.isEmpty) {
      return requiredMsg ?? 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return tooShortMsg ?? 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
    }
    return null;
  }

  /// Validates required text field.
  static String? validateRequired(String? value, String fieldName, {bool isArabic = true}) {
    if (value == null || value.trim().isEmpty) {
      return isArabic ? '$fieldName مطلوب' : '$fieldName is required';
    }
    return null;
  }
}
