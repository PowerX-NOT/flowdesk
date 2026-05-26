import 'package:flow_desk/domain/entities/task_entity.dart';

/// Abstract repository interface for task operations
abstract class TaskRepository {
  /// Fetch tasks for current user with optional filters
  Future<List<TaskEntity>> getTasks({
    TaskStatus? statusFilter,
    String? search,
  });

  /// Get a single task by ID
  Future<TaskEntity> getTask(int id);

  /// Create a new task
  Future<TaskEntity> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
  });

  /// Update an existing task
  Future<TaskEntity> updateTask({
    required int id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  });

  /// Delete a task by ID
  Future<void> deleteTask(int id);
}
