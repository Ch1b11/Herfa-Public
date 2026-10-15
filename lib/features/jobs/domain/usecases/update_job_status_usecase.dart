import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/job.dart';
import '../repositories/i_jobs_repository.dart';

class UpdateJobStatusUseCase {
  final IJobsRepository repository;

  UpdateJobStatusUseCase({required this.repository});

  Future<Either<Failure, Job>> call({
    required String jobId,
    required JobStatus status,
    int? progressStep,
  }) async {
    return await repository.updateJobStatus(
      jobId: jobId,
      status: status,
      progressStep: progressStep,
    );
  }
}
