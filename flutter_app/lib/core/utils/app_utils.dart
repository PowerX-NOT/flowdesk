import 'package:intl/intl.dart';

/// Utility helpers for FlowDesk
class AppUtils {
  AppUtils._();

  /// Format date as "Mon, 26 May 2026"
  static String formatDate(DateTime date) {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  /// Format date as "26 May" (short)
  static String formatDateShort(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  /// Returns true if the date is in the past
  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  /// Returns remaining days string for due date label
  static String dueDateLabel(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    final diff = dueDate.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Overdue by ${diff.abs()} day${diff.abs() == 1 ? '' : 's'}';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due in $diff days';
  }
}
