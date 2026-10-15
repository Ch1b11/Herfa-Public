import 'package:flutter/material.dart';

import '../../../../core/layout_manager/adaptive_layout_manager.dart';
import '../widgets/components/role_selection_desktop_layout.dart';
import '../widgets/components/role_selection_mobile_layout.dart';
import '../widgets/components/role_selection_tablet_layout.dart';
import '../widgets/role_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  final ValueChanged<AuthUserRole>? onRoleSelected;

  const RoleSelectionScreen({
    super.key,
    this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutManager(
      mobileLayout: (context) => RoleSelectionMobileLayout(
        onRoleSelected: onRoleSelected,
      ),
      tabletLayout: (context) => RoleSelectionTabletLayout(
        onRoleSelected: onRoleSelected,
      ),
      desktopLayout: (context) => RoleSelectionDesktopLayout(
        onRoleSelected: onRoleSelected,
      ),
    );
  }
}
