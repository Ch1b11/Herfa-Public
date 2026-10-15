import 'package:equatable/equatable.dart';

import '../../domain/entities/job.dart';

abstract class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object?> get props => [];
}

class JobsInitial extends JobsState {
  const JobsInitial();
}

class JobsLoading extends JobsState {
  const JobsLoading();
}

class JobsLoaded extends JobsState {
  final List<Job> jobs;
  final List<Job> availableBroadcasts;
  final JobStatus? selectedFilter;

  const JobsLoaded({
    required this.jobs,
    this.availableBroadcasts = const [],
    this.selectedFilter,
  });

  JobsLoaded copyWith({
    List<Job>? jobs,
    List<Job>? availableBroadcasts,
    JobStatus? selectedFilter,
  }) {
    return JobsLoaded(
      jobs: jobs ?? this.jobs,
      availableBroadcasts: availableBroadcasts ?? this.availableBroadcasts,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [jobs, availableBroadcasts, selectedFilter];
}

class JobDetailLoaded extends JobsState {
  final Job job;

  const JobDetailLoaded({required this.job});

  @override
  List<Object?> get props => [job];
}

class JobsError extends JobsState {
  final String message;

  const JobsError(this.message);

  @override
  List<Object?> get props => [message];
}
