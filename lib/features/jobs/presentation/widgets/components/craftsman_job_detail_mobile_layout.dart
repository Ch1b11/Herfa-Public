import 'package:flutter/material.dart';

import '../../models/craftsman_job_detail_view_data.dart';
import '../craftsman_job_detail_cards.dart';

class CraftsmanJobDetailMobileLayout extends StatelessWidget {
  const CraftsmanJobDetailMobileLayout({
    super.key,
    required this.detail,
    required this.completedSteps,
    required this.onCompleteStep,
  });

  final CraftsmanJobDetailData detail;
  final int completedSteps;
  final VoidCallback onCompleteStep;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalPadding = (screenSize.width * 0.04).clamp(12.0, 20.0);
    final topPadding = (screenSize.height * 0.015).clamp(8.0, 16.0);
    final sectionSpacing = (screenSize.height * 0.022).clamp(14.0, 20.0);
    final bottomClearance =
        MediaQuery.paddingOf(context).bottom +
        (screenSize.height * 0.09).clamp(70.0, 85.0);
    final live = detail.copyWith(completedSteps: completedSteps);

    return FocusScope(
      autofocus: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.only(
            start: horizontalPadding,
            end: horizontalPadding,
            top: topPadding,
            bottom: bottomClearance,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CraftsmanJobDetailClientCard(detail: live),
                  SizedBox(height: sectionSpacing),
                  CraftsmanJobDetailLocationCard(detail: live),
                  SizedBox(height: sectionSpacing),
                  CraftsmanJobDetailWorkflowCard(detail: live),
                  SizedBox(height: sectionSpacing),
                  CraftsmanJobDetailInspectionCard(detail: live),
                  SizedBox(height: sectionSpacing),
                  CraftsmanJobDetailPartsCard(detail: live),
                  SizedBox(height: sectionSpacing),
                  CraftsmanJobDetailPriceCard(detail: live),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
