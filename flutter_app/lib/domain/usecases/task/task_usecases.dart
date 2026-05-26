import 'package:flow_desk/domain/entities/task_entity.dart';
import 'package:flow_desk/domain/repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository _repository;
  const GetTasksUseCase(this._repository);

  Future<List<TaskEntity>> call({TaskStatus? statusFilter, String? search}) {
    return _repository.getTasks(statusFilter: statusFilter, search: search);
  }
}

class GetTaskUseCase {
  final TaskRepository _repository;
  const GetTaskUseCase(this._repository);

  Future<TaskEntity> call(int id) => _repository.getTask(id);
}

class CreateTaskUseCase {
  final TaskRepository _repository;
  const CreateTaskUseCase(this._repository);

  Future<TaskEntity> call({
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
  }) {
    return _repository.createTask(
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
    );
  }
}

class UpdateTaskUseCase {
  final TaskRepository _repository;
  const UpdateTaskUseCase(this._repository);

  Future<TaskEntity> call({
    required int id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) {
    return _repository.updateTask(
      id: id,
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
    );
  }
}

class DeleteTaskUseCase {
  final TaskRepository _repository;
  const DeleteTaskUseCase(this._repository);

  Future<void> call(int id) => _repository.deleteTask(id);
}
