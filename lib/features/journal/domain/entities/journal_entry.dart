class JournalEntry {
  final String userId;
  final String content;
  final int emotionId;
  final String emotionName;
  final int intensity;
  final List<int> contextTagIds;
  final DateTime createdAt;
  final String? aiFeedback;
  final String? aiPattern;

  const JournalEntry({
    required this.userId,
    required this.content,
    required this.emotionId,
    required this.emotionName,
    required this.intensity,
    required this.contextTagIds,
    required this.createdAt,
    this.aiFeedback,
    this.aiPattern,
  });
}
