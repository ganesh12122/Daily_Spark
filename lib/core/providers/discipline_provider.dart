import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/discipline_manager.dart';

class DisciplineProvider extends ChangeNotifier {
  List<DisciplineManager> _list = [];
  bool _darkMode = false;
  int _totalMedals = 0;
  int _quickWins = 0;

  List<DisciplineManager> get list => _list;
  bool get darkMode => _darkMode;
  int get totalMedals => _totalMedals;
  int get quickWins => _quickWins;

  String get achievementLevel {
    final completed = _list.where((d) => d.isDone).length;
    final total = _list.length;
    if (total == 0) return 'none';
    final completionRate = completed / total;
    if (completionRate == 1.0) return 'gold';
    if (completionRate >= 0.75) return 'silver';
    return 'none';
  }

  double get todayCompletionRate {
    final completed = _list.where((d) => d.isDone).length;
    final total = _list.length;
    return total > 0 ? completed / total : 0.0;
  }

  void addNewDiscipline(String discipline, bool hasCommitment) {
    _list.add(DisciplineManager(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      discipline: discipline,
      lastCompleted: DateTime(1970), // Initialize to epoch to avoid completion display
      commitmentStartDate: hasCommitment ? DateTime.now() : null,
      hasCommitment: hasCommitment,
    ));
    _saveToPrefs();
    notifyListeners();
  }

  void removeDiscipline(int index) {
    _list.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  void toggleCompletion(int index) {
    final discipline = _list[index];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      discipline.lastCompleted.year,
      discipline.lastCompleted.month,
      discipline.lastCompleted.day,
    );

    if (discipline.isDone) {
      discipline.isDone = false;
      discipline.lastCompleted = DateTime(1970); // Reset to epoch when unchecked
      discipline.streak = 0;
      discipline.successRate = _calculateSuccessRate(discipline);
    } else {
      discipline.isDone = true;
      discipline.lastCompleted = now;
      if (lastCompleted != today) {
        discipline.streak++;
      }
      discipline.successRate = _calculateSuccessRate(discipline);
      _checkMilestone(index);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void _checkMilestone(int index) {
    final discipline = _list[index];
    if (discipline.hasCommitment && discipline.streak >= 48 && discipline.stars < (discipline.streak / 48).floor()) {
      discipline.stars = (discipline.streak / 48).floor();
      if (discipline.stars == 1) {
        _totalMedals += 100;
      } else {
        _totalMedals += 50;
      }
      if (discipline.stars >= 3) {
        _saveIronWillBadge();
      }
      _saveToPrefs();
    } else if (!discipline.hasCommitment && discipline.streak >= 7 && discipline.stars == 0) {
      discipline.stars = 1; // Quick Win badge
      _quickWins += 1;
      _saveToPrefs();
    }
  }

  bool canDeleteDiscipline(DisciplineManager discipline) {
    if (!discipline.hasCommitment) {
      return true;
    }
    if (discipline.streak < 48) {
      return false;
    }
    return true;
  }

  void updateReminder(int index, TimeOfDay time) {
    _list[index].reminderTime = time;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final disciplineData = prefs.getString('disciplines');
    final darkMode = prefs.getBool('darkMode') ?? false;
    _totalMedals = prefs.getInt('totalMedals') ?? 0;
    _quickWins = prefs.getInt('quickWins') ?? 0;

    if (disciplineData != null) {
      final List<dynamic> json = jsonDecode(disciplineData);
      _list = json.map((item) => DisciplineManager.fromJson(item)).toList();
    }
    _darkMode = darkMode;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final disciplineData = jsonEncode(_list.map((d) => d.toJson()).toList());
    await prefs.setString('disciplines', disciplineData);
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setInt('totalMedals', _totalMedals);
    await prefs.setInt('quickWins', _quickWins);
  }

  Future<void> _saveIronWillBadge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ironWillBadge', true);
  }

  double _calculateSuccessRate(DisciplineManager discipline) {
    return discipline.streak > 0 ? (discipline.streak / (discipline.streak + 1)) * 100 : 0.0;
  }
}