import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/job.dart';
import '../repositories/i_jobs_repository.dart';

class CreateBroadcastServiceRequestUseCase {
  final IJobsRepository repository;

  CreateBroadcastServiceRequestUseCase({required this.repository});

  Future<Either<Failure, Job>> call({
    required String title,
    required String category,
    required String description,
    double? budget,
    DateTime? scheduledAt,
  }) {
    return repository.createBroadcastServiceRequest(
      title: title,
      category: category,
      description: description,
      budget: budget,
      scheduledAt: scheduledAt,
    );
  }
}
