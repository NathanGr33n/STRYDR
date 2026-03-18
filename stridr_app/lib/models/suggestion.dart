enum SuggestionType { longerRun, restDay }

class Suggestion {
  final SuggestionType type;
  final String title;
  final String message;
  final DateTime createdAt;
  bool dismissed;

  Suggestion({
    required this.type,
    required this.title,
    required this.message,
    DateTime? createdAt,
    this.dismissed = false,
  }) : createdAt = createdAt ?? DateTime.now();

  String get icon {
    switch (type) {
      case SuggestionType.longerRun:
        return '🏃';
      case SuggestionType.restDay:
        return '😴';
    }
  }
}
