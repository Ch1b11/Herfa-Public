import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/job.dart';
import '../repositories/i_jobs_repository.dart';

class GetJobDetailsUseCase {
  final IJobsRepository repository;

  GetJobDetailsUseCase({required this.repository});

  Future<Either<Failure, Job>> call(String jobId) async {
    return repository.getJobDetails(jobId);
  }
}
