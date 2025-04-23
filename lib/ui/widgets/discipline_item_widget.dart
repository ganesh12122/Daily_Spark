import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/discipline_manager.dart';
import '../../core/providers/discipline_provider.dart';
import '../../core/services/analytics_service.dart';

class DisciplineItemWidget extends StatelessWidget {
  final DisciplineManager discipline;
  final int index;
  final Animation<double> animation;
  final ValueChanged<bool> onToggle;
  final Future<bool?> Function(DismissDirection) onDismiss;
  final VoidCallback onSetReminder;

  const DisciplineItemWidget({
    super.key,
    required this.discipline,
    required this.index,
    required this.animation,
    required this.onToggle,
    required this.onDismiss,
    required this.onSetReminder,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: Dismissible(
        key: Key(discipline.id),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          onDismiss(direction).then((result) {
            if (result == true) {
              AnalyticsService.logEvent('discipline_dismissed');
            }
          });
        },
        confirmDismiss: onDismiss,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        secondaryBackground: Container(
          color: Colors.blue,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Icon(Icons.alarm, color: Colors.white),
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Checkbox(
              value: discipline.isDone,
              onChanged: (value) {
                onToggle(value ?? false);
                AnalyticsService.logEvent('checkbox_toggled', params: {'is_done': value});
              },
            ),
            title: Text(
              discipline.discipline,
              style: TextStyle(
                decoration: discipline.isDone ? TextDecoration.lineThrough : null,
                color: discipline.isDone ? Colors.grey : null,
              ),
            ),
            subtitle: discipline.hasCommitment
                ? Text(
              'Committed: ${discipline.streak}/48 days (${discipline.stars}★)',
              style: const TextStyle(color: Colors.orange),
            )
                : Text(
              'Streak: ${discipline.streak} days (${discipline.stars}★)',
              style: const TextStyle(color: Colors.green),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.alarm),
              onPressed: onSetReminder,
              tooltip: 'Set Reminder',
            ),
          ),
        ),
      ),
    );
  }
}