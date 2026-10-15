import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../l10n/app_localizations.dart';
import '../role_card.dart';

class RoleSelectionMobileLayout extends StatefulWidget {
  final ValueChanged<AuthUserRole>? onRoleSelected;
  final AuthUserRole? initialRole;

  const RoleSelectionMobileLayout({
    super.key,
    this.onRoleSelected,
    this.initialRole,
  });

  @override
  State<RoleSelectionMobileLayout> createState() =>
      _RoleSelectionMobileLayoutState();
}

class _RoleSelectionMobileLayoutState
    extends State<RoleSelectionMobileLayout> {
  AuthUserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  void _selectRole(AuthUserRole role) {
    setState(() {
      _selectedRole = role;
    });
    if (widget.onRoleSelected != null) {
      widget.onRoleSelected!(role);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final customerBg = theme.colorScheme.secondary.withValues(
      alpha: isDark ? 0.2 : 0.12,
    );

    final providerBg = theme.colorScheme.primary.withValues(
      alpha: isDark ? 0.2 : 0.12,
    );

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Question / Subtitle
            Text(
              l10n.howWillYouUseHerfa,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 48),

            // Card 1: Customer
            RoleCard(
              title: l10n.customer,
              subtitle: l10n.customerSubtitle,
              icon: Icons.home_outlined,
              iconColor: theme.colorScheme.secondary,
              iconBackgroundColor: customerBg,
              isSelected: _selectedRole == AuthUserRole.customer,
              onTap: () => _selectRole(AuthUserRole.customer),
              onLoginTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                context.pushNamed('login');
              },
              onRegisterTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                context.pushNamed('register-customer');
              },
            ),

            const SizedBox(height: 18),

            // Card 2: Technician / Provider
            RoleCard(
              title: l10n.technician,
              subtitle: l10n.technicianSubtitle,
              icon: Icons.handyman_outlined,
              iconColor: theme.colorScheme.primary,
              iconBackgroundColor: providerBg,
              isSelected: _selectedRole == AuthUserRole.provider,
              onTap: () => _selectRole(AuthUserRole.provider),
              onLoginTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                context.pushNamed('login');
              },
              onRegisterTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                context.pushNamed('register-craftsman');
              },
            ),
          ],
        ),
      ),
    );
  }
}
