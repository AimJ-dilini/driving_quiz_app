import 'dart:io';

import 'package:driving_quiz_app/models/question.dart';
import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../data/question_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int currentQuestion = 0;
  bool answered = false;
  int selectedIndex = -1;
  late List<Question> allQuestions;
  bool onlyCustom = false;
  bool onlyReview = false;
  int correctAnswers = 0;
  int totalAnswered = 0;
  bool quizCompleted = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    updateQuestionList();

    // Setup animations
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(begin: const Offset(0.2, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void updateQuestionList() {
    final all = [...questions, ...getAllQuestions()];

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

    _animationController.reset();

    setState(() {
      currentQuestion = (currentQuestion + 1) % allQuestions.length;
      answered = false;
      selectedIndex = -1;
    });

    _animationController.forward();
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

    // Show feedback with snackbar
    final marked = allQuestions[currentQuestion].markedForReview;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(marked ? 'Question marked for review' : 'Removed from review list', style: const TextStyle(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: marked ? Colors.indigo : Colors.blueGrey,
      ),
    );
  }

  // Function to show a summary dialog at the end of the quiz
  void showSummaryDialog() {
    final score = correctAnswers / allQuestions.length;
    final Color scoreColor =
        score > 0.8
            ? Colors.green
            : score > 0.5
            ? Colors.orange
            : Colors.red;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(children: [const Icon(Icons.emoji_events, color: Colors.amber, size: 30), const SizedBox(width: 10), const Text('Quiz Completed')]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(height: 120, width: 120, child: CircularProgressIndicator(value: score, strokeWidth: 10, backgroundColor: Colors.grey.shade200, color: scoreColor)),
                    Column(
                      children: [
                        Text('${(score * 100).toInt()}%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: scoreColor)),
                        Text('$correctAnswers/${allQuestions.length}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  score > 0.8
                      ? 'Excellent! Great job!'
                      : score > 0.5
                      ? 'Good effort! Keep practicing.'
                      : 'Keep practicing, you\'ll improve!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
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
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Exit Quiz'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (allQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Driving Test Quiz'),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.question_mark_rounded, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text("No questions available", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Try changing your filters or adding new questions", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final question = allQuestions[currentQuestion];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        title: Text('Question ${currentQuestion + 1}/${allQuestions.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            icon: Icon(onlyCustom ? Icons.star : Icons.star_border, color: onlyCustom ? Colors.amber : null),
            tooltip: 'Toggle Custom Questions',
            onPressed: toggleOnlyCustom,
          ),
          IconButton(
            icon: Icon(onlyReview ? Icons.bookmark : Icons.bookmark_border, color: onlyReview ? Colors.red : null),
            tooltip: 'Toggle Review Questions',
            onPressed: toggleOnlyReview,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.primary.withOpacity(0.1), Theme.of(context).scaffoldBackgroundColor],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Progress indicator
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: LinearProgressIndicator(
                        value: (currentQuestion + 1) / allQuestions.length,
                        backgroundColor: Colors.grey.shade200,
                        color: Theme.of(context).colorScheme.primary,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Question card
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 2))],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Question text
                              Text(question.questionText ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4), textAlign: TextAlign.center),

                              // Question image if available
                              if (question.imagePath != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 1)]),
                                      child:
                                          question.imagePath!.startsWith('assets/')
                                              ? Image.asset(question.imagePath!, height: 220, fit: BoxFit.cover)
                                              : Image.file(File(question.imagePath!), height: 220, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // Options list
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: question.options.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final isCorrect = index == question.correctIndex;
                                  final isSelected = index == selectedIndex;

                                  Color getOptionColor() {
                                    if (!answered) return Colors.transparent;
                                    if (isSelected && isCorrect) return Colors.green.shade50;
                                    if (isSelected && !isCorrect) return Colors.red.shade50;
                                    if (isCorrect) return Colors.green.shade50;
                                    return Colors.transparent;
                                  }

                                  Color getBorderColor() {
                                    if (!answered) {
                                      return isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300;
                                    }
                                    if (isSelected && isCorrect) return Colors.green;
                                    if (isSelected && !isCorrect) return Colors.red;
                                    if (isCorrect) return Colors.green;
                                    return Colors.grey.shade300;
                                  }

                                  IconData? getIcon() {
                                    if (!answered) return null;
                                    if (isSelected && isCorrect) return Icons.check_circle;
                                    if (isSelected && !isCorrect) return Icons.cancel;
                                    if (isCorrect) return Icons.check_circle_outline;
                                    return null;
                                  }

                                  Color getIconColor() {
                                    if (isSelected && isCorrect) return Colors.green;
                                    if (isSelected && !isCorrect) return Colors.red;
                                    if (isCorrect) return Colors.green;
                                    return Colors.grey;
                                  }

                                  return InkWell(
                                    onTap: () => checkAnswer(index),
                                    borderRadius: BorderRadius.circular(16),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness == Brightness.dark ? getOptionColor().withOpacity(0.2) : getOptionColor(),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: getBorderColor(), width: isSelected ? 2 : 1),
                                      ),
                                      child: Row(
                                        children: [
                                          // Option letter
                                          Container(
                                            width: 36,
                                            height: 36,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected ? getBorderColor().withOpacity(0.1) : Colors.grey.shade100,
                                              border: Border.all(color: isSelected ? getBorderColor() : Colors.grey.shade300, width: 1),
                                            ),
                                            child: Text(
                                              String.fromCharCode(65 + index), // A, B, C, D
                                              style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? getBorderColor() : Colors.grey.shade700),
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Option text
                                          Expanded(
                                            child: Text(
                                              question.options[index],
                                              style: TextStyle(fontSize: 16, fontWeight: isSelected || (answered && isCorrect) ? FontWeight.w600 : FontWeight.normal),
                                            ),
                                          ),

                                          // Result icon
                                          if (getIcon() != null) Icon(getIcon(), color: getIconColor(), size: 24),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom actions
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Row(
                        children: [
                          // Review button
                          IconButton(
                            onPressed: toggleMarkForReview,
                            icon: Icon(question.markedForReview ? Icons.bookmark : Icons.bookmark_outline, color: question.markedForReview ? Colors.red : null),
                            tooltip: question.markedForReview ? 'Remove from review' : 'Mark for review',
                          ),

                          const Spacer(),

                          // Next button
                          if (answered)
                            ElevatedButton.icon(
                              onPressed: nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                              icon: const Text('Next Question'),
                              label: const Icon(Icons.arrow_forward),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
