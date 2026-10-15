import 'package:equatable/equatable.dart';

import '../../domain/entities/job.dart';

abstract class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCraftsmanJobs extends JobsEvent {
  final JobStatus? status;
  final bool forceRefresh;

  const FetchCraftsmanJobs({this.status, this.forceRefresh = false});

  @override
  List<Object?> get props => [status, forceRefresh];
}

class FetchJobDetail extends JobsEvent {
  final String jobId;

  const FetchJobDetail({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

class UpdateJobProgress extends JobsEvent {
  final String jobId;
  final JobStatus status;
  final int? progressStep;

  const UpdateJobProgress({
    required this.jobId,
    required this.status,
    this.progressStep,
  });

  @override
  List<Object?> get props => [jobId, status, progressStep];
}

class AcceptJob extends JobsEvent {
  final String jobId;

  const AcceptJob(this.jobId);

  @override
  List<Object?> get props => [jobId];
}
