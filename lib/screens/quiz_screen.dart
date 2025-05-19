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
  bool onlyCustom = false;
  bool onlyReview = false;
  int correctAnswers = 0;
  int totalAnswered = 0;
  bool quizCompleted = false;

  @override
  void initState() {
    super.initState();
    // allQuestions = [...questions, ...getAllQuestions()];
    updateQuestionList();
  }

  void updateQuestionList() {
    final all = [...questions, ...getAllQuestions()];
    allQuestions = onlyCustom ? all.where((q) => q.isCustom).toList() : all;

    // Filter based on both toggles
    allQuestions =
        all.where((q) {
          if (onlyCustom && !q.isCustom) return false;
          if (onlyReview && !q.markedForReview) return false;
          return true;
        }).toList();
    currentQuestion = 0;
    answered = false;
    selectedIndex = -1;
  }

  void nextQuestion() {
    if (quizCompleted) {
      showSummaryDialog();
      return;
    }
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
      totalAnswered++;

      if (index == allQuestions[currentQuestion].correctIndex) {
        correctAnswers++;
      }

      // Check if it's the last question
      if (currentQuestion == allQuestions.length - 1) {
        quizCompleted = true;
      }
    });
  }

  void toggleOnlyCustom() {
    setState(() {
      onlyCustom = !onlyCustom;
      updateQuestionList();
    });
  }

  void toggleOnlyReview() {
    setState(() {
      onlyReview = !onlyReview;
      updateQuestionList();
    });
  }

  void toggleMarkForReview() {
    setState(() {
      final question = allQuestions[currentQuestion];
      question.markedForReview = !question.markedForReview;
    });

    // final marked = allQuestions[currentQuestion].markedForReview;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(marked ? 'Marked for review' : 'Unmarked from review'), //
    //     duration: Duration(seconds: 2),
    //     backgroundColor: marked ? Colors.green : Colors.red,
    //   ),
    // );
  }

  // Function to show a summary dialog at the end of the quiz
  void showSummaryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Quiz Completed'),
            content: Text('You got $correctAnswers out of ${allQuestions.length} correct.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    currentQuestion = 0;
                    answered = false;
                    selectedIndex = -1;
                    correctAnswers = 0;
                    totalAnswered = 0;
                    quizCompleted = false;
                  });
                },
                child: const Text('Restart Quiz'),
              ),
              TextButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('Exit')),
            ],
          ),
    );
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
      appBar: AppBar(
        title: const Text('Driving Test Quiz'),
        actions: [
          IconButton(
            icon: Icon(onlyCustom ? Icons.star : Icons.star_border),
            tooltip: 'Toggle Custom Only',
            onPressed: toggleOnlyCustom, //
          ),
          IconButton(
            icon: Icon(onlyReview ? Icons.bookmark : Icons.bookmark_border),
            tooltip: 'Only Review Questions',
            onPressed: toggleOnlyReview, //
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Question ${currentQuestion + 1} of ${allQuestions.length}', style: const TextStyle(fontSize: 16)),
            // const SizedBox(height: 8),
            // const Divider(),
            const SizedBox(height: 10),
            Text(question.questionText ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),
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
            const SizedBox(height: 10),

            if (answered)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: toggleMarkForReview,
                    icon: Icon(question.markedForReview ? Icons.bookmark_added : Icons.bookmark_add_outlined),
                    label: Text(question.markedForReview ? 'Marked for Review' : 'Mark for Review'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
