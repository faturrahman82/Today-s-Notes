class JournalEntry {
  const JournalEntry({
    required this.date,
    required this.sentence,
    required this.mood,
    required this.theme,
  });

  final String date;
  final String sentence;
  final int mood;
  final String theme;

  Map<String, dynamic> toJson() => {
    'date': date,
    'sentence': sentence,
    'mood': mood,
    'theme': theme,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: json['date'] as String,
      sentence: json['sentence'] as String,
      mood: (json['mood'] as num).toInt(),
      theme: json['theme'] as String,
    );
  }
}
