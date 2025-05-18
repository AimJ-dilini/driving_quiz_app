import 'dart:io';

import 'package:driving_quiz_app/models/question.dart';
import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../widgets/option_button.dart';
import '../data/question_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  bool answered = false;
  int selectedIndex = -1;
  late List<Question> allQuestions;

  @override
  void initState() {
    super.initState();
    allQuestions = [...questions, ...getAllQuestions()];
  }

  void nextQuestion() {
    setState(() {
      currentQuestion = (currentQuestion + 1) % allQuestions.length;
      answered = false;
      selectedIndex = -1;
    });
  }

  void checkAnswer(int index) {
    if (answered) return;
    setState(() {
      selectedIndex = index;
      answered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (allQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Driving Test Quiz')),
        body: const Center(child: Text("No questions available.")), //
      );
    }

    final question = allQuestions[currentQuestion];
    return Scaffold(
      appBar: AppBar(title: const Text('Driving Test Quiz')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (question.imagePath != null)
            // Image.asset(question.imagePath!, height: 200)
            question.imagePath != null && question.imagePath!.startsWith('assets/')
                ? Image.asset(question.imagePath!, height: 200)
                : Image.file(File(question.imagePath!), height: 200)
          else
            const SizedBox(height: 10),
          const SizedBox(height: 20),
          ...List.generate(question.options.length, (index) {
            return OptionButton(
              text: question.options[index],
              isCorrect: index == question.correctIndex,
              isSelected: index == selectedIndex,
              wasAnswered: answered,
              onTap: () => checkAnswer(index),
            );
          }),
          const SizedBox(height: 20),
          if (answered) ElevatedButton(onPressed: nextQuestion, child: const Text('Next Question')),
        ],
      ),
    );
  }
}
