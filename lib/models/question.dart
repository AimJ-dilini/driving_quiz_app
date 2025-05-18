import 'package:hive/hive.dart';

part 'question.g.dart';
 
@HiveType(typeId: 0)
class Question extends HiveObject {
  @HiveField(0)
  String? imagePath;  
  
  @HiveField(1)
  List<String> options;

  @HiveField(2)
  int correctIndex;

  @HiveField(3)
  bool markedForReview;

  @HiveField(4)
  bool isCustom;

  @HiveField(5)
  String? questionText; 

  Question({
    this.imagePath,
    required this.options,
    required this.correctIndex,
    this.markedForReview = false,
    this.isCustom = false,
    this.questionText,
  });
}

