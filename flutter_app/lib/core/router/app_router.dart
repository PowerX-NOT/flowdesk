import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flow_desk/core/constants/app_routes.dart';
import 'package:flow_desk/presentation/providers/app_providers.dart';
import 'package:flow_desk/presentation/screens/auth/login_screen.dart';
import 'package:flow_desk/presentation/screens/auth/register_screen.dart';
import 'package:flow_desk/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:flow_desk/presentation/screens/task/add_edit_task_screen.dart';
import 'package:flow_desk/presentation/screens/task/task_detail_screen.dart';

/// Splash/redirect screen that checks auth state on launch
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger auth check — router redirect will navigate accordingly
    ref.read(authProvider.notifier).loadCurrentUser();
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// App router with auth-gated navigation.
/// Unauthenticated users are redirected to /login from any protected route.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final isAuth = await ref.read(isAuthenticatedUseCaseProvider).call();
      final isOnAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      // Not authenticated → redirect to login
      if (!isAuth && !isOnAuth) return AppRoutes.login;

      // Already authenticated → skip auth screens
      if (isAuth && isOnAuth) return AppRoutes.dashboard;

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.addTask,
        builder: (_, __) => const AddEditTaskScreen(),
      ),
      GoRoute(
        path: AppRoutes.taskDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TaskDetailScreen(taskId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.editTask,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final taskState = ref.read(taskProvider);
          final task = taskState.tasks.firstWhere((t) => t.id == id);
          return AddEditTaskScreen(existingTask: task);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
