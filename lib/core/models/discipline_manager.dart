import 'package:flutter/material.dart';

class DisciplineManager {
  String id;
  String discipline;
  bool isDone;
  int streak;
  double successRate;
  DateTime lastCompleted;
  TimeOfDay? reminderTime;
  DateTime? commitmentStartDate;
  int stars;
  bool hasCommitment;

  DisciplineManager({
    required this.id,
    required this.discipline,
    this.isDone = false,
    this.streak = 0,
    this.successRate = 0.0,
    required this.lastCompleted,
    this.reminderTime,
    this.commitmentStartDate,
    this.stars = 0,
    this.hasCommitment = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'discipline': discipline,
    'isDone': isDone,
    'streak': streak,
    'successRate': successRate,
    'lastCompleted': lastCompleted.toIso8601String(),
    'reminderTime': reminderTime != null
        ? '${reminderTime!.hour}:${reminderTime!.minute}'
        : null,
    'commitmentStartDate': commitmentStartDate?.toIso8601String(),
    'stars': stars,
    'hasCommitment': hasCommitment,
  };

  factory DisciplineManager.fromJson(Map<String, dynamic> json) {
    final reminderTimeStr = json['reminderTime'] as String?;
    TimeOfDay? reminderTime;
    if (reminderTimeStr != null) {
      final parts = reminderTimeStr.split(':');
      reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return DisciplineManager(
      id: json['id'],
      discipline: json['discipline'],
      isDone: json['isDone'],
      streak: json['streak'],
      successRate: json['successRate'].toDouble(),
      lastCompleted: DateTime.parse(json['lastCompleted']),
      reminderTime: reminderTime,
      commitmentStartDate: json['commitmentStartDate'] != null
          ? DateTime.parse(json['commitmentStartDate'])
          : null,
      stars: json['stars'] ?? 0,
      hasCommitment: json['hasCommitment'] ?? true,
    );
  }
}