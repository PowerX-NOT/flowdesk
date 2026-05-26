import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flow_desk/core/constants/app_routes.dart';
import 'package:flow_desk/presentation/providers/app_providers.dart';
import 'package:flow_desk/presentation/screens/auth/login_screen.dart';
import 'package:flow_desk/presentation/screens/auth/register_screen.dart';
import 'package:flow_desk/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:flow_desk/presentation/screens/profile/profile_screen.dart';
import 'package:flow_desk/presentation/screens/task/add_edit_task_screen.dart';
import 'package:flow_desk/presentation/screens/task/task_detail_screen.dart';

/// Splash/redirect screen that checks auth state on launch
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // Kick off auth check once; avoid re-triggering on rebuilds.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_started) return;
      _started = true;
      await ref.read(authProvider.notifier).loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
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
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final isAuth = await ref.read(isAuthenticatedUseCaseProvider).call();
      final isOnLogin = state.matchedLocation == AppRoutes.login;
      final isOnRegister = state.matchedLocation == AppRoutes.register;
      final isOnSplash = state.matchedLocation == AppRoutes.splash;

      // Unauthenticated users should never stay on the splash loader.
      if (!isAuth) {
        if (isOnLogin || isOnRegister) return null;
        return AppRoutes.login;
      }

      // Authenticated users should skip login/register/splash.
      if (isAuth && (isOnLogin || isOnRegister || isOnSplash)) {
        return AppRoutes.dashboard;
      }

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
        path: AppRoutes.profile,
        builder: (_, __) => const ProfileScreen(),
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
