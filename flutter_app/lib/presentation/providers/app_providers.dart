import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flow_desk/data/datasources/api_client.dart';
import 'package:flow_desk/data/datasources/auth_remote_datasource.dart';
import 'package:flow_desk/data/datasources/task_remote_datasource.dart';
import 'package:flow_desk/data/repositories/auth_repository_impl.dart';
import 'package:flow_desk/data/repositories/task_repository_impl.dart';
import 'package:flow_desk/domain/entities/task_entity.dart';
import 'package:flow_desk/domain/entities/user_entity.dart';
import 'package:flow_desk/domain/repositories/auth_repository.dart';
import 'package:flow_desk/domain/repositories/task_repository.dart';
import 'package:flow_desk/domain/usecases/auth/auth_usecases.dart';
import 'package:flow_desk/domain/usecases/task/task_usecases.dart';

// ─── Infrastructure Providers ───────────────────────────────────────────────

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  ),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(secureStorageProvider)),
);

// ─── Datasource Providers ───────────────────────────────────────────────────

final authRemoteDatasourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(apiClientProvider)),
);

final taskRemoteDatasourceProvider = Provider<TaskRemoteDataSource>(
  (ref) => TaskRemoteDataSource(ref.watch(apiClientProvider)),
);

// ─── Repository Providers ────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDatasourceProvider),
    ref.watch(secureStorageProvider),
  ),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(ref.watch(taskRemoteDatasourceProvider)),
);

// ─── Use Case Providers ──────────────────────────────────────────────────────

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);
final registerUseCaseProvider = Provider(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);
final logoutUseCaseProvider = Provider(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);
final getCurrentUserUseCaseProvider = Provider(
  (ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
);
final isAuthenticatedUseCaseProvider = Provider(
  (ref) => IsAuthenticatedUseCase(ref.watch(authRepositoryProvider)),
);

final getTasksUseCaseProvider = Provider(
  (ref) => GetTasksUseCase(ref.watch(taskRepositoryProvider)),
);
final createTaskUseCaseProvider = Provider(
  (ref) => CreateTaskUseCase(ref.watch(taskRepositoryProvider)),
);
final updateTaskUseCaseProvider = Provider(
  (ref) => UpdateTaskUseCase(ref.watch(taskRepositoryProvider)),
);
final deleteTaskUseCaseProvider = Provider(
  (ref) => DeleteTaskUseCase(ref.watch(taskRepositoryProvider)),
);

// ─── Auth State ──────────────────────────────────────────────────────────────

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({UserEntity? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState()) {
    _ref.read(apiClientProvider).onUnauthorized = () async {
      await _ref.read(logoutUseCaseProvider).call();
      state = const AuthState();
    };
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _ref.read(loginUseCaseProvider).call(email: email, password: password);
      final user = await _ref.read(getCurrentUserUseCaseProvider).call();
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _ref.read(registerUseCaseProvider).call(
        name: name, email: email,
        password: password, confirmPassword: confirmPassword,
      );
      // Auto-login after registration
      return await login(email: email, password: password);
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _ref.read(logoutUseCaseProvider).call();
    // Clear state — session lifecycle complete
    state = const AuthState();
  }

  Future<void> loadCurrentUser() async {
    try {
      final isAuth = await _ref.read(isAuthenticatedUseCaseProvider).call();
      if (!isAuth) {
        state = const AuthState();
        return;
      }
      try {
        final user = await _ref.read(getCurrentUserUseCaseProvider).call();
        state = AuthState(user: user);
      } catch (_) {
        final refreshed = await _ref
            .read(authRepositoryProvider)
            .refreshSessionIfNeeded();
        if (refreshed) {
          final user = await _ref.read(getCurrentUserUseCaseProvider).call();
          state = AuthState(user: user);
        } else {
          state = const AuthState();
        }
      }
    } catch (_) {
      state = const AuthState();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

// ─── Task State ──────────────────────────────────────────────────────────────

class TaskState {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final TaskStatus? statusFilter;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.statusFilter,
  });

  TaskState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    TaskStatus? statusFilter,
    bool clearFilter = false,
    bool clearError = false,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearFilter ? null : statusFilter ?? this.statusFilter,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final Ref _ref;
  TaskNotifier(this._ref) : super(const TaskState());

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tasks = await _ref.read(getTasksUseCaseProvider).call(
        statusFilter: state.statusFilter,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilter(TaskStatus? status) {
    state = state.copyWith(statusFilter: status, clearFilter: status == null);
  }

  Future<bool> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    required TaskStatus status,
    DateTime? dueDate,
  }) async {
    try {
      await _ref.read(createTaskUseCaseProvider).call(
        title: title, description: description,
        priority: priority, status: status, dueDate: dueDate,
      );
      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateTask({
    required int id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) async {
    try {
      await _ref.read(updateTaskUseCaseProvider).call(
        id: id, title: title, description: description,
        priority: priority, status: status, dueDate: dueDate,
      );
      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _ref.read(deleteTaskUseCaseProvider).call(id);
      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>(
  (ref) => TaskNotifier(ref),
);
