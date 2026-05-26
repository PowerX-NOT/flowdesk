import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flow_desk/core/constants/app_constants.dart';
import 'package:flow_desk/core/constants/app_routes.dart';
import 'package:flow_desk/core/theme/app_theme.dart';
import 'package:flow_desk/domain/entities/task_entity.dart';
import 'package:flow_desk/presentation/providers/app_providers.dart';
import 'package:flow_desk/presentation/widgets/common_widgets.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskProvider.notifier).loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(taskProvider.notifier).loadTasks();
  }

  void _onSearch(String query) {
    ref.read(taskProvider.notifier).setSearch(query);
    ref.read(taskProvider.notifier).loadTasks();
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FlowDeskColors.cardDark,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFCF6679)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${authState.user?.name.split(' ').first ?? 'there'} 👋',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          AppConstants.appName,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  // Task count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: FlowDeskColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: FlowDeskColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${taskState.tasks.length} tasks',
                      style: const TextStyle(
                        color: FlowDeskColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Logout',
                    style: IconButton.styleFrom(
                      backgroundColor: FlowDeskColors.surfaceVariantDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Search Bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: Color(0xFF8D9099)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ─── Status Filter Chips ────────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: taskState.statusFilter == null,
                    onTap: () {
                      ref.read(taskProvider.notifier).setFilter(null);
                      ref.read(taskProvider.notifier).loadTasks();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pending',
                    selected: taskState.statusFilter == TaskStatus.pending,
                    color: FlowDeskColors.statusPending,
                    onTap: () {
                      ref.read(taskProvider.notifier).setFilter(TaskStatus.pending);
                      ref.read(taskProvider.notifier).loadTasks();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'In Progress',
                    selected: taskState.statusFilter == TaskStatus.inProgress,
                    color: FlowDeskColors.statusInProgress,
                    onTap: () {
                      ref.read(taskProvider.notifier).setFilter(TaskStatus.inProgress);
                      ref.read(taskProvider.notifier).loadTasks();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Completed',
                    selected: taskState.statusFilter == TaskStatus.completed,
                    color: FlowDeskColors.statusCompleted,
                    onTap: () {
                      ref.read(taskProvider.notifier).setFilter(TaskStatus.completed);
                      ref.read(taskProvider.notifier).loadTasks();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── Task List ──────────────────────────────────────────────────
            Expanded(
              child: taskState.isLoading
                  ? _buildShimmerList()
                  : taskState.errorMessage != null
                      ? _buildError(taskState.errorMessage!)
                      : taskState.tasks.isEmpty
                          ? EmptyTasksWidget(
                              message: taskState.searchQuery.isNotEmpty
                                  ? 'No tasks match "${taskState.searchQuery}"'
                                  : 'No tasks yet',
                            )
                          : RefreshIndicator(
                              onRefresh: _onRefresh,
                              color: FlowDeskColors.primary,
                              backgroundColor: FlowDeskColors.cardDark,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 100),
                                itemCount: taskState.tasks.length,
                                itemBuilder: (context, index) {
                                  final task = taskState.tasks[index];
                                  return TaskCard(
                                    task: task,
                                    onTap: () => context.push(
                                      AppRoutes.taskDetailPath(task.id),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addTask),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: FlowDeskColors.cardDark,
        highlightColor: FlowDeskColors.surfaceVariantDark,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          height: 100,
          decoration: BoxDecoration(
            color: FlowDeskColors.cardDark,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: Color(0xFF6B6F7C), size: 48),
            const SizedBox(height: 16),
            Text(message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? FlowDeskColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withOpacity(0.15)
              : FlowDeskColors.surfaceVariantDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : const Color(0xFF3A3D4A),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? activeColor : const Color(0xFF8D9099),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
