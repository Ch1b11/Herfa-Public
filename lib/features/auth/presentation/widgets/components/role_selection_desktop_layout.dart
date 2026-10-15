import 'package:flutter/material.dart';
import '../role_card.dart';
import 'role_selection_mobile_layout.dart';

class RoleSelectionDesktopLayout extends StatelessWidget {
  final ValueChanged<AuthUserRole>? onRoleSelected;

  const RoleSelectionDesktopLayout({
    super.key,
    this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: RoleSelectionMobileLayout(
          onRoleSelected: onRoleSelected,
        ),
      ),
    );
  }
}
