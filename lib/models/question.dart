class Question {
  final String imagePath;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.imagePath,
    required this.options,
    required this.correctIndex,
  });
}
