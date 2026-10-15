import 'package:flutter/material.dart';

import '../../models/craftsman_job_detail_view_data.dart';
import '../craftsman_job_detail_cards.dart';

class CraftsmanJobDetailDesktopLayout extends StatelessWidget {
  const CraftsmanJobDetailDesktopLayout({
    super.key,
    required this.detail,
    required this.completedSteps,
  });

  final CraftsmanJobDetailData detail;
  final int completedSteps;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalPadding = (screenSize.width * 0.07).clamp(32.0, 64.0);
    final topPadding = (screenSize.height * 0.025).clamp(20.0, 32.0);
    final sectionSpacing = (screenSize.height * 0.022).clamp(20.0, 26.0);
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 100.0;
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
            bottom: bottomPadding,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        CraftsmanJobDetailClientCard(detail: live),
                        SizedBox(height: sectionSpacing),
                        CraftsmanJobDetailLocationCard(detail: live),
                        SizedBox(height: sectionSpacing),
                        CraftsmanJobDetailInspectionCard(detail: live),
                      ],
                    ),
                  ),
                  SizedBox(width: sectionSpacing),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        CraftsmanJobDetailWorkflowCard(detail: live),
                        SizedBox(height: sectionSpacing),
                        CraftsmanJobDetailPartsCard(detail: live),
                        SizedBox(height: sectionSpacing),
                        CraftsmanJobDetailPriceCard(detail: live),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
