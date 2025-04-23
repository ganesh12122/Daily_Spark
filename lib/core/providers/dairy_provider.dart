import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/dairy_entry.dart';


class DiaryProvider extends ChangeNotifier {
  List<DiaryEntry> _entries = [];
  int _reflectionStreak = 0;

  List<DiaryEntry> get entries => _entries;
  int get reflectionStreak => _reflectionStreak;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final diaryData = prefs.getString('diary_entries');
    if (diaryData != null) {
      final List<dynamic> json = jsonDecode(diaryData);
      _entries = json.map((item) => DiaryEntry.fromJson(item)).toList();
    }
    _updateReflectionStreak();
    notifyListeners();
  }

  void addEntry(String thoughts, {String? mood}) {
    final now = DateTime.now();
    _entries.add(DiaryEntry(
      id: now.millisecondsSinceEpoch.toString(),
      date: now,
      thoughts: thoughts,
      mood: mood,
    ));
    _updateReflectionStreak();
    _saveToPrefs();
    notifyListeners();
  }

  void updateEntry(String id, String thoughts, {String? mood}) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = DiaryEntry(
        id: _entries[index].id,
        date: _entries[index].date,
        thoughts: thoughts,
        mood: mood ?? _entries[index].mood,
      );
      _updateReflectionStreak();
      _saveToPrefs();
      notifyListeners();
    }
  }

  void _updateReflectionStreak() {
    if (_entries.isEmpty) {
      _reflectionStreak = 0;
      return;
    }
    _entries.sort((a, b) => b.date.compareTo(a.date));
    int streak = 1;
    DateTime previousDate = DateTime(
      _entries[0].date.year,
      _entries[0].date.month,
      _entries[0].date.day,
    );
    for (int i = 1; i < _entries.length; i++) {
      final currentDate = DateTime(
        _entries[i].date.year,
        _entries[i].date.month,
        _entries[i].date.day,
      );
      if (previousDate.difference(currentDate).inDays == 1) {
        streak++;
        previousDate = currentDate;
      } else {
        break;
      }
    }
    _reflectionStreak = streak;
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final diaryData = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('diary_entries', diaryData);
  }
}