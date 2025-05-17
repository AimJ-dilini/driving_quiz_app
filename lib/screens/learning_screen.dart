import 'package:flutter/material.dart';
import '../data/questions.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int currentIndex = 0;
  bool reveal = false;

  void showAnswer() {
    setState(() {
      reveal = true;
    });
  }

  void next() {
    setState(() {
      currentIndex = (currentIndex + 1) % questions.length;
      reveal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(question.imagePath, height: 200),
            const SizedBox(height: 20),
            if (reveal)
              Text(
                'Answer: ${question.options[question.correctIndex]}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            if (!reveal)
              ElevatedButton(
                onPressed: showAnswer,
                child: const Text('Reveal Answer'),
              ),
            if (reveal)
              ElevatedButton(
                onPressed: next,
                child: const Text('Next'),
              ),
          ],
        ),
      ),
    );
  }
}
