import 'package:hive/hive.dart';
import '../models/question.dart';

List<Question> getAllQuestions() {
  final box = Hive.box<Question>('questionsBox');
  return box.values.toList();
}
