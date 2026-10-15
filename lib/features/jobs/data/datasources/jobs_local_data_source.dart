import 'dart:convert';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/job.dart';
import '../models/job_model.dart';

abstract class IJobsLocalDataSource {
  Future<void> cacheJobs(List<JobModel> jobs);
  List<JobModel> getCachedJobs({JobStatus? status});
  JobModel? getCachedJob(String jobId);
  Future<void> clearCache();

  Future<void> cacheCustomerActiveJob(JobModel? job);
  JobModel? getCachedCustomerActiveJob();
  Future<void> cacheCustomerJobs(List<JobModel> jobs);
  List<JobModel> getCachedCustomerJobs();
}

typedef JobsLocalDataSource = IJobsLocalDataSource;

class JobsLocalDataSourceImpl implements IJobsLocalDataSource {
  final StorageService storageService;

  JobsLocalDataSourceImpl({required this.storageService});

  static const _jobsKey = 'cached_craftsman_jobs';
  static const _customerActiveJobKey = 'cached_customer_active_job';
  static const _customerJobsKey = 'cached_customer_jobs';

  @override
  Future<void> cacheJobs(List<JobModel> jobs) async {
    try {
      final jsonList = jobs.map((j) => j.toJson()).toList();
      await storageService.jobsBox.put(_jobsKey, jsonEncode(jsonList));
    } catch (e) {
      throw CacheException('Failed to cache jobs: $e');
    }
  }

  @override
  List<JobModel> getCachedJobs({JobStatus? status}) {
    try {
      final raw = storageService.jobsBox.get(_jobsKey);
      if (raw == null || raw.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      final jobs = decoded
          .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
          .toList();

      if (status != null) {
        return jobs.where((j) => j.status == status).toList();
      }
      return jobs;
    } catch (e) {
      throw CacheException('Failed to get cached jobs: $e');
    }
  }

  @override
  JobModel? getCachedJob(String jobId) {
    try {
      final cleanId = jobId.replaceFirst('#', '').trim();
      bool matches(JobModel j) =>
          j.id == jobId ||
          j.id.replaceFirst('#', '').trim() == cleanId;

      // 1. Check direct craftsman jobs
      final jobs = getCachedJobs();
      final index = jobs.indexWhere(matches);
      if (index != -1) {
        return jobs[index];
      }

      // 2. Check customer active job
      final activeJob = getCachedCustomerActiveJob();
      if (activeJob != null && matches(activeJob)) {
        return activeJob;
      }

      // 3. Check customer jobs list
      final customerJobs = getCachedCustomerJobs();
      final customerIndex = customerJobs.indexWhere(matches);
      if (customerIndex != -1) {
        return customerJobs[customerIndex];
      }

      return null;
    } catch (e) {
      throw CacheException('Failed to get cached job details: $e');
    }
  }

  @override
  Future<void> cacheCustomerActiveJob(JobModel? job) async {
    try {
      if (job == null) {
        await storageService.jobsBox.delete(_customerActiveJobKey);
      } else {
        await storageService.jobsBox.put(
          _customerActiveJobKey,
          jsonEncode(job.toJson()),
        );
      }
    } catch (e) {
      throw CacheException('Failed to cache customer active job: $e');
    }
  }

  @override
  JobModel? getCachedCustomerActiveJob() {
    try {
      final raw = storageService.jobsBox.get(_customerActiveJobKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return JobModel.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached customer active job: $e');
    }
  }

  @override
  Future<void> cacheCustomerJobs(List<JobModel> jobs) async {
    try {
      final jsonList = jobs.map((j) => j.toJson()).toList();
      await storageService.jobsBox.put(
        _customerJobsKey,
        jsonEncode(jsonList),
      );
    } catch (e) {
      throw CacheException('Failed to cache customer jobs: $e');
    }
  }

  @override
  List<JobModel> getCachedCustomerJobs() {
    try {
      final raw = storageService.jobsBox.get(_customerJobsKey);
      if (raw == null || raw.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      return decoded
          .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached customer jobs: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await storageService.jobsBox.delete(_jobsKey);
      await storageService.jobsBox.delete(_customerActiveJobKey);
      await storageService.jobsBox.delete(_customerJobsKey);
    } catch (e) {
      throw CacheException('Failed to clear cached jobs: $e');
    }
  }
}
