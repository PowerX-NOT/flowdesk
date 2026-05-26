import 'package:dio/dio.dart';
import 'package:flow_desk/data/datasources/api_client.dart';
import 'package:flow_desk/data/models/task_model.dart';
import 'package:flow_desk/domain/entities/task_entity.dart';

/// Remote data source for all task API calls
class TaskRemoteDataSource {
  final ApiClient _apiClient;
  TaskRemoteDataSource(this._apiClient);

  Future<List<TaskModel>> getTasks({
    TaskStatus? statusFilter,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (statusFilter != null) queryParams['status'] = statusFilter.apiValue;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiClient.dio.get(
        '/tasks/',
        queryParameters: queryParams,
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.failure;
    }
  }

  Future<TaskModel> getTask(int id) async {
    try {
      final response = await _apiClient.dio.get('/tasks/$id');
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.failure;
    }
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'priority': priority.apiValue,
        'status': status.apiValue,
      };
      if (description != null) data['description'] = description;
      if (dueDate != null) data['due_date'] = dueDate.toIso8601String().split('T').first;

      final response = await _apiClient.dio.post('/tasks/', data: data);
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.failure;
    }
  }

  Future<TaskModel> updateTask({
    required int id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (priority != null) data['priority'] = priority.apiValue;
      if (status != null) data['status'] = status.apiValue;
      if (dueDate != null) data['due_date'] = dueDate.toIso8601String().split('T').first;

      final response = await _apiClient.dio.put('/tasks/$id', data: data);
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.failure;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _apiClient.dio.delete('/tasks/$id');
    } on DioException catch (e) {
      throw e.failure;
    }
  }
}
