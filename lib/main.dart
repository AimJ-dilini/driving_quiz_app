import 'package:flutter/material.dart';
import 'screens/quiz_screen.dart';
import 'screens/learning_screen.dart';

void main() {
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
          ],
        ),
      ),
    );
  }
}
