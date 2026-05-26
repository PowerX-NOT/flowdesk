import 'package:flutter/material.dart';
import 'package:flow_desk/core/theme/app_theme.dart';
import 'package:flow_desk/core/utils/app_utils.dart';
import 'package:flow_desk/domain/entities/task_entity.dart';

/// Priority badge chip with color-coded background
class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool compact;

  const PriorityBadge({super.key, required this.priority, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (priority) {
      TaskPriority.low => (FlowDeskColors.priorityLow, Icons.arrow_downward_rounded),
      TaskPriority.medium => (FlowDeskColors.priorityMedium, Icons.remove_rounded),
      TaskPriority.high => (FlowDeskColors.priorityHigh, Icons.arrow_upward_rounded),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: color),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status chip with icon and color
class StatusChip extends StatelessWidget {
  final TaskStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      TaskStatus.pending => (FlowDeskColors.statusPending, Icons.schedule_rounded),
      TaskStatus.inProgress => (FlowDeskColors.statusInProgress, Icons.play_circle_rounded),
      TaskStatus.completed => (FlowDeskColors.statusCompleted, Icons.check_circle_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Task card for dashboard list
class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = AppUtils.isOverdue(task.dueDate) &&
        task.status != TaskStatus.completed;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == TaskStatus.completed
                            ? const Color(0xFF6B6F7C)
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PriorityBadge(priority: task.priority, compact: true),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  StatusChip(status: task.status),
                  const Spacer(),
                  if (task.dueDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: isOverdue
                              ? FlowDeskColors.priorityHigh
                              : const Color(0xFF8D9099),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppUtils.formatDateShort(task.dueDate!),
                          style: TextStyle(
                            fontSize: 11,
                            color: isOverdue
                                ? FlowDeskColors.priorityHigh
                                : const Color(0xFF8D9099),
                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom text field with consistent FlowDesk styling
class FlowTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final void Function(String)? onChanged;

  const FlowTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}

/// Full-screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: FlowDeskColors.cardDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: FlowDeskColors.primary),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget for dashboard
class EmptyTasksWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onAddTask;

  const EmptyTasksWidget({
    super.key,
    this.message = 'No tasks yet',
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: FlowDeskColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 40,
                color: FlowDeskColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first task',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
