import 'dart:io';

import 'package:driving_quiz_app/data/question_data.dart';
import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../models/question.dart';
import 'dart:math';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late List<Question> learningList;
  int currentIndex = 0;
  bool reveal = false;
  bool reviewOnly = false;
  bool shuffle = false;
  bool onlyCustom = false;
  // List<Question> getAllCombinedQuestions() => [...questions, ...getAllQuestions()];

  @override
  void initState() {
    super.initState();
    // learningList = [...questions, ...getAllQuestions()];
    updateLearningList();
  }

  void updateLearningList() {
    learningList =
        [...questions, ...getAllQuestions()].where((q) {
          if (reviewOnly && !q.markedForReview) return false;
          if (onlyCustom && !q.isCustom) return false;
          return true;
        }).toList();

    if (shuffle) learningList.shuffle(Random());

    setState(() {
      currentIndex = 0;
      reveal = false;
    });
  }

  void toggleShuffle() {
    setState(() {
      shuffle = !shuffle;
      updateLearningList();
      // final allQuestions = [...questions, ...getAllQuestions()];
      // learningList = shuffle ? (allQuestions..shuffle(Random())) : allQuestions;
      // currentIndex = 0;
      // reveal = false;
    });
  }

  void toggleReviewOnly() {
    setState(() {
      reviewOnly = !reviewOnly;
      updateLearningList();
      // final allQuestions = [...questions, ...getAllQuestions()];
      // if (reviewOnly) {
      //   learningList = allQuestions.where((q) => q.markedForReview).toList();
      // } else {
      //   learningList = shuffle ? (allQuestions..shuffle(Random())) : allQuestions;
      // }
      // currentIndex = 0;
      // reveal = false;
    });
  }

  void toggleOnlyCustom() {
    setState(() {
      onlyCustom = !onlyCustom;
      updateLearningList();
    });
  }

  void toggleMarkReview() {
    setState(() {
      learningList[currentIndex].markedForReview = !learningList[currentIndex].markedForReview;
    });
  }

  void showAnswer() => setState(() => reveal = true);

  void next() {
    if (currentIndex < learningList.length - 1) {
      setState(() {
        currentIndex++;
        reveal = false;
      });
    }
  }

  void back() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        reveal = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (learningList.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Learning Mode')), body: const Center(child: Text('No questions available in this mode.')));
    }

    final question = learningList[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Mode'),
        actions: [
          IconButton(icon: Icon(onlyCustom ? Icons.star : Icons.star_border), tooltip: 'Toggle Custom Only', onPressed: toggleOnlyCustom),
          IconButton(icon: Icon(shuffle ? Icons.shuffle_on : Icons.shuffle), tooltip: 'Toggle Shuffle', onPressed: toggleShuffle),
          IconButton(icon: Icon(reviewOnly ? Icons.bookmark : Icons.bookmark_border), tooltip: 'Toggle Review Mode', onPressed: toggleReviewOnly),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Question ${currentIndex + 1} of ${learningList.length}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(question.questionText ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Image.asset(question.imagePath ?? '', height: 200),
              if (question.imagePath != null)
                // Image.asset(question.imagePath!, height: 200)
                question.imagePath != null && question.imagePath!.startsWith('assets/')
                    ? Image.asset(question.imagePath!, height: 200)
                    : Image.file(File(question.imagePath!), height: 200)
              else
                const SizedBox(height: 10),

              const SizedBox(height: 20),
              if (reveal) Text('Answer: ${question.options[question.correctIndex]}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (!reveal) ElevatedButton(onPressed: showAnswer, child: const Text('Reveal Answer')),
              if (reveal) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ElevatedButton(onPressed: back, child: const Text('Back')), const SizedBox(width: 10), ElevatedButton(onPressed: next, child: const Text('Next'))],
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: toggleMarkReview,
                  icon: Icon(question.markedForReview ? Icons.bookmark_added : Icons.bookmark_add_outlined),
                  label: Text(question.markedForReview ? 'Marked for Review' : 'Mark for Review'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
