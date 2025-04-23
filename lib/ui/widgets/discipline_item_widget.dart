import 'package:flutter/material.dart';
import '../../core/models/discipline_manager.dart';

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
        key: Key(discipline.discipline + index.toString()),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        secondaryBackground: Container(
          color: Colors.blue,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.alarm, color: Colors.white),
        ),
        onDismissed: (direction) {},
        confirmDismiss: (direction) async => await onDismiss(direction),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Checkbox(
              value: discipline.isDone,
              onChanged: (value) {
                if (value != null) onToggle(value);
              },
            ),
            title: Text(
              discipline.discipline,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: discipline.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Row(
              children: [
                Text('🔥 Streak: ${discipline.streak}'),
                const SizedBox(width: 10),
                if (discipline.stars > 0)
                  Text(
                    '★ ${discipline.stars}',
                    style: const TextStyle(color: Colors.amber),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (discipline.reminderTime != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      discipline.reminderTime!.format(context),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.alarm),
                  onPressed: onSetReminder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}