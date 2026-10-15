import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/job.dart';

/// Lifecycle buckets used by the craftsman jobs screen.
enum CraftsmanJobStatus { scheduled, onTheWay, inProgress, pending, completed }

/// The three top-level tabs of the jobs screen.
enum CraftsmanJobsTab { active, incoming, completed }

/// A single job row rendered across the craftsman jobs screen.
class CraftsmanJobItem {
  final String orderId;
  final String clientKey;
  final String issueKey;
  final String distanceKey;
  final String priceKey;
  final CraftsmanJobStatus status;
  final int progressStep;
  final int totalSteps;
  final String dayLabelKey;
  final String slotLabelKey;

  const CraftsmanJobItem({
    required this.orderId,
    required this.clientKey,
    required this.issueKey,
    required this.distanceKey,
    required this.priceKey,
    required this.status,
    this.progressStep = 0,
    this.totalSteps = 0,
    this.dayLabelKey = '',
    this.slotLabelKey = '',
  });

  factory CraftsmanJobItem.fromJob(Job job) {
    CraftsmanJobStatus mapStatus(JobStatus s) {
      switch (s) {
        case JobStatus.pending:
          return CraftsmanJobStatus.pending;
        case JobStatus.scheduled:
          return CraftsmanJobStatus.scheduled;
        case JobStatus.onTheWay:
          return CraftsmanJobStatus.onTheWay;
        case JobStatus.inProgress:
          return CraftsmanJobStatus.inProgress;
        case JobStatus.completed:
          return CraftsmanJobStatus.completed;
      }
    }

    final id = job.id.startsWith('#')
        ? job.id
        : '#${job.id.length > 8 ? job.id.substring(0, 8).toUpperCase() : job.id}';

    final formattedPrice =
        '${job.price.toStringAsFixed(job.price.truncateToDouble() == job.price ? 0 : 2)} ج.م';

    return CraftsmanJobItem(
      orderId: id,
      clientKey: job.clientName,
      issueKey: job.title.isNotEmpty ? job.title : 'طلب صيانة',
      distanceKey: job.district.isNotEmpty
          ? job.district
          : (job.location.isNotEmpty ? job.location : 'القاهرة'),
      priceKey: formattedPrice,
      status: mapStatus(job.status),
      progressStep: job.progressStep,
      totalSteps: job.totalSteps,
    );
  }

  String client(AppLocalizations l10n) => resolveCraftsmanKey(l10n, clientKey);
  String issue(AppLocalizations l10n) => resolveCraftsmanKey(l10n, issueKey);
  String distance(AppLocalizations l10n) =>
      resolveCraftsmanKey(l10n, distanceKey);
  String price(AppLocalizations l10n) => resolveCraftsmanKey(l10n, priceKey);
  String dayLabel(AppLocalizations l10n) =>
      resolveCraftsmanKey(l10n, dayLabelKey);
  String slotLabel(AppLocalizations l10n) =>
      resolveCraftsmanKey(l10n, slotLabelKey);

  bool get hasProgress => totalSteps > 0;

  String statusLabel(AppLocalizations l10n) {
    switch (status) {
      case CraftsmanJobStatus.scheduled:
        return l10n.craftsmanJobsStatusScheduled;
      case CraftsmanJobStatus.onTheWay:
        return l10n.craftsmanJobsStatusOnTheWay;
      case CraftsmanJobStatus.inProgress:
        return l10n.craftsmanJobsStatusInProgress;
      case CraftsmanJobStatus.pending:
        return l10n.craftsmanJobsStatusPending;
      case CraftsmanJobStatus.completed:
        return l10n.craftsmanJobsStatusCompleted;
    }
  }
}

/// Active craftsman jobs fallback list.
const craftsmanActiveJobs = <CraftsmanJobItem>[
  CraftsmanJobItem(
    orderId: '#HRF-8492',
    clientKey: 'craftsmanActiveJobClientName',
    issueKey: 'craftsmanActiveJobIssueTitle',
    distanceKey: 'craftsmanRequest1Distance',
    priceKey: 'craftsmanDetailPart1Price',
    status: CraftsmanJobStatus.inProgress,
    progressStep: 2,
    totalSteps: 4,
    dayLabelKey: 'craftsmanJobsTodayLabel',
    slotLabelKey: 'craftsmanJobsSlotMorning',
  ),
  CraftsmanJobItem(
    orderId: '#HRF-8511',
    clientKey: 'craftsmanJob4Client',
    issueKey: 'craftsmanJob4Issue',
    distanceKey: 'craftsmanJob4Distance',
    priceKey: 'craftsmanProfileService1Price',
    status: CraftsmanJobStatus.onTheWay,
    dayLabelKey: 'craftsmanJobsTodayLabel',
    slotLabelKey: 'craftsmanJobsSlotEvening',
  ),
  CraftsmanJobItem(
    orderId: '#HRF-8523',
    clientKey: 'craftsmanJob5Client',
    issueKey: 'craftsmanJob5Issue',
    distanceKey: 'craftsmanJob5Distance',
    priceKey: 'craftsmanDetailPart2Price',
    status: CraftsmanJobStatus.scheduled,
    dayLabelKey: 'craftsmanJobsTomorrowLabel',
    slotLabelKey: 'craftsmanJobsSlotMorning',
  ),
];

/// Incoming broadcast requests fallback list.
const craftsmanIncomingJobs = <CraftsmanJobItem>[
  CraftsmanJobItem(
    orderId: '#HRF-8530',
    clientKey: 'craftsmanRequest1Name',
    issueKey: 'craftsmanRequest1Issue',
    distanceKey: 'craftsmanRequest1Distance',
    priceKey: 'craftsmanRequest1Price',
    status: CraftsmanJobStatus.pending,
  ),
  CraftsmanJobItem(
    orderId: '#HRF-8531',
    clientKey: 'craftsmanRequest2Name',
    issueKey: 'craftsmanRequest2Issue',
    distanceKey: 'craftsmanRequest2Distance',
    priceKey: 'craftsmanRequest2Price',
    status: CraftsmanJobStatus.pending,
  ),
  CraftsmanJobItem(
    orderId: '#HRF-8532',
    clientKey: 'craftsmanJob6Client',
    issueKey: 'craftsmanJob6Issue',
    distanceKey: 'craftsmanJob6Distance',
    priceKey: 'craftsmanProfileService3Price',
    status: CraftsmanJobStatus.pending,
  ),
];

/// Historical completed jobs fallback list.
const craftsmanCompletedJobs = <CraftsmanJobItem>[
  CraftsmanJobItem(
    orderId: '#HRF-8480',
    clientKey: 'craftsmanRecent1Client',
    issueKey: 'craftsmanRecent1Title',
    distanceKey: 'craftsmanRequest2Distance',
    priceKey: 'craftsmanRecent1Price',
    status: CraftsmanJobStatus.completed,
    progressStep: 4,
    totalSteps: 4,
  ),
  CraftsmanJobItem(
    orderId: '#HRF-8455',
    clientKey: 'craftsmanRecent2Client',
    issueKey: 'craftsmanRecent2Title',
    distanceKey: 'craftsmanRequest1Distance',
    priceKey: 'craftsmanRecent2Price',
    status: CraftsmanJobStatus.completed,
    progressStep: 3,
    totalSteps: 3,
  ),
  CraftsmanJobItem(
    orderId: '#HRF-8431',
    clientKey: 'craftsmanRecent3Client',
    issueKey: 'craftsmanRecent3Title',
    distanceKey: 'craftsmanJob4Distance',
    priceKey: 'craftsmanRecent3Price',
    status: CraftsmanJobStatus.completed,
    progressStep: 2,
    totalSteps: 2,
  ),
];

List<CraftsmanJobItem> jobsForTab(CraftsmanJobsTab tab) {
  switch (tab) {
    case CraftsmanJobsTab.active:
      return craftsmanActiveJobs;
    case CraftsmanJobsTab.incoming:
      return craftsmanIncomingJobs;
    case CraftsmanJobsTab.completed:
      return craftsmanCompletedJobs;
  }
}

String craftsmanJobsTabLabel(AppLocalizations l10n, CraftsmanJobsTab tab) {
  switch (tab) {
    case CraftsmanJobsTab.active:
      return l10n.craftsmanJobsTabActive;
    case CraftsmanJobsTab.incoming:
      return l10n.craftsmanJobsTabIncoming;
    case CraftsmanJobsTab.completed:
      return l10n.craftsmanJobsTabCompleted;
  }
}

String resolveCraftsmanKey(AppLocalizations l10n, String key) {
  switch (key) {
    case 'craftsmanProfileName':
      return l10n.craftsmanProfileName;
    case 'craftsmanProfileNameAvatars':
      return l10n.craftsmanProfileNameAvatars;
    case 'craftsmanProfileSpecialization':
      return l10n.craftsmanProfileSpecialization;
    case 'craftsmanProfileRatingBadge':
      return l10n.craftsmanProfileRatingBadge;
    case 'craftsmanProfileJobsBadge':
      return l10n.craftsmanProfileJobsBadge;
    case 'craftsmanProfileSatisfactionBadge':
      return l10n.craftsmanProfileSatisfactionBadge;
    case 'craftsmanAvailabilityTitle':
      return l10n.craftsmanAvailabilityTitle;
    case 'craftsmanAvailabilityAvailable':
      return l10n.craftsmanAvailabilityAvailable;
    case 'craftsmanAvailabilityBusy':
      return l10n.craftsmanAvailabilityBusy;
    case 'craftsmanAvailabilityToastAvailable':
      return l10n.craftsmanAvailabilityToastAvailable;
    case 'craftsmanAvailabilityToastBusy':
      return l10n.craftsmanAvailabilityToastBusy;
    case 'craftsmanActiveJobTitle':
      return l10n.craftsmanActiveJobTitle;
    case 'craftsmanActiveJobClientLabel':
      return l10n.craftsmanActiveJobClientLabel;
    case 'craftsmanActiveJobOrderLabel':
      return l10n.craftsmanActiveJobOrderLabel;
    case 'craftsmanActiveJobProgress':
      return l10n.craftsmanActiveJobProgress;
    case 'craftsmanActiveJobCompleteStep':
      return l10n.craftsmanActiveJobCompleteStep;
    case 'craftsmanActiveJobDoneBadge':
      return l10n.craftsmanActiveJobDoneBadge;
    case 'craftsmanActiveJobStepDoneToast':
      return l10n.craftsmanActiveJobStepDoneToast;
    case 'craftsmanActiveJobViewChat':
      return l10n.craftsmanActiveJobViewChat;
    case 'craftsmanActiveJobIssueTitle':
      return l10n.craftsmanActiveJobIssueTitle;
    case 'craftsmanActiveJobClientName':
      return l10n.craftsmanActiveJobClientName;
    case 'craftsmanActiveJobClientAddress':
      return l10n.craftsmanActiveJobClientAddress;
    case 'craftsmanEarningsTitle':
      return l10n.craftsmanEarningsTitle;
    case 'craftsmanEarningsAvailableBadge':
      return l10n.craftsmanEarningsAvailableBadge;
    case 'craftsmanEarningsToday':
      return l10n.craftsmanEarningsToday;
    case 'craftsmanEarningsWeek':
      return l10n.craftsmanEarningsWeek;
    case 'craftsmanEarningsTodayValue':
      return l10n.craftsmanEarningsTodayValue;
    case 'craftsmanEarningsWeekValue':
      return l10n.craftsmanEarningsWeekValue;
    case 'craftsmanEarningsWithdraw':
      return l10n.craftsmanEarningsWithdraw;
    case 'craftsmanEarningsWithdrawToast':
      return l10n.craftsmanEarningsWithdrawToast;
    case 'craftsmanEarningsPayoutNote':
      return l10n.craftsmanEarningsPayoutNote;
    case 'craftsmanIncomingTitle':
      return l10n.craftsmanIncomingTitle;
    case 'craftsmanIncomingSubtitle':
      return l10n.craftsmanIncomingSubtitle;
    case 'craftsmanIncomingAccept':
      return l10n.craftsmanIncomingAccept;
    case 'craftsmanIncomingDecline':
      return l10n.craftsmanIncomingDecline;
    case 'craftsmanIncomingAcceptedToast':
      return l10n.craftsmanIncomingAcceptedToast;
    case 'craftsmanIncomingDeclinedToast':
      return l10n.craftsmanIncomingDeclinedToast;
    case 'craftsmanIncomingAcceptedChip':
      return l10n.craftsmanIncomingAcceptedChip;
    case 'craftsmanIncomingDeclinedChip':
      return l10n.craftsmanIncomingDeclinedChip;
    case 'craftsmanRecentTitle':
      return l10n.craftsmanRecentTitle;
    case 'craftsmanRecentViewAll':
      return l10n.craftsmanRecentViewAll;
    case 'craftsmanSwitchToCustomer':
      return l10n.craftsmanSwitchToCustomer;
    case 'craftsmanRequest1Name':
      return l10n.craftsmanRequest1Name;
    case 'craftsmanRequest1Issue':
      return l10n.craftsmanRequest1Issue;
    case 'craftsmanRequest1Price':
      return l10n.craftsmanRequest1Price;
    case 'craftsmanRequest1Distance':
      return l10n.craftsmanRequest1Distance;
    case 'craftsmanRequest2Name':
      return l10n.craftsmanRequest2Name;
    case 'craftsmanRequest2Issue':
      return l10n.craftsmanRequest2Issue;
    case 'craftsmanRequest2Price':
      return l10n.craftsmanRequest2Price;
    case 'craftsmanRequest2Distance':
      return l10n.craftsmanRequest2Distance;
    case 'craftsmanRecent1Title':
      return l10n.craftsmanRecent1Title;
    case 'craftsmanRecent1Client':
      return l10n.craftsmanRecent1Client;
    case 'craftsmanRecent1Price':
      return l10n.craftsmanRecent1Price;
    case 'craftsmanRecent2Title':
      return l10n.craftsmanRecent2Title;
    case 'craftsmanRecent2Client':
      return l10n.craftsmanRecent2Client;
    case 'craftsmanRecent2Price':
      return l10n.craftsmanRecent2Price;
    case 'craftsmanRecent3Title':
      return l10n.craftsmanRecent3Title;
    case 'craftsmanRecent3Client':
      return l10n.craftsmanRecent3Client;
    case 'craftsmanRecent3Price':
      return l10n.craftsmanRecent3Price;
    case 'craftsmanJob4Client':
      return l10n.craftsmanJob4Client;
    case 'craftsmanJob4Issue':
      return l10n.craftsmanJob4Issue;
    case 'craftsmanJob4Distance':
      return l10n.craftsmanJob4Distance;
    case 'craftsmanJob5Client':
      return l10n.craftsmanJob5Client;
    case 'craftsmanJob5Issue':
      return l10n.craftsmanJob5Issue;
    case 'craftsmanJob5Distance':
      return l10n.craftsmanJob5Distance;
    case 'craftsmanJob6Client':
      return l10n.craftsmanJob6Client;
    case 'craftsmanJob6Issue':
      return l10n.craftsmanJob6Issue;
    case 'craftsmanJob6Distance':
      return l10n.craftsmanJob6Distance;
    case 'craftsmanJobsTodayLabel':
      return l10n.craftsmanJobsTodayLabel;
    case 'craftsmanJobsTomorrowLabel':
      return l10n.craftsmanJobsTomorrowLabel;
    case 'craftsmanJobsSlotMorning':
      return l10n.craftsmanJobsSlotMorning;
    case 'craftsmanJobsSlotEvening':
      return l10n.craftsmanJobsSlotEvening;
    case 'craftsmanDetailPart1Price':
      return l10n.craftsmanDetailPart1Price;
    case 'craftsmanDetailPart2Price':
      return l10n.craftsmanDetailPart2Price;
    case 'craftsmanDetailPart3Price':
      return l10n.craftsmanDetailPart3Price;
    case 'craftsmanProfileService1Price':
      return l10n.craftsmanProfileService1Price;
    case 'craftsmanProfileService2Price':
      return l10n.craftsmanProfileService2Price;
    case 'craftsmanProfileService3Price':
      return l10n.craftsmanProfileService3Price;
    case 'craftsmanEarningsTodayEgp':
      return l10n.craftsmanEarningsTodayValue;
    case 'craftsmanEarningsWeekEgp':
      return l10n.craftsmanEarningsWeekValue;
    case 'craftsmanDetailPart1Name':
      return l10n.craftsmanDetailPart1Name;
    case 'craftsmanDetailPart1Meta':
      return l10n.craftsmanDetailPart1Meta;
    case 'craftsmanDetailPart2Name':
      return l10n.craftsmanDetailPart2Name;
    case 'craftsmanDetailPart2Meta':
      return l10n.craftsmanDetailPart2Meta;
    case 'craftsmanDetailPart3Name':
      return l10n.craftsmanDetailPart3Name;
    case 'craftsmanDetailPart3Meta':
      return l10n.craftsmanDetailPart3Meta;
    case 'craftsmanEarningsTxn1Title':
      return l10n.craftsmanEarningsTxn1Title;
    case 'craftsmanEarningsTxn2Title':
      return l10n.craftsmanEarningsTxn2Title;
    case 'craftsmanEarningsTxn3Title':
      return l10n.craftsmanEarningsTxn3Title;
    case 'craftsmanEarningsTxn4Title':
      return l10n.craftsmanEarningsTxn4Title;
    case 'chatBadgeValidId':
      return l10n.chatBadgeValidId;
    case 'chatBadgeElectronicTools':
      return l10n.chatBadgeElectronicTools;
    case 'chatBadgeCleanRecord':
      return l10n.chatBadgeCleanRecord;
    case 'craftsmanProfileCert1':
      return l10n.craftsmanProfileCert1;
    case 'craftsmanProfileCert2':
      return l10n.craftsmanProfileCert2;
    case 'craftsmanProfileCert3':
      return l10n.craftsmanProfileCert3;
    case 'craftsmanProfileCert4':
      return l10n.craftsmanProfileCert4;
    case 'craftsmanProfileReview1':
      return l10n.craftsmanProfileReview1;
    case 'craftsmanProfileReview1Author':
      return l10n.craftsmanProfileReview1Author;
    case 'craftsmanProfileReview2':
      return l10n.craftsmanProfileReview2;
    case 'craftsmanProfileReview2Author':
      return l10n.craftsmanProfileReview2Author;
    case 'craftsmanProfileReview3':
      return l10n.craftsmanProfileReview3;
    case 'craftsmanProfileReview3Author':
      return l10n.craftsmanProfileReview3Author;
    case 'craftsmanProfilePortfolio1':
      return l10n.craftsmanProfilePortfolio1;
    case 'craftsmanProfilePortfolio2':
      return l10n.craftsmanProfilePortfolio2;
    case 'craftsmanProfilePortfolio3':
      return l10n.craftsmanProfilePortfolio3;
    case 'craftsmanProfileService1':
      return l10n.craftsmanProfileService1;
    case 'craftsmanProfileService2':
      return l10n.craftsmanProfileService2;
    case 'craftsmanProfileService2PriceMeta':
      return l10n.craftsmanProfileService2PriceMeta;
    case 'craftsmanProfileService3':
      return l10n.craftsmanProfileService3;
    case 'craftsmanProfileService3PriceMeta':
      return l10n.craftsmanProfileService3PriceMeta;
    case 'craftsmanProfileSupport1':
      return l10n.craftsmanProfileSupport1;
    case 'craftsmanProfileSupport2':
      return l10n.craftsmanProfileSupport2;
    case 'craftsmanProfileSupport3':
      return l10n.craftsmanProfileSupport3;
    case 'quoteStepRequested':
      return l10n.quoteStepRequested;
    case 'quoteStepTechAssigned':
      return l10n.quoteStepTechAssigned;
    case 'quoteStepEnRoute':
      return l10n.quoteStepEnRoute;
    case 'quoteStepAwaitingApproval':
      return l10n.quoteStepAwaitingApproval;
    case 'quoteStepDiagnosed':
      return l10n.quoteStepDiagnosed;
    case 'quoteStepAiAnalysis':
      return l10n.quoteStepAiAnalysis;
    case 'quoteStepDigitalReport':
      return l10n.quoteStepDigitalReport;
    case 'quoteStepArrived':
      return l10n.quoteStepArrived;
    case 'quoteStepStartRepair':
      return l10n.quoteStepStartRepair;
    case 'quoteStepEfficiencyTest':
      return l10n.quoteStepEfficiencyTest;
    case 'quoteStepPaymentWarranty':
      return l10n.quoteStepPaymentWarranty;
    default:
      return key;
  }
}
