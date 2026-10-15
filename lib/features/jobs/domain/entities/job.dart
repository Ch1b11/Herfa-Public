import 'package:equatable/equatable.dart';

enum JobStatus {
  scheduled,
  onTheWay,
  inProgress,
  pending,
  completed,
}

class Job extends Equatable {
  final String id;
  final String title;
  final String clientName;
  final String? clientPhone;
  final String location;
  final String district;
  final double price;
  final JobStatus status;
  final int progressStep;
  final int totalSteps;
  final DateTime scheduledDate;
  final String? description;
  final String? technicianName;
  final String? technicianPhone;
  final String? technicianTitle;
  final double? technicianRating;
  final int? technicianJobsCount;

  const Job({
    required this.id,
    required this.title,
    required this.clientName,
    this.clientPhone,
    required this.location,
    required this.district,
    required this.price,
    required this.status,
    this.progressStep = 0,
    this.totalSteps = 4,
    required this.scheduledDate,
    this.description,
    this.technicianName,
    this.technicianPhone,
    this.technicianTitle,
    this.technicianRating,
    this.technicianJobsCount,
  });

  bool get hasProgress => totalSteps > 0;

  @override
  List<Object?> get props => [
        id,
        title,
        clientName,
        clientPhone,
        location,
        district,
        price,
        status,
        progressStep,
        totalSteps,
        scheduledDate,
        description,
        technicianName,
        technicianPhone,
        technicianTitle,
        technicianRating,
        technicianJobsCount,
      ];
}
