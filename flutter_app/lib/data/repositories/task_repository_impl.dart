import 'package:flow_desk/data/datasources/task_remote_datasource.dart';
import 'package:flow_desk/domain/entities/task_entity.dart';
import 'package:flow_desk/domain/repositories/task_repository.dart';

/// Concrete implementation of [TaskRepository]
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _dataSource;
  TaskRepositoryImpl(this._dataSource);

  @override
  Future<List<TaskEntity>> getTasks({
    TaskStatus? statusFilter,
    String? search,
  }) => _dataSource.getTasks(statusFilter: statusFilter, search: search);

  @override
  Future<TaskEntity> getTask(int id) => _dataSource.getTask(id);

  @override
  Future<TaskEntity> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
  }) => _dataSource.createTask(
        title: title,
        description: description,
        priority: priority,
        status: status,
        dueDate: dueDate,
      );

  @override
  Future<TaskEntity> updateTask({
    required int id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) => _dataSource.updateTask(
        id: id,
        title: title,
        description: description,
        priority: priority,
        status: status,
        dueDate: dueDate,
      );

  @override
  Future<void> deleteTask(int id) => _dataSource.deleteTask(id);
}
