import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flow_desk/core/theme/app_theme.dart';
import 'package:flow_desk/core/utils/validators.dart';
import 'package:flow_desk/domain/entities/task_entity.dart';
import 'package:flow_desk/presentation/providers/app_providers.dart';
import 'package:flow_desk/presentation/widgets/common_widgets.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final TaskEntity? existingTask; // null = create mode

  const AddEditTaskScreen({super.key, this.existingTask});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.pending;
  DateTime? _dueDate;
  bool _isSaving = false;

  bool get _isEditMode => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final t = widget.existingTask!;
      _titleController.text = t.title;
      _descController.text = t.description ?? '';
      _priority = t.priority;
      _status = t.status;
      _dueDate = t.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: FlowDeskColors.primary,
            surface: FlowDeskColors.cardDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    bool success;
    if (_isEditMode) {
      success = await ref.read(taskProvider.notifier).updateTask(
        id: widget.existingTask!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
      );
    } else {
      success = await ref.read(taskProvider.notifier).createTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
      );
    }

    setState(() => _isSaving = false);
    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Task updated!' : 'Task created!'),
          backgroundColor: FlowDeskColors.priorityLow,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(
              _isEditMode ? 'Update' : 'Create',
              style: const TextStyle(
                color: FlowDeskColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  FlowTextField(
                    label: 'Task Title',
                    hint: 'What needs to be done?',
                    controller: _titleController,
                    validator: (v) => Validators.required(v, fieldName: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  FlowTextField(
                    label: 'Description',
                    hint: 'Add details (optional)',
                    controller: _descController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // ─── Priority ───────────────────────────────────────────
                  Text('Priority', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: TaskPriority.values.map((p) {
                      final isSelected = _priority == p;
                      final color = switch (p) {
                        TaskPriority.low => FlowDeskColors.priorityLow,
                        TaskPriority.medium => FlowDeskColors.priorityMedium,
                        TaskPriority.high => FlowDeskColors.priorityHigh,
                      };
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _priority = p),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withOpacity(0.18)
                                    : FlowDeskColors.surfaceVariantDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : const Color(0xFF3A3D4A),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    p == TaskPriority.low
                                        ? Icons.arrow_downward_rounded
                                        : p == TaskPriority.medium
                                            ? Icons.remove_rounded
                                            : Icons.arrow_upward_rounded,
                                    color: isSelected ? color : const Color(0xFF8D9099),
                                    size: 18,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.label,
                                    style: TextStyle(
                                      color: isSelected ? color : const Color(0xFF8D9099),
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ─── Status ─────────────────────────────────────────────
                  Text('Status', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: FlowDeskColors.surfaceVariantDark,
                      borderRadius: BorderRadius.circular(14),
                      border: const Border.fromBorderSide(
                          BorderSide(color: Color(0xFF3A3D4A))),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TaskStatus>(
                        value: _status,
                        isExpanded: true,
                        dropdownColor: FlowDeskColors.cardDark,
                        style: theme.textTheme.bodyLarge,
                        onChanged: (v) => setState(() => _status = v!),
                        items: TaskStatus.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s.label),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Due Date ────────────────────────────────────────────
                  Text('Due Date', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDueDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: FlowDeskColors.surfaceVariantDark,
                        borderRadius: BorderRadius.circular(14),
                        border: const Border.fromBorderSide(
                            BorderSide(color: Color(0xFF3A3D4A))),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 20, color: Color(0xFF8D9099)),
                          const SizedBox(width: 12),
                          Text(
                            _dueDate != null
                                ? DateFormat('EEE, d MMM yyyy').format(_dueDate!)
                                : 'Select due date (optional)',
                            style: TextStyle(
                              color: _dueDate != null
                                  ? FlowDeskColors.onSurfaceDark
                                  : const Color(0xFF6B6F7C),
                            ),
                          ),
                          const Spacer(),
                          if (_dueDate != null)
                            GestureDetector(
                              onTap: () => setState(() => _dueDate = null),
                              child: const Icon(Icons.close_rounded,
                                  size: 18, color: Color(0xFF8D9099)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          if (_isSaving) const LoadingOverlay(message: 'Saving task...'),
        ],
      ),
    );
  }
}
