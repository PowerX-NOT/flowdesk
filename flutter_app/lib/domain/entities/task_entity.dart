/// Task priority levels
enum TaskPriority { low, medium, high }

/// Task lifecycle status
enum TaskStatus { pending, inProgress, completed }

extension TaskPriorityExt on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low: return 'Low';
      case TaskPriority.medium: return 'Medium';
      case TaskPriority.high: return 'High';
    }
  }

  String get apiValue {
    switch (this) {
      case TaskPriority.low: return 'low';
      case TaskPriority.medium: return 'medium';
      case TaskPriority.high: return 'high';
    }
  }
}

extension TaskStatusExt on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.pending: return 'Pending';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.completed: return 'Completed';
    }
  }

  String get apiValue {
    switch (this) {
      case TaskStatus.pending: return 'pending';
      case TaskStatus.inProgress: return 'in_progress';
      case TaskStatus.completed: return 'completed';
    }
  }
}

/// Pure domain entity for Task
class TaskEntity {
  final int id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final int ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  TaskEntity copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) {
    return TaskEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
