import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../widgets/option_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  bool answered = false;
  int selectedIndex = -1;

  void nextQuestion() {
    setState(() {
      currentQuestion = (currentQuestion + 1) % questions.length;
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
    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(title: const Text('Driving Test Quiz')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(question.imagePath, height: 200),
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
