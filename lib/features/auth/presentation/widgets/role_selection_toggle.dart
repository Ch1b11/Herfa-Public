import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'role_card.dart'; // Using AuthUserRole

class RoleSelectionToggle extends StatelessWidget {
  final AuthUserRole selectedRole;
  final ValueChanged<AuthUserRole> onRoleChanged;

  const RoleSelectionToggle({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final unselectedBg = theme.colorScheme.surfaceContainerLow;
    final selectedCustomerBg = theme.colorScheme.secondary.withValues(
      alpha: isDark ? 0.2 : 0.12,
    );
    final selectedProviderBg = theme.colorScheme.primary.withValues(
      alpha: isDark ? 0.2 : 0.12,
    );

    return Container(
      decoration: BoxDecoration(
        color: unselectedBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ToggleItem(
              title: l10n.customer,
              icon: Icons.home_outlined,
              isSelected: selectedRole == AuthUserRole.customer,
              activeColor: theme.colorScheme.secondary,
              activeBgColor: selectedCustomerBg,
              onTap: () => onRoleChanged(AuthUserRole.customer),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ToggleItem(
              title: l10n.technician,
              icon: Icons.handyman_outlined,
              isSelected: selectedRole == AuthUserRole.provider,
              activeColor: theme.colorScheme.primary,
              activeBgColor: selectedProviderBg,
              onTap: () => onRoleChanged(AuthUserRole.provider),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final Color activeBgColor;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.activeBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.3))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? activeColor : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
