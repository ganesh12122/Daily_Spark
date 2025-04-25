import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/dairy_entry.dart';
import '../../core/providers/dairy_provider.dart';


class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _thoughtsController = TextEditingController();
  DiaryEntry? _todayEntry;
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTodayEntry();
    });
  }

  void _updateTodayEntry() {
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    setState(() {
      _todayEntry = diaryProvider.entries.firstWhere(
            (entry) {
          final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
          return entryDate == todayDate;
        },
        orElse: () => DiaryEntry(id: '', date: today, thoughts: '', mood: null),
      );
      if (_todayEntry!.thoughts.isNotEmpty) {
        _thoughtsController.text = _todayEntry!.thoughts;
        _selectedMood = _todayEntry!.mood;
      } else {
        _thoughtsController.clear();
        _selectedMood = null;
      }
    });
  }

  @override
  void dispose() {
    _thoughtsController.dispose();
    super.dispose();
  }

  void _saveThoughts(DiaryProvider diaryProvider) {
    if (_thoughtsController.text.trim().isEmpty) return;
    if (_todayEntry!.id.isEmpty) {
      diaryProvider.addEntry(_thoughtsController.text.trim(), mood: _selectedMood);
    } else {
      diaryProvider.updateEntry(_todayEntry!.id, _thoughtsController.text.trim(), mood: _selectedMood);
    }
    _updateTodayEntry();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thoughts saved!')),
    );
  }

  void _startEditing(BuildContext context, DiaryEntry entry) {
    _thoughtsController.text = entry.thoughts;
    _selectedMood = entry.mood;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _thoughtsController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Edit your thoughts...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: _selectedMood,
                  hint: const Text('How are you feeling?'),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'Happy', child: Text('😊 Happy')),
                    DropdownMenuItem(value: 'Stressed', child: Text('😓 Stressed')),
                    DropdownMenuItem(value: 'Motivated', child: Text('🔥 Motivated')),
                    DropdownMenuItem(value: 'Tired', child: Text('😴 Tired')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMood = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
                    diaryProvider.updateEntry(entry.id, _thoughtsController.text.trim(), mood: _selectedMood);
                    Navigator.pop(context);
                    _updateTodayEntry();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = Provider.of<DiaryProvider>(context);
    final today = DateTime.now();

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<DiaryProvider>(
                      builder: (context, diaryProvider, child) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'YOUR REFLECTIONS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            '🔥 Streak: ${diaryProvider.reflectionStreak}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.yellow[50],
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today, ${DateFormat('MMM d, y').format(today)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_todayEntry != null && _todayEntry!.mood != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Feeling: ${_todayEntry!.mood}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              _todayEntry?.thoughts.isEmpty ?? true
                                  ? 'Tap to write your thoughts...'
                                  : _todayEntry!.thoughts,
                              style: TextStyle(
                                fontSize: 14,
                                color: _todayEntry?.thoughts.isEmpty ?? true ? Colors.grey : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Past Reflections',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final entry = diaryProvider.entries[index];
                    final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
                    final todayDate = DateTime(today.year, today.month, today.day);
                    if (entryDate == todayDate) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => _startEditing(context, entry),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM d, y').format(entry.date),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (entry.mood != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Feeling: ${entry.mood}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  entry.thoughts,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: diaryProvider.entries.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            onPressed: () {
              _thoughtsController.clear();
              _selectedMood = null;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _thoughtsController,
                            maxLines: 10,
                            decoration: InputDecoration(
                              hintText: 'How was your day? Write your thoughts here...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButton<String>(
                            value: _selectedMood,
                            hint: const Text('How are you feeling?'),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'Happy', child: Text('😊 Happy')),
                              DropdownMenuItem(value: 'Stressed', child: Text('😓 Stressed')),
                              DropdownMenuItem(value: 'Motivated', child: Text('🔥 Motivated')),
                              DropdownMenuItem(value: 'Tired', child: Text('😴 Tired')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedMood = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
                              _saveThoughts(diaryProvider);
                              Navigator.pop(context);
                            },
                            child: const Text('Save Thoughts'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}