import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/job.dart';
import '../repositories/i_jobs_repository.dart';

class GetCraftsmanJobsUseCase {
  final IJobsRepository repository;

  GetCraftsmanJobsUseCase({required this.repository});

  Future<Either<Failure, List<Job>>> call({JobStatus? status}) async {
    return await repository.getCraftsmanJobs(status: status);
  }
}
