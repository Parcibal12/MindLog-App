class Analytics {
  final int totalEntries;
  final String dominantEmotion;
  final String dominantPattern;
  final List<ContextTagCount> topDisparadores;

  const Analytics({
    required this.totalEntries,
    required this.dominantEmotion,
    required this.dominantPattern,
    required this.topDisparadores,
  });
}

class ContextTagCount {
  final String tagName;
  final int count;
  final String dominantEmotion;

  const ContextTagCount({
    required this.tagName,
    required this.count,
    required this.dominantEmotion,
  });
}
