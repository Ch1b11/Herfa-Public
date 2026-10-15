import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/job.dart';
import '../repositories/i_jobs_repository.dart';

class GetCustomerActiveJobUseCase {
  final IJobsRepository repository;

  GetCustomerActiveJobUseCase({required this.repository});

  Future<Either<Failure, Job?>> call() async {
    return repository.getCustomerActiveJob();
  }
}
