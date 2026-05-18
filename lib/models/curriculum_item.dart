class CurriculumItem {
  final String id;
  final String stage;
  final int order;
  final String character;
  final String reading;
  final String description;
  final String dotPattern;
  final String ttsGuide;
  final String goal;

  const CurriculumItem({
    required this.id,
    required this.character,
    required this.description,
    this.stage = '',
    this.order = 0,
    this.reading = '',
    this.dotPattern = '',
    this.ttsGuide = '',
    this.goal = '',
  });

  String get title {
    if (reading.isEmpty) return character;
    return '$character - $reading';
  }

  bool get usesMultipleCells {
    return dotPattern.contains('셀1') ||
        dotPattern.contains('셀2') ||
        dotPattern.contains('/');
  }
}