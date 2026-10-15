import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/job.dart';
import '../repositories/i_jobs_repository.dart';

class AcceptBroadcastJobUseCase {
  final IJobsRepository repository;

  AcceptBroadcastJobUseCase({required this.repository});

  Future<Either<Failure, Job>> call(String jobId) async {
    return await repository.acceptBroadcastJob(jobId);
  }
}
