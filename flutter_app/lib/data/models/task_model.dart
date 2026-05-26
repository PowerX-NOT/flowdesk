import 'package:flow_desk/domain/entities/task_entity.dart';

/// Data model for Task — handles JSON serialization/deserialization
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.priority,
    required super.status,
    super.dueDate,
    required super.ownerId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: _parsePriority(json['priority'] as String? ?? 'medium'),
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      ownerId: json['owner_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.apiValue,
        'status': status.apiValue,
        'due_date': dueDate?.toIso8601String().split('T').first,
        'owner_id': ownerId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static TaskPriority _parsePriority(String value) {
    switch (value) {
      case 'low': return TaskPriority.low;
      case 'high': return TaskPriority.high;
      default: return TaskPriority.medium;
    }
  }

  static TaskStatus _parseStatus(String value) {
    switch (value) {
      case 'in_progress': return TaskStatus.inProgress;
      case 'completed': return TaskStatus.completed;
      default: return TaskStatus.pending;
    }
  }
}
