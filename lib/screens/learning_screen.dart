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

  @override
  void initState() {
    super.initState();
    learningList = List<Question>.from(questions);
  }

  void toggleShuffle() {
    setState(() {
      shuffle = !shuffle;
      if (shuffle) {
        learningList.shuffle(Random());
      } else {
        learningList = List<Question>.from(questions);
      }
      currentIndex = 0;
      reveal = false;
    });
  }

  void toggleReviewOnly() {
    setState(() {
      reviewOnly = !reviewOnly;
      if (reviewOnly) {
        learningList = questions.where((q) => q.markedForReview).toList();
      } else {
        learningList = List<Question>.from(questions);
        if (shuffle) learningList.shuffle(Random());
      }
      currentIndex = 0;
      reveal = false;
    });
  }

  void toggleMarkReview() {
    setState(() {
      learningList[currentIndex].markedForReview =
          !learningList[currentIndex].markedForReview;
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
      return Scaffold(
        appBar: AppBar(title: const Text('Learning Mode')),
        body: const Center(
          child: Text('No questions available in this mode.'),
        ),
      );
    }

    final question = learningList[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Mode'),
        actions: [
          IconButton(
            icon: Icon(shuffle ? Icons.shuffle_on : Icons.shuffle),
            tooltip: 'Toggle Shuffle',
            onPressed: toggleShuffle,
          ),
          IconButton(
            icon: Icon(reviewOnly ? Icons.bookmark : Icons.bookmark_border),
            tooltip: 'Toggle Review Mode',
            onPressed: toggleReviewOnly,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Question ${currentIndex + 1} of ${learningList.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
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
            if (reveal) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: back,
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: next,
                    child: const Text('Next'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: toggleMarkReview,
                icon: Icon(question.markedForReview
                    ? Icons.bookmark_added
                    : Icons.bookmark_add_outlined),
                label: Text(question.markedForReview
                    ? 'Marked for Review'
                    : 'Mark for Review'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
