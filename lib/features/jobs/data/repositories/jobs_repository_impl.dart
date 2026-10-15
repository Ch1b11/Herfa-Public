import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/sync/pending_mutation.dart';
import '../../../../core/sync/sync_service.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/i_jobs_repository.dart';
import '../datasources/jobs_local_data_source.dart';
import '../datasources/jobs_remote_data_source.dart';
import '../models/job_model.dart';

class JobsRepositoryImpl implements IJobsRepository {
  final IJobsRemoteDataSource remoteDataSource;
  final IJobsLocalDataSource? localDataSource;
  final INetworkInfo? networkInfo;
  final StorageService? storageService;
  final SyncService? syncService;

  JobsRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
    this.storageService,
    this.syncService,
  });

  @override
  Future<Either<Failure, List<Job>>> getCraftsmanJobs({JobStatus? status}) async {
    try {
      final jobs = await remoteDataSource.getCraftsmanJobs(status: status);
      try {
        await localDataSource?.cacheJobs(jobs);
      } catch (_) {}
      return Right(jobs);
    } on ServerException catch (e) {
      if (localDataSource != null) {
        try {
          final cached = localDataSource!.getCachedJobs(status: status);
          if (cached.isNotEmpty) {
            return Right(cached);
          }
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      if (localDataSource != null) {
        try {
          final cached = localDataSource!.getCachedJobs(status: status);
          if (cached.isNotEmpty) {
            return Right(cached);
          }
        } catch (_) {}
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Job>> getJobDetails(String jobId) async {
    try {
      final job = await remoteDataSource.getJobDetails(jobId);
      return Right(job);
    } on ServerException catch (e) {
      if (localDataSource != null) {
        try {
          final cached = localDataSource!.getCachedJob(jobId);
          if (cached != null) {
            return Right(cached);
          }
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      if (localDataSource != null) {
        try {
          final cached = localDataSource!.getCachedJob(jobId);
          if (cached != null) {
            return Right(cached);
          }
        } catch (_) {}
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Job>> updateJobStatus({
    required String jobId,
    required JobStatus status,
    int? progressStep,
  }) async {
    final isOnline = await networkInfo?.isConnected ?? true;

    if (!isOnline) {
      final queuedJob = await _queueJobStatusMutation(
        jobId: jobId,
        status: status,
        progressStep: progressStep,
      );
      return Right(queuedJob);
    }

    try {
      final job = await remoteDataSource.updateJobStatus(
        jobId: jobId,
        status: status,
        progressStep: progressStep,
      );
      if (localDataSource != null) {
        try {
          await _updateCachedJob(job);
        } catch (_) {}
      }
      return Right(job);
    } on ServerException catch (e) {
      if (e.message == 'error_connection_failed') {
        final queuedJob = await _queueJobStatusMutation(
          jobId: jobId,
          status: status,
          progressStep: progressStep,
        );
        return Right(queuedJob);
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<JobModel> _queueJobStatusMutation({
    required String jobId,
    required JobStatus status,
    int? progressStep,
  }) async {
    final existingJob = localDataSource?.getCachedJob(jobId);
    final updatedJob = existingJob != null
        ? JobModel(
            id: existingJob.id,
            title: existingJob.title,
            clientName: existingJob.clientName,
            clientPhone: existingJob.clientPhone,
            location: existingJob.location,
            district: existingJob.district,
            price: existingJob.price,
            status: status,
            progressStep: progressStep ?? existingJob.progressStep,
            totalSteps: existingJob.totalSteps,
            scheduledDate: existingJob.scheduledDate,
            description: existingJob.description,
          )
        : JobModel(
            id: jobId,
            title: 'طلب صيانة',
            clientName: 'العميل',
            location: '',
            district: '',
            price: 0.0,
            status: status,
            progressStep: progressStep ?? 0,
            totalSteps: 4,
            scheduledDate: DateTime.now(),
          );

    if (localDataSource != null) {
      try {
        await _updateCachedJob(updatedJob);
      } catch (_) {}
    }

    if (storageService != null) {
      final cleanId = jobId.replaceFirst('#', '').trim();
      final mutation = PendingMutation(
        id: const Uuid().v4(),
        method: HttpMethod.patch,
        endpoint: '/requests/$cleanId/status',
        payload: {
          'status': JobModel.toBackendStatus(status),
        },
        timestamp: DateTime.now(),
        collection: 'jobs',
      );

      await storageService!.addMutation(
        mutation.id,
        jsonEncode(mutation.toJson()),
      );

      syncService?.processQueue();
    }

    return updatedJob;
  }

  Future<void> _updateCachedJob(JobModel updatedJob) async {
    if (localDataSource == null) return;
    final allJobs = localDataSource!.getCachedJobs();
    final cleanId = updatedJob.id.replaceFirst('#', '').trim();
    final idx = allJobs.indexWhere(
      (j) => j.id == updatedJob.id || j.id.replaceFirst('#', '').trim() == cleanId,
    );
    final updatedList = List<JobModel>.from(allJobs);
    if (idx != -1) {
      updatedList[idx] = updatedJob;
    } else {
      updatedList.add(updatedJob);
    }
    await localDataSource!.cacheJobs(updatedList);
  }

  @override
  Future<Either<Failure, List<Job>>> getCustomerJobs() async {
    final isOnline = await networkInfo?.isConnected ?? true;

    if (!isOnline && localDataSource != null) {
      try {
        final cached = localDataSource!.getCachedCustomerJobs();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
      } catch (_) {}
    }

    try {
      final jobs = await remoteDataSource.getCustomerJobs();
      try {
        await localDataSource?.cacheCustomerJobs(jobs);
      } catch (_) {}
      return Right(jobs);
    } on ServerException catch (e) {
      if (localDataSource != null) {
        try {
          final cached = localDataSource!.getCachedCustomerJobs();
          if (cached.isNotEmpty) {
            return Right(cached);
          }
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      if (localDataSource != null) {
        try {
          final cached = localDataSource!.getCachedCustomerJobs();
          if (cached.isNotEmpty) {
            return Right(cached);
          }
        } catch (_) {}
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Job?>> getCustomerActiveJob() async {
    final isOnline = await networkInfo?.isConnected ?? true;

    if (!isOnline && localDataSource != null) {
      try {
        final cached = localDataSource!.getCachedCustomerActiveJob();
        if (cached != null) {
          return Right(cached);
        }
      } catch (_) {}
    }

    try {
      final jobs = await remoteDataSource.getCustomerJobs();
      final activeJobs = jobs.where((j) =>
        j.status == JobStatus.pending ||
        j.status == JobStatus.scheduled ||
        j.status == JobStatus.onTheWay ||
        j.status == JobStatus.inProgress
      ).toList();

      final activeJob = activeJobs.isNotEmpty ? activeJobs.first : null;
      try {
        await localDataSource?.cacheCustomerActiveJob(activeJob);
        await localDataSource?.cacheCustomerJobs(jobs);
      } catch (_) {}
      return Right(activeJob);
    } on ServerException catch (e) {
      if (localDataSource != null) {
        try {
          final cached = localDataSource!.getCachedCustomerActiveJob();
          if (cached != null) {
            return Right(cached);
          }
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      if (localDataSource != null) {
        try {
          final cached = localDataSource!.getCachedCustomerActiveJob();
          if (cached != null) {
            return Right(cached);
          }
        } catch (_) {}
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Job>> createBroadcastServiceRequest({
    required String title,
    required String category,
    required String description,
    double? budget,
    DateTime? scheduledAt,
  }) async {
    final isOnline = await networkInfo?.isConnected ?? true;

    if (!isOnline) {
      final queuedJob = await _queueBroadcastRequestMutation(
        title: title,
        category: category,
        description: description,
        budget: budget,
        scheduledAt: scheduledAt,
      );
      return Right(queuedJob);
    }

    try {
      final job = await remoteDataSource.createBroadcastServiceRequest(
        title: title,
        category: category,
        description: description,
        budget: budget,
        scheduledAt: scheduledAt,
      );
      if (localDataSource != null) {
        try {
          await localDataSource!.cacheCustomerActiveJob(job);
        } catch (_) {}
      }
      return Right(job);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<JobModel> _queueBroadcastRequestMutation({
    required String title,
    required String category,
    required String description,
    double? budget,
    DateTime? scheduledAt,
  }) async {
    final tempId = const Uuid().v4();
    final optimisticJob = JobModel(
      id: tempId,
      title: title.trim(),
      clientName: 'أنت',
      location: '',
      district: '',
      price: budget ?? 0.0,
      status: JobStatus.pending,
      scheduledDate: scheduledAt ?? DateTime.now(),
      description: description.trim(),
    );

    if (localDataSource != null) {
      try {
        await localDataSource!.cacheCustomerActiveJob(optimisticJob);
      } catch (_) {}
    }

    if (storageService != null) {
      try {
        final payload = <String, dynamic>{
          'title': title.trim(),
          'category': category.trim().toLowerCase(),
          'description': description.trim(),
        };
        if (budget != null) {
          payload['budget'] = budget;
        }
        if (scheduledAt != null) {
          payload['scheduledAt'] = scheduledAt.toUtc().toIso8601String();
        }

        final mutation = PendingMutation(
          id: const Uuid().v4(),
          method: HttpMethod.post,
          endpoint: '/requests',
          payload: payload,
          timestamp: DateTime.now(),
          tempId: tempId,
          collection: 'jobs',
        );

        await storageService!.addMutation(
          mutation.id,
          jsonEncode(mutation.toJson()),
        );

        syncService?.processQueue();
      } catch (_) {}
    }

    return optimisticJob;
  }

  @override
  Future<Either<Failure, List<Job>>> getAvailableBroadcastJobs() async {
    try {
      final jobs = await remoteDataSource.getAvailableBroadcastJobs();
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Job>> acceptBroadcastJob(String jobId) async {
    final isOnline = await networkInfo?.isConnected ?? true;

    if (!isOnline) {
      final queuedJob = await _queueAcceptJobMutation(jobId);
      return Right(queuedJob);
    }

    try {
      final job = await remoteDataSource.acceptBroadcastJob(jobId);
      if (localDataSource != null) {
        try {
          await _updateCachedJob(job);
        } catch (_) {}
      }
      return Right(job);
    } on ServerException catch (e) {
      if (e.message == 'error_connection_failed') {
        final queuedJob = await _queueAcceptJobMutation(jobId);
        return Right(queuedJob);
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<JobModel> _queueAcceptJobMutation(String jobId) async {
    final existingJob = localDataSource?.getCachedJob(jobId);
    final cleanId = jobId.replaceFirst('#', '').trim();
    final updatedJob = existingJob != null
        ? JobModel(
            id: existingJob.id,
            title: existingJob.title,
            clientName: existingJob.clientName,
            clientPhone: existingJob.clientPhone,
            location: existingJob.location,
            district: existingJob.district,
            price: existingJob.price,
            status: JobStatus.scheduled,
            progressStep: 1,
            totalSteps: existingJob.totalSteps,
            scheduledDate: existingJob.scheduledDate,
            description: existingJob.description,
          )
        : JobModel(
            id: cleanId,
            title: 'طلب صيانة',
            clientName: 'العميل',
            location: '',
            district: '',
            price: 0.0,
            status: JobStatus.scheduled,
            progressStep: 1,
            totalSteps: 4,
            scheduledDate: DateTime.now(),
          );

    if (localDataSource != null) {
      try {
        await _updateCachedJob(updatedJob);
      } catch (_) {}
    }

    if (storageService != null) {
      final mutation = PendingMutation(
        id: const Uuid().v4(),
        method: HttpMethod.post,
        endpoint: '/requests/$cleanId/accept',
        payload: {},
        timestamp: DateTime.now(),
        collection: 'jobs',
      );

      await storageService!.addMutation(
        mutation.id,
        jsonEncode(mutation.toJson()),
      );

      syncService?.processQueue();
    }

    return updatedJob;
  }
}
