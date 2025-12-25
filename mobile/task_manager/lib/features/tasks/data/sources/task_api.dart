import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../models/task_model.dart';

class TaskApiException implements Exception {
  final String message;
  TaskApiException(this.message);

  @override
  String toString() => message;
}

class TaskApi {
  final Dio _dio = DioClient.dio;

   Future<List<TaskModel>> getTasks({
    String? status,
    String? priority,
    String? category,
    int limit = 10,
  }) async {

    final queryParams = <String, dynamic>{
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (priority != null) queryParams['priority'] = priority;
    if (category != null) queryParams['category'] = category;

    try {
      final response = await _dio.get(
        '/task',
        queryParameters: queryParams,
      );

      final data = response.data["data"] as List;
    //   print(data);

      return data
          .map((json) => TaskModel.fromJson(json))
          .toList();

    // return [];
    } on DioException catch (e) {
      throw TaskApiException(
        e.response?.data?['error'] ?? 'Failed to fetch tasks',
      );
    } catch (e, st) {
      print(e);print(st);
      throw TaskApiException(
          'Unexpected error occurred',
        );
      }
  }

  Future<TaskModel> createTask({
    required String rawInput,
  }) async {
    try {
      final response = await _dio.post(
        '/task',
        data: {
          'input': rawInput,
        },
      );
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw TaskApiException(
        e.response?.data?['error'] ?? 'Failed to create task',
      );
    }
  }
}