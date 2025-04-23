class DiaryEntry {
  final String id;
  final DateTime date;
  final String thoughts;
  final String? mood;

  DiaryEntry({
    required this.id,
    required this.date,
    required this.thoughts,
    this.mood,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'thoughts': thoughts,
    'mood': mood,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      thoughts: json['thoughts'],
      mood: json['mood'],
    );
  }
}