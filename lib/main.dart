import 'package:driving_quiz_app/models/question.dart';
import 'package:driving_quiz_app/screens/add_question_screen.dart';
import 'package:driving_quiz_app/screens/manage_questions_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/quiz_screen.dart';
import 'screens/learning_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  Hive.registerAdapter(QuestionAdapter());
  await Hive.openBox<Question>('questionsBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Driving Quiz App', theme: ThemeData(primarySwatch: Colors.blue), home: const HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driving Test App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Start Quiz Mode'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Start Learning Mode'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen()));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Question"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddQuestionScreen()));
              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text("Manage Questions"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageQuestionsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
