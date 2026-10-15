import 'package:flutter/material.dart';

import '../../models/craftsman_job_detail_view_data.dart';
import '../craftsman_job_detail_cards.dart';

class CraftsmanJobDetailTabletLayout extends StatelessWidget {
  const CraftsmanJobDetailTabletLayout({
    super.key,
    required this.detail,
    required this.completedSteps,
  });

  final CraftsmanJobDetailData detail;
  final int completedSteps;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalPadding = (screenSize.width * 0.06).clamp(24.0, 48.0);
    final topPadding = (screenSize.height * 0.02).clamp(14.0, 24.0);
    final sectionSpacing = (screenSize.height * 0.022).clamp(18.0, 24.0);
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
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            CraftsmanJobDetailClientCard(detail: live),
                            SizedBox(height: sectionSpacing),
                            CraftsmanJobDetailLocationCard(detail: live),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            CraftsmanJobDetailInspectionCard(detail: live),
                            SizedBox(height: sectionSpacing),
                            CraftsmanJobDetailPartsCard(detail: live),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: CraftsmanJobDetailWorkflowCard(detail: live),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 5,
                        child: CraftsmanJobDetailPriceCard(detail: live),
                      ),
                    ],
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
