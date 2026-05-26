/// Named route paths for go_router
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String addTask = '/tasks/add';
  static const String editTask = '/tasks/edit/:id';
  static const String taskDetail = '/tasks/:id';

  static String editTaskPath(int id) => '/tasks/edit/$id';
  static String taskDetailPath(int id) => '/tasks/$id';
}
