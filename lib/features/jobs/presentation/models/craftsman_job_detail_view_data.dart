import '../../../../l10n/app_localizations.dart';
import 'craftsman_jobs_view_data.dart';

/// One material/line item billed back to the customer.
class CraftsmanPartItem {
  final String nameKey;
  final String metaKey;
  final String priceKey;

  const CraftsmanPartItem({
    required this.nameKey,
    required this.metaKey,
    required this.priceKey,
  });

  String name(AppLocalizations l10n) => resolveCraftsmanKey(l10n, nameKey);
  String meta(AppLocalizations l10n) => resolveCraftsmanKey(l10n, metaKey);
  String price(AppLocalizations l10n) => resolveCraftsmanKey(l10n, priceKey);
}

/// A single row in the earnings breakdown.
class CraftsmanBreakdownRow {
  final String label;
  final String value;
  final bool isDeduction;
  final bool isTotal;

  const CraftsmanBreakdownRow({
    required this.label,
    required this.value,
    this.isDeduction = false,
    this.isTotal = false,
  });
}

/// Everything the job details screen renders.
class CraftsmanJobDetailData {
  final String orderId;
  final String clientKey;
  final String addressKey;
  final String issueKey;
  final String arrivalKey;
  final String distanceKey;
  final List<String> workflowStepKeys;
  final int completedSteps;
  final int totalSteps;
  final List<CraftsmanPartItem> parts;
  final bool inspectionCleared;

  const CraftsmanJobDetailData({
    required this.orderId,
    required this.clientKey,
    required this.addressKey,
    required this.issueKey,
    required this.arrivalKey,
    required this.distanceKey,
    required this.workflowStepKeys,
    required this.completedSteps,
    required this.totalSteps,
    required this.parts,
    required this.inspectionCleared,
  });

  String client(AppLocalizations l10n) => resolveCraftsmanKey(l10n, clientKey);
  String address(AppLocalizations l10n) =>
      resolveCraftsmanKey(l10n, addressKey);
  String issue(AppLocalizations l10n) => resolveCraftsmanKey(l10n, issueKey);
  String arrival(AppLocalizations l10n) =>
      resolveCraftsmanKey(l10n, arrivalKey);
  String distance(AppLocalizations l10n) =>
      resolveCraftsmanKey(l10n, distanceKey);

  double get progress => totalSteps > 0 ? completedSteps / totalSteps : 0.0;

  /// Localized labels for the workflow steps of this job.
  List<String> workflowSteps(AppLocalizations l10n) {
    return workflowStepKeys
        .map((key) => resolveCraftsmanKey(l10n, key))
        .toList();
  }

  /// Returns a copy with the workflow progress advanced (used by the UI).
  CraftsmanJobDetailData copyWith({int? completedSteps}) {
    return CraftsmanJobDetailData(
      orderId: orderId,
      clientKey: clientKey,
      addressKey: addressKey,
      issueKey: issueKey,
      arrivalKey: arrivalKey,
      distanceKey: distanceKey,
      workflowStepKeys: workflowStepKeys,
      completedSteps: completedSteps ?? this.completedSteps,
      totalSteps: totalSteps,
      parts: parts,
      inspectionCleared: inspectionCleared,
    );
  }
}

/// Default fallback job details specification.
const craftsmanDefaultJobDetail = CraftsmanJobDetailData(
  orderId: '#HRF-8492',
  clientKey: 'craftsmanActiveJobClientName',
  addressKey: 'craftsmanActiveJobClientAddress',
  issueKey: 'craftsmanActiveJobIssueTitle',
  arrivalKey: 'craftsmanJobsSlotMorning',
  distanceKey: 'craftsmanRequest1Distance',
  workflowStepKeys: [
    'quoteStepRequested',
    'quoteStepAiAnalysis',
    'quoteStepTechAssigned',
    'quoteStepEnRoute',
    'quoteStepArrived',
    'quoteStepDiagnosed',
    'quoteStepAwaitingApproval',
    'quoteStepStartRepair',
    'quoteStepEfficiencyTest',
    'quoteStepDigitalReport',
    'quoteStepPaymentWarranty',
  ],
  completedSteps: 5,
  totalSteps: 11,
  parts: [
    CraftsmanPartItem(
      nameKey: 'craftsmanDetailPart1Name',
      metaKey: 'craftsmanDetailPart1Meta',
      priceKey: 'craftsmanDetailPart1Price',
    ),
    CraftsmanPartItem(
      nameKey: 'craftsmanDetailPart2Name',
      metaKey: 'craftsmanDetailPart2Meta',
      priceKey: 'craftsmanDetailPart2Price',
    ),
    CraftsmanPartItem(
      nameKey: 'craftsmanDetailPart3Name',
      metaKey: 'craftsmanDetailPart3Meta',
      priceKey: 'craftsmanDetailPart3Price',
    ),
  ],
  inspectionCleared: true,
);

/// Builds the localized earnings breakdown for the job details screen.
List<CraftsmanBreakdownRow> craftsmanBreakdown(AppLocalizations l10n) {
  return [
    CraftsmanBreakdownRow(
      label: l10n.craftsmanDetailLaborItem,
      value: '220 EGP',
    ),
    CraftsmanBreakdownRow(
      label: l10n.craftsmanDetailPartsItem,
      value: '325 EGP',
    ),
    CraftsmanBreakdownRow(
      label: l10n.craftsmanDetailCommissionItem,
      value: '- 61 EGP',
      isDeduction: true,
    ),
    CraftsmanBreakdownRow(
      label: l10n.craftsmanDetailNetLabel,
      value: '484 EGP',
      isTotal: true,
    ),
  ];
}
