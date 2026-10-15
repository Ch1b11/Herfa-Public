import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/job.dart';

abstract class IJobsRepository {
  Future<Either<Failure, List<Job>>> getCraftsmanJobs({JobStatus? status});

  Future<Either<Failure, Job>> getJobDetails(String jobId);

  Future<Either<Failure, Job>> updateJobStatus({
    required String jobId,
    required JobStatus status,
    int? progressStep,
  });

  Future<Either<Failure, List<Job>>> getCustomerJobs();

  Future<Either<Failure, Job?>> getCustomerActiveJob();

  Future<Either<Failure, List<Job>>> getAvailableBroadcastJobs();

  Future<Either<Failure, Job>> acceptBroadcastJob(String jobId);

  Future<Either<Failure, Job>> createBroadcastServiceRequest({
    required String title,
    required String category,
    required String description,
    double? budget,
    DateTime? scheduledAt,
  });
}
