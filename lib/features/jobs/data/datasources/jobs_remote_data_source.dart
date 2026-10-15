import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/dio_error_parser.dart';
import '../../domain/entities/job.dart';
import '../models/job_model.dart';

abstract class IJobsRemoteDataSource {
  Future<List<JobModel>> getCraftsmanJobs({JobStatus? status});

  Future<JobModel> getJobDetails(String jobId);

  Future<JobModel> updateJobStatus({
    required String jobId,
    required JobStatus status,
    int? progressStep,
  });

  Future<List<JobModel>> getCustomerJobs();

  Future<List<JobModel>> getAvailableBroadcastJobs();

  Future<JobModel> acceptBroadcastJob(String jobId);

  Future<JobModel> createBroadcastServiceRequest({
    required String title,
    required String category,
    required String description,
    double? budget,
    DateTime? scheduledAt,
  });
}

class JobsRemoteDataSourceImpl implements IJobsRemoteDataSource {
  final Dio dio;

  JobsRemoteDataSourceImpl({required this.dio});

  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.error is SocketException ||
        (e.type == DioExceptionType.unknown &&
            e.message != null &&
            e.message!.contains('SocketException'))) {
      throw ServerException('error_connection_failed');
    }

    final message = DioErrorParser.parseMessage(e);
    throw ServerException(message);
  }

  @override
  Future<List<JobModel>> getCraftsmanJobs({JobStatus? status}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (status != null) {
        queryParams['status'] = JobModel.toBackendStatus(status);
      }

      final response = await dio.get(
        '/requests',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final rawData = response.data;
      List<dynamic> items = [];

      if (rawData is Map<String, dynamic>) {
        final inner = rawData['data'];
        if (inner is Map<String, dynamic> && inner['data'] is List) {
          items = inner['data'] as List<dynamic>;
        } else if (inner is List) {
          items = inner;
        } else if (rawData['items'] is List) {
          items = rawData['items'] as List<dynamic>;
        }
      } else if (rawData is List) {
        items = rawData;
      }

      return items
          .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> getJobDetails(String jobId) async {
    try {
      final cleanId = jobId.replaceFirst('#', '').trim();
      final response = await dio.get('/requests/$cleanId');

      final rawData = response.data;
      Map<String, dynamic> item = {};

      if (rawData is Map<String, dynamic>) {
        if (rawData['data'] is Map<String, dynamic>) {
          item = rawData['data'] as Map<String, dynamic>;
        } else {
          item = rawData;
        }
      }

      return JobModel.fromJson(item);
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> updateJobStatus({
    required String jobId,
    required JobStatus status,
    int? progressStep,
  }) async {
    try {
      final cleanId = jobId.replaceFirst('#', '').trim();
      final backendStatus = JobModel.toBackendStatus(status);

      final response = await dio.patch(
        '/requests/$cleanId/status',
        data: {'status': backendStatus},
      );

      final rawData = response.data;
      Map<String, dynamic> item = {};

      if (rawData is Map<String, dynamic>) {
        if (rawData['data'] is Map<String, dynamic>) {
          item = rawData['data'] as Map<String, dynamic>;
        } else {
          item = rawData;
        }
      }

      return JobModel.fromJson(item);
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobModel>> getCustomerJobs() async {
    try {
      final response = await dio.get('/requests');

      final rawData = response.data;
      List<dynamic> items = [];

      if (rawData is Map<String, dynamic>) {
        final inner = rawData['data'];
        if (inner is Map<String, dynamic> && inner['data'] is List) {
          items = inner['data'] as List<dynamic>;
        } else if (inner is List) {
          items = inner;
        } else if (rawData['items'] is List) {
          items = rawData['items'] as List<dynamic>;
        }
      } else if (rawData is List) {
        items = rawData;
      }

      return items
          .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> createBroadcastServiceRequest({
    required String title,
    required String category,
    required String description,
    double? budget,
    DateTime? scheduledAt,
  }) async {
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

      final response = await dio.post(
        '/requests',
        data: payload,
      );

      final rawData = response.data;
      Map<String, dynamic> item = {};

      if (rawData is Map<String, dynamic>) {
        if (rawData['data'] is Map<String, dynamic>) {
          item = rawData['data'] as Map<String, dynamic>;
        } else {
          item = rawData;
        }
      }

      return JobModel.fromJson(item);
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobModel>> getAvailableBroadcastJobs() async {
    try {
      final response = await dio.get('/requests/available');

      final rawData = response.data;
      List<dynamic> items = [];

      if (rawData is Map<String, dynamic>) {
        final inner = rawData['data'];
        if (inner is Map<String, dynamic> && inner['data'] is List) {
          items = inner['data'] as List<dynamic>;
        } else if (inner is List) {
          items = inner;
        } else if (rawData['items'] is List) {
          items = rawData['items'] as List<dynamic>;
        }
      } else if (rawData is List) {
        items = rawData;
      }

      return items
          .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobModel> acceptBroadcastJob(String jobId) async {
    try {
      final cleanId = jobId.replaceFirst('#', '').trim();
      final response = await dio.post('/requests/$cleanId/accept');

      final rawData = response.data;
      Map<String, dynamic> item = {};

      if (rawData is Map<String, dynamic>) {
        if (rawData['data'] is Map<String, dynamic>) {
          item = rawData['data'] as Map<String, dynamic>;
        } else {
          item = rawData;
        }
      }

      return JobModel.fromJson(item);
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
