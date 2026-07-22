import 'package:flutter/material.dart';

import '../../../../core/utils/date_time_extension.dart';
import '../../domain/entities/reminder.dart';
import 'category_chip.dart';
import 'priority_badge.dart';

/// Card reminder untuk Home Screen — rounded, soft shadow, dan strip
/// warna di kiri sesuai warna yang dipilih user saat membuat reminder.
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.use24Hour,
    required this.onTap,
    required this.onToggleComplete,
  });

  final Reminder reminder;
  final bool use24Hour;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  @override
  Widget build(BuildContext context) {
    final color = Color(reminder.colorValue);
    final scheme = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: reminder.isCompleted ? 0.6 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 6, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reminder.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: reminder.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: onToggleComplete,
                              icon: Icon(
                                reminder.isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: reminder.isCompleted
                                    ? scheme.primary
                                    : scheme.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminder.dueDateTime
                              .toDisplayDateTime(use24Hour: use24Hour),
                          style: TextStyle(
                            fontSize: 13,
                            color: reminder.isOverdue
                                ? scheme.error
                                : scheme.outline,
                            fontWeight: reminder.isOverdue
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            PriorityBadge(priority: reminder.priority),
                            CategoryChip(label: reminder.category),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
