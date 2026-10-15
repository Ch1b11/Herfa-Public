import '../../domain/entities/job.dart';

class JobModel extends Job {
  const JobModel({
    required super.id,
    required super.title,
    required super.clientName,
    super.clientPhone,
    required super.location,
    required super.district,
    required super.price,
    required super.status,
    super.progressStep = 0,
    super.totalSteps = 4,
    required super.scheduledDate,
    super.description,
    super.technicianName,
    super.technicianPhone,
    super.technicianTitle,
    super.technicianRating,
    super.technicianJobsCount,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // 1. Parse status first so we can use it for fallback progress step
    final status = _statusFromString(json['status'] as String?);

    // 2. Parse price/budget supporting both num and String
    final priceRaw = json['price'] ?? json['budget'];
    final double price;
    if (priceRaw is num) {
      price = priceRaw.toDouble();
    } else if (priceRaw is String) {
      price = double.tryParse(priceRaw) ?? 0.0;
    } else {
      price = 0.0;
    }

    // 3. Extract client name & phone, supporting nested 'customer' entity
    String clientName = '';
    String? clientPhone;
    if (json['customer'] is Map<String, dynamic>) {
      final customer = json['customer'] as Map<String, dynamic>;
      final first = (customer['firstName'] as String?)?.trim() ?? '';
      final last = (customer['lastName'] as String?)?.trim() ?? '';
      clientName = '$first $last'.trim();
      clientPhone = customer['phone'] as String?;
    }
    if (clientName.isEmpty && json['clientName'] != null) {
      clientName = (json['clientName'] as String).trim();
    }
    if (clientName.isEmpty) {
      clientName = 'عميل';
    }
    if (clientPhone == null && json['clientPhone'] != null) {
      clientPhone = json['clientPhone'] as String?;
    }

    // 4. Extract location and district safely
    String location = (json['location'] as String?)?.trim() ?? '';
    String district = (json['district'] as String?)?.trim() ?? '';
    if (location.isEmpty && json['provider'] is Map<String, dynamic>) {
      final provider = json['provider'] as Map<String, dynamic>;
      location = (provider['city'] as String?)?.trim() ?? '';
    }
    if (location.isEmpty) {
      location = (json['city'] as String?)?.trim() ?? 'المعادي';
    }
    if (district.isEmpty) {
      district = location;
    }

    // 5. Total and progress steps
    final totalSteps = (json['totalSteps'] as num?)?.toInt() ?? 4;
    final int progressStep;
    if (json['progressStep'] != null) {
      progressStep = (json['progressStep'] as num).toInt();
    } else {
      switch (status) {
        case JobStatus.pending:
          progressStep = 0;
          break;
        case JobStatus.scheduled:
          progressStep = 1;
          break;
        case JobStatus.onTheWay:
          progressStep = 2;
          break;
        case JobStatus.inProgress:
          progressStep = 3;
          break;
        case JobStatus.completed:
          progressStep = totalSteps;
          break;
      }
    }

    // 6. Scheduled date parsing with fallbacks
    final scheduledDateRaw =
        json['scheduledDate'] ?? json['scheduledAt'] ?? json['createdAt'];
    final DateTime scheduledDate;
    if (scheduledDateRaw is String) {
      scheduledDate = DateTime.tryParse(scheduledDateRaw) ?? DateTime.now();
    } else {
      scheduledDate = DateTime.now();
    }

    // 7. Defensive parsing of nested provider & provider.user relations
    String? technicianName = json['technicianName'] as String?;
    String? technicianPhone = json['technicianPhone'] as String?;
    String? technicianTitle = json['technicianTitle'] as String?;
    double? technicianRating;
    if (json['technicianRating'] is num) {
      technicianRating = (json['technicianRating'] as num).toDouble();
    } else if (json['technicianRating'] is String) {
      technicianRating = double.tryParse(json['technicianRating'] as String);
    }
    int? technicianJobsCount;
    if (json['technicianJobsCount'] is num) {
      technicianJobsCount = (json['technicianJobsCount'] as num).toInt();
    } else if (json['technicianJobsCount'] is String) {
      technicianJobsCount = int.tryParse(json['technicianJobsCount'] as String);
    }

    if (json['provider'] is Map<String, dynamic>) {
      final provider = json['provider'] as Map<String, dynamic>;

      if (technicianTitle == null || technicianTitle.isEmpty) {
        final bName = (provider['businessName'] as String?)?.trim();
        final cat = (provider['category'] as String?)?.trim();
        technicianTitle = (bName != null && bName.isNotEmpty) ? bName : cat;
      }

      if (technicianRating == null) {
        final avgRatingRaw = provider['avgRating'];
        if (avgRatingRaw is num) {
          technicianRating = avgRatingRaw.toDouble();
        } else if (avgRatingRaw is String) {
          technicianRating = double.tryParse(avgRatingRaw);
        }
      }

      if (technicianJobsCount == null) {
        final totalReviewsRaw = provider['totalReviews'];
        if (totalReviewsRaw is num) {
          technicianJobsCount = totalReviewsRaw.toInt();
        } else if (totalReviewsRaw is String) {
          technicianJobsCount = int.tryParse(totalReviewsRaw);
        }
      }

      if (provider['user'] is Map<String, dynamic>) {
        final pUser = provider['user'] as Map<String, dynamic>;
        final fName = (pUser['firstName'] as String?)?.trim() ?? '';
        final lName = (pUser['lastName'] as String?)?.trim() ?? '';
        final pFullName = '$fName $lName'.trim();
        if (technicianName == null && pFullName.isNotEmpty) {
          technicianName = pFullName;
        }
        technicianPhone ??= pUser['phone'] as String?;
      }

      if (technicianName == null && technicianTitle != null && technicianTitle.isNotEmpty) {
        technicianName = technicianTitle;
      }
    }

    return JobModel(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      clientName: clientName,
      clientPhone: clientPhone,
      location: location,
      district: district,
      price: price,
      status: status,
      progressStep: progressStep,
      totalSteps: totalSteps,
      scheduledDate: scheduledDate,
      description: json['description'] as String?,
      technicianName: technicianName,
      technicianPhone: technicianPhone,
      technicianTitle: technicianTitle,
      technicianRating: technicianRating,
      technicianJobsCount: technicianJobsCount,
    );
  }

  static JobStatus _statusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'ontheway':
      case 'on_the_way':
        return JobStatus.onTheWay;
      case 'inprogress':
      case 'in_progress':
        return JobStatus.inProgress;
      case 'pending':
        return JobStatus.pending;
      case 'completed':
        return JobStatus.completed;
      case 'cancelled':
        return JobStatus.completed;
      case 'accepted':
      case 'scheduled':
      default:
        return JobStatus.scheduled;
    }
  }

  static String _statusToString(JobStatus status) {
    switch (status) {
      case JobStatus.onTheWay:
        return 'onTheWay';
      case JobStatus.inProgress:
        return 'inProgress';
      case JobStatus.pending:
        return 'pending';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.scheduled:
        return 'scheduled';
    }
  }

  static String toBackendStatus(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return 'pending';
      case JobStatus.scheduled:
        return 'accepted';
      case JobStatus.onTheWay:
      case JobStatus.inProgress:
        return 'in_progress';
      case JobStatus.completed:
        return 'completed';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'location': location,
      'district': district,
      'price': price,
      'status': _statusToString(status),
      'progressStep': progressStep,
      'totalSteps': totalSteps,
      'scheduledDate': scheduledDate.toIso8601String(),
      'description': description,
      'technicianName': technicianName,
      'technicianPhone': technicianPhone,
      'technicianTitle': technicianTitle,
      'technicianRating': technicianRating,
      'technicianJobsCount': technicianJobsCount,
    };
  }

  factory JobModel.fromEntity(Job entity) {
    return JobModel(
      id: entity.id,
      title: entity.title,
      clientName: entity.clientName,
      clientPhone: entity.clientPhone,
      location: entity.location,
      district: entity.district,
      price: entity.price,
      status: entity.status,
      progressStep: entity.progressStep,
      totalSteps: entity.totalSteps,
      scheduledDate: entity.scheduledDate,
      description: entity.description,
      technicianName: entity.technicianName,
      technicianPhone: entity.technicianPhone,
      technicianTitle: entity.technicianTitle,
      technicianRating: entity.technicianRating,
      technicianJobsCount: entity.technicianJobsCount,
    );
  }
}
