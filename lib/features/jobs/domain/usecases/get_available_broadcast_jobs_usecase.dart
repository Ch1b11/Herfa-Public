import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/job.dart';
import '../repositories/i_jobs_repository.dart';

class GetAvailableBroadcastJobsUseCase {
  final IJobsRepository repository;

  GetAvailableBroadcastJobsUseCase({required this.repository});

  Future<Either<Failure, List<Job>>> call() async {
    return await repository.getAvailableBroadcastJobs();
  }
}
