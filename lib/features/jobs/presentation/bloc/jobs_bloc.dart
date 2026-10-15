import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/jobs_local_data_source.dart';
import '../../domain/entities/job.dart';
import '../../domain/usecases/accept_broadcast_job_usecase.dart';
import '../../domain/usecases/get_available_broadcast_jobs_usecase.dart';
import '../../domain/usecases/get_craftsman_jobs_usecase.dart';
import '../../domain/usecases/update_job_status_usecase.dart';
import 'jobs_event.dart';
import 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final GetCraftsmanJobsUseCase getCraftsmanJobsUseCase;
  final UpdateJobStatusUseCase updateJobStatusUseCase;
  final GetAvailableBroadcastJobsUseCase? getAvailableBroadcastJobsUseCase;
  final AcceptBroadcastJobUseCase? acceptBroadcastJobUseCase;
  final IJobsLocalDataSource? localDataSource;

  DateTime? _lastFetchedAt;
  static const Duration staleDuration = Duration(minutes: 5);

  DateTime? get lastFetchedAt => _lastFetchedAt;

  @visibleForTesting
  set lastFetchedAt(DateTime? value) => _lastFetchedAt = value;

  void invalidateStaleness() {
    _lastFetchedAt = null;
  }

  JobsBloc({
    required this.getCraftsmanJobsUseCase,
    required this.updateJobStatusUseCase,
    this.getAvailableBroadcastJobsUseCase,
    this.acceptBroadcastJobUseCase,
    this.localDataSource,
  }) : super(_getInitialState(localDataSource)) {
    on<FetchCraftsmanJobs>(_onFetchCraftsmanJobs);
    on<FetchJobDetail>(_onFetchJobDetail);
    on<UpdateJobProgress>(_onUpdateJobProgress);
    on<AcceptJob>(_onAcceptJob);
  }

  static JobsState _getInitialState(IJobsLocalDataSource? localDataSource) {
    if (localDataSource != null) {
      try {
        final cached = localDataSource.getCachedJobs();
        if (cached.isNotEmpty) {
          return JobsLoaded(jobs: cached);
        }
      } catch (_) {}
    }
    return const JobsLoading();
  }

  Future<void> _onFetchCraftsmanJobs(
    FetchCraftsmanJobs event,
    Emitter<JobsState> emit,
  ) async {
    final isLoaded = state is JobsLoaded;
    final isFresh = _lastFetchedAt != null &&
        DateTime.now().difference(_lastFetchedAt!) < staleDuration;

    // Staleness Guard: If data is loaded in memory, not stale, and forceRefresh is false,
    // skip the remote network call completely to conserve network and avoid UI flashes.
    if (isLoaded && !event.forceRefresh && isFresh) {
      if (event.status != null &&
          (state as JobsLoaded).selectedFilter != event.status &&
          localDataSource != null) {
        try {
          final models = localDataSource!.getCachedJobs(status: event.status);
          if (models.isNotEmpty) {
            emit(JobsLoaded(jobs: models, selectedFilter: event.status));
          }
        } catch (_) {}
      }
      return;
    }

    // 1. SWR: If not loaded yet, check cache or emit Loading
    if (!isLoaded) {
      List<Job>? cachedJobs;
      if (localDataSource != null) {
        try {
          final models = localDataSource!.getCachedJobs(status: event.status);
          if (models.isNotEmpty) {
            cachedJobs = models;
          }
        } catch (_) {}
      }

      if (cachedJobs != null && cachedJobs.isNotEmpty) {
        emit(JobsLoaded(jobs: cachedJobs, selectedFilter: event.status));
      } else if (state is! JobsLoading) {
        emit(const JobsLoading());
      }
    } else if (event.status != null &&
        (state as JobsLoaded).selectedFilter != event.status &&
        localDataSource != null) {
      // If switching filter, attempt quick cached slice
      try {
        final models = localDataSource!.getCachedJobs(status: event.status);
        if (models.isNotEmpty) {
          emit(JobsLoaded(jobs: models, selectedFilter: event.status));
        }
      } catch (_) {}
    }

    // 2. Fetch fresh data from remote in background (revalidation)
    final result = await getCraftsmanJobsUseCase(status: event.status);

    await result.fold(
      (failure) async {
        // Offline resilience: if cached jobs are already on screen, silently retain JobsLoaded
        if (state is JobsLoaded) {
          return;
        }
        emit(JobsError(failure.message));
      },
      (jobs) async {
        _lastFetchedAt = DateTime.now();
        List<Job> broadcasts = [];
        if (getAvailableBroadcastJobsUseCase != null) {
          final broadcastRes = await getAvailableBroadcastJobsUseCase!();
          broadcasts = broadcastRes.fold((_) => <Job>[], (b) => b);
        }
        emit(JobsLoaded(
          jobs: jobs,
          availableBroadcasts: broadcasts,
          selectedFilter: event.status,
        ));
      },
    );
  }

  Future<void> _onFetchJobDetail(
    FetchJobDetail event,
    Emitter<JobsState> emit,
  ) async {
    Job? cachedJob;
    if (localDataSource != null) {
      try {
        cachedJob = localDataSource!.getCachedJob(event.jobId);
      } catch (_) {}
    }

    if (cachedJob != null) {
      emit(JobDetailLoaded(job: cachedJob));
    } else {
      emit(const JobsLoading());
    }

    final result = await getCraftsmanJobsUseCase();
    result.fold(
      (failure) {
        if (cachedJob != null) return;
        emit(JobsError(failure.message));
      },
      (jobs) {
        final job = jobs.firstWhere(
          (j) =>
              j.id == event.jobId ||
              j.id.replaceFirst('#', '').trim() ==
                  event.jobId.replaceFirst('#', '').trim(),
          orElse: () => jobs.first,
        );
        emit(JobDetailLoaded(job: job));
      },
    );
  }

  Future<void> _onUpdateJobProgress(
    UpdateJobProgress event,
    Emitter<JobsState> emit,
  ) async {
    final isLoaded = state is JobsLoaded;
    List<Job>? previousJobs;
    JobStatus? previousFilter;

    if (isLoaded) {
      previousJobs = (state as JobsLoaded).jobs;
      previousFilter = (state as JobsLoaded).selectedFilter;

      final updatedIndex = previousJobs.indexWhere(
        (j) =>
            j.id == event.jobId ||
            j.id.replaceFirst('#', '') == event.jobId.replaceFirst('#', ''),
      );

      if (updatedIndex != -1) {
        final current = previousJobs[updatedIndex];
        final optimisticJob = Job(
          id: current.id,
          title: current.title,
          clientName: current.clientName,
          clientPhone: current.clientPhone,
          location: current.location,
          district: current.district,
          price: current.price,
          status: event.status,
          progressStep: event.progressStep ?? current.progressStep,
          totalSteps: current.totalSteps,
          scheduledDate: current.scheduledDate,
          description: current.description,
        );
        final optimisticList = List<Job>.from(previousJobs);
        optimisticList[updatedIndex] = optimisticJob;
        emit(JobsLoaded(jobs: optimisticList, selectedFilter: previousFilter));
      }
    }

    final result = await updateJobStatusUseCase(
      jobId: event.jobId,
      status: event.status,
      progressStep: event.progressStep,
    );

    result.fold(
      (failure) {
        if (isLoaded && previousJobs != null) {
          emit(JobsLoaded(jobs: previousJobs, selectedFilter: previousFilter));
        }
        emit(JobsError(failure.message));
      },
      (updatedJob) {
        _lastFetchedAt = DateTime.now();
        if (isLoaded) {
          final currentList = (state is JobsLoaded)
              ? List<Job>.from((state as JobsLoaded).jobs)
              : List<Job>.from(previousJobs ?? []);
          final idx = currentList.indexWhere(
            (j) =>
                j.id == updatedJob.id ||
                j.id.replaceFirst('#', '') ==
                    updatedJob.id.replaceFirst('#', ''),
          );
          if (idx != -1) {
            currentList[idx] = updatedJob;
          } else {
            currentList.add(updatedJob);
          }
          emit(JobsLoaded(jobs: currentList, selectedFilter: previousFilter));
        } else {
          emit(JobDetailLoaded(job: updatedJob));
        }
      },
    );
  }

  Future<void> _onAcceptJob(
    AcceptJob event,
    Emitter<JobsState> emit,
  ) async {
    final isLoaded = state is JobsLoaded;
    List<Job>? previousJobs;
    List<Job>? previousBroadcasts;
    JobStatus? previousFilter;

    final cleanId = event.jobId.replaceFirst('#', '').trim();

    if (isLoaded) {
      final currentLoaded = state as JobsLoaded;
      previousJobs = currentLoaded.jobs;
      previousBroadcasts = currentLoaded.availableBroadcasts;
      previousFilter = currentLoaded.selectedFilter;

      final broadcastIndex = previousBroadcasts.indexWhere(
        (j) =>
            j.id == cleanId ||
            j.id.replaceFirst('#', '').trim() == cleanId,
      );

      final Job claimedJob;
      if (broadcastIndex != -1) {
        final target = previousBroadcasts[broadcastIndex];
        claimedJob = Job(
          id: target.id,
          title: target.title,
          clientName: target.clientName,
          clientPhone: target.clientPhone,
          location: target.location,
          district: target.district,
          price: target.price,
          status: JobStatus.scheduled,
          progressStep: 1,
          totalSteps: target.totalSteps > 0 ? target.totalSteps : 4,
          scheduledDate: target.scheduledDate,
          description: target.description,
          technicianName: target.technicianName,
          technicianTitle: target.technicianTitle,
          technicianPhone: target.technicianPhone,
          technicianRating: target.technicianRating,
          technicianJobsCount: target.technicianJobsCount,
        );
      } else {
        final jobIndex = previousJobs.indexWhere(
          (j) =>
              j.id == cleanId ||
              j.id.replaceFirst('#', '').trim() == cleanId,
        );
        if (jobIndex != -1) {
          final target = previousJobs[jobIndex];
          claimedJob = Job(
            id: target.id,
            title: target.title,
            clientName: target.clientName,
            clientPhone: target.clientPhone,
            location: target.location,
            district: target.district,
            price: target.price,
            status: JobStatus.scheduled,
            progressStep: 1,
            totalSteps: target.totalSteps > 0 ? target.totalSteps : 4,
            scheduledDate: target.scheduledDate,
            description: target.description,
            technicianName: target.technicianName,
            technicianTitle: target.technicianTitle,
            technicianPhone: target.technicianPhone,
            technicianRating: target.technicianRating,
            technicianJobsCount: target.technicianJobsCount,
          );
        } else {
          claimedJob = Job(
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
        }
      }

      // Optimistic update: filter out from available broadcasts, prepend/update in assigned jobs
      final newBroadcasts = previousBroadcasts
          .where(
            (j) =>
                j.id != cleanId &&
                j.id.replaceFirst('#', '').trim() != cleanId,
          )
          .toList();

      final newJobs = List<Job>.from(previousJobs);
      final existingIndex = newJobs.indexWhere(
        (j) =>
            j.id == cleanId ||
            j.id.replaceFirst('#', '').trim() == cleanId,
      );
      if (existingIndex != -1) {
        newJobs[existingIndex] = claimedJob;
      } else {
        newJobs.insert(0, claimedJob);
      }

      emit(JobsLoaded(
        jobs: newJobs,
        availableBroadcasts: newBroadcasts,
        selectedFilter: previousFilter,
      ));
    }

    if (acceptBroadcastJobUseCase != null) {
      final result = await acceptBroadcastJobUseCase!(cleanId);

      result.fold(
        (failure) {
          // Rollback: restore previous jobs and broadcasts, then emit error
          if (isLoaded && previousJobs != null) {
            emit(JobsLoaded(
              jobs: previousJobs,
              availableBroadcasts: previousBroadcasts ?? const [],
              selectedFilter: previousFilter,
            ));
          }
          emit(JobsError(failure.message));
        },
        (confirmedJob) {
          _lastFetchedAt = DateTime.now();
          if (state is JobsLoaded) {
            final currentList =
                List<Job>.from((state as JobsLoaded).jobs);
            final idx = currentList.indexWhere(
              (j) =>
                  j.id == confirmedJob.id ||
                  j.id.replaceFirst('#', '').trim() ==
                      confirmedJob.id.replaceFirst('#', '').trim(),
            );
            if (idx != -1) {
              currentList[idx] = confirmedJob;
            } else {
              currentList.insert(0, confirmedJob);
            }
            emit((state as JobsLoaded).copyWith(jobs: currentList));
          }
        },
      );
    }
  }
}
