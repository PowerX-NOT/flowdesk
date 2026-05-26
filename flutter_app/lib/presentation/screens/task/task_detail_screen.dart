import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flow_desk/core/theme/app_theme.dart';
import 'package:flow_desk/core/utils/app_utils.dart';
import 'package:flow_desk/domain/entities/task_entity.dart';
import 'package:flow_desk/presentation/providers/app_providers.dart';
import 'package:flow_desk/presentation/screens/task/add_edit_task_screen.dart';
import 'package:flow_desk/presentation/widgets/common_widgets.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isDeleting = false;

  TaskEntity? _getTask() {
    final tasks = ref.watch(taskProvider).tasks;
    try {
      return tasks.firstWhere((t) => t.id == widget.taskId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleDelete(TaskEntity task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FlowDeskColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFCF6679),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      final success =
          await ref.read(taskProvider.notifier).deleteTask(task.id);
      setState(() => _isDeleting = false);
      if (success && mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted'),
            backgroundColor: Color(0xFFCF6679),
          ),
        );
      }
    }
  }

  void _handleEdit(TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(existingTask: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = _getTask();
    final theme = Theme.of(context);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Detail')),
        body: const Center(child: Text('Task not found')),
      );
    }

    final isOverdue = AppUtils.isOverdue(task.dueDate) &&
        task.status != TaskStatus.completed;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── Sliver App Bar ─────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: FlowDeskColors.surfaceDark,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          FlowDeskColors.primary.withOpacity(0.3),
                          FlowDeskColors.surfaceDark,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              PriorityBadge(priority: task.priority),
                              const SizedBox(width: 8),
                              StatusChip(status: task.status),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _handleEdit(task),
                    tooltip: 'Edit task',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _handleDelete(task),
                    tooltip: 'Delete task',
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFFCF6679),
                    ),
                  ),
                ],
              ),

              // ─── Content ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          decoration: task.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        _SectionLabel('Description'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: FlowDeskColors.surfaceVariantDark,
                            borderRadius: BorderRadius.circular(14),
                            border: const Border.fromBorderSide(
                                BorderSide(color: Color(0xFF3A3D4A))),
                          ),
                          child: Text(
                            task.description!,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Due Date
                      _SectionLabel('Due Date'),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        text: task.dueDate != null
                            ? AppUtils.formatDate(task.dueDate!)
                            : 'No due date set',
                        iconColor: isOverdue
                            ? FlowDeskColors.priorityHigh
                            : const Color(0xFF8D9099),
                        textColor: isOverdue ? FlowDeskColors.priorityHigh : null,
                      ),
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            AppUtils.dueDateLabel(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue
                                  ? FlowDeskColors.priorityHigh
                                  : const Color(0xFF6B6F7C),
                              fontWeight: isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Timestamps
                      _SectionLabel('Timeline'),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.add_circle_outline_rounded,
                        text: 'Created ${AppUtils.formatDate(task.createdAt)}',
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.update_rounded,
                        text: 'Updated ${AppUtils.formatDate(task.updatedAt)}',
                      ),
                      const SizedBox(height: 40),

                      // Quick status update buttons
                      _SectionLabel('Quick Update Status'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: TaskStatus.values
                            .where((s) => s != task.status)
                            .map((s) {
                          return OutlinedButton(
                            onPressed: () async {
                              await ref
                                  .read(taskProvider.notifier)
                                  .updateTask(id: task.id, status: s);
                              if (mounted) context.pop();
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            child: Text('Mark as ${s.label}'),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isDeleting) const LoadingOverlay(message: 'Deleting task...'),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Color(0xFF8D9099),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 16, color: iconColor ?? const Color(0xFF8D9099)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
