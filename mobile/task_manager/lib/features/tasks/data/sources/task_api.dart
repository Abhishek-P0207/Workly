import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../models/task_model.dart';

class TaskApiException implements Exception {
  final String message;
  TaskApiException(this.message);

  @override
  String toString() => message;
}

class TaskPreview {
  final String title;
  final String description;
  final String category;
  final String priority;
  final String? assignedTo;
  final DateTime? dueDate;
  final Map<String, dynamic> extractedEntities;
  final List<String> suggestedActions;

  TaskPreview({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.assignedTo,
    this.dueDate,
    required this.extractedEntities,
    required this.suggestedActions,
  });

  factory TaskPreview.fromJson(Map<String, dynamic> json) {
    return TaskPreview(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      assignedTo: json['assigned_to'] as String?,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'] as String)
          : null,
      extractedEntities: json['extracted_entities'] as Map<String, dynamic>,
      suggestedActions: (json['suggested_actions'] as List)
          .map((e) => e.toString())
          .toList(),
    );
  }
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

  Future<TaskPreview> previewTask({
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/task/preview',
        data: {
          'description': description,
        },
      );
      return TaskPreview.fromJson(response.data);
    } on DioException catch (e) {
      throw TaskApiException(
        e.response?.data?['error'] ?? 'Failed to preview task',
      );
    }
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String category,
    required String priority,
    String? assignedTo,
    DateTime? dueDate,
    Map<String, dynamic>? extractedEntities,
    List<String>? suggestedActions,
  }) async {
    try {
      final response = await _dio.post(
        '/task',
        data: {
          'title': title,
          'description': description,
          'category': category,
          'priority': priority,
          'assigned_to': assignedTo,
          'due_date': dueDate?.toIso8601String(),
          'extracted_entities': extractedEntities,
          'suggested_actions': suggestedActions,
        },
      );
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw TaskApiException(
        e.response?.data?['error'] ?? 'Failed to create task',
      );
    }
  }

  Future<TaskModel> updateTask({
    required String taskId,
    String? status,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category;
      if (priority != null) data['priority'] = priority;
      if (assignedTo != null) data['assigned_to'] = assignedTo;
      if (dueDate != null) data['due_date'] = dueDate.toIso8601String();

      final response = await _dio.put(
        '/task/$taskId',
        data: data,
      );
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw TaskApiException(
        e.response?.data?['error'] ?? 'Failed to update task',
      );
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _dio.delete('/task/$taskId');
    } on DioException catch (e) {
      throw TaskApiException(
        e.response?.data?['error'] ?? 'Failed to delete task',
      );
    }
  }
}