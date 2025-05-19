import 'dart:io';
import 'dart:math';

import 'package:driving_quiz_app/data/question_data.dart';
import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../models/question.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> with SingleTickerProviderStateMixin {
  late List<Question> learningList;
  int currentIndex = 0;
  bool reveal = false;
  bool reviewOnly = false;
  bool shuffle = false;
  bool onlyCustom = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Page controller for swipe navigation
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    updateLearningList();

    // Initialize page controller
    _pageController = PageController(initialPage: currentIndex);

    // Setup animations
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
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
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(shuffle ? 'Questions shuffled' : 'Questions in original order', style: const TextStyle(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void toggleReviewOnly() {
    setState(() {
      reviewOnly = !reviewOnly;
      updateLearningList();
    });

    if (learningList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No questions marked for review', style: TextStyle(fontWeight: FontWeight.w500)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void toggleOnlyCustom() {
    setState(() {
      onlyCustom = !onlyCustom;
      updateLearningList();
    });

    if (learningList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No custom questions available', style: TextStyle(fontWeight: FontWeight.w500)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void toggleMarkReview() {
    setState(() {
      learningList[currentIndex].markedForReview = !learningList[currentIndex].markedForReview;
    });

    // Show feedback
    final marked = learningList[currentIndex].markedForReview;
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

  void showAnswer() {
    setState(() => reveal = true);
    _animationController.reset();
    _animationController.forward();
  }

  void next() {
    if (currentIndex < learningList.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        currentIndex++;
        reveal = false;
      });
    } else {
      // Feedback for last question
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You reached the last question', style: TextStyle(fontWeight: FontWeight.w500)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void back() {
    if (currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        currentIndex--;
        reveal = false;
      });
    } else {
      // Feedback for first question
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You are at the first question', style: TextStyle(fontWeight: FontWeight.w500)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (learningList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learning Mode'), elevation: 0, backgroundColor: Theme.of(context).scaffoldBackgroundColor, foregroundColor: colorScheme.primary),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text("No questions available", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Try changing your filters or adding new questions", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    reviewOnly = false;
                    onlyCustom = false;
                  });
                  updateLearningList();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Reset Filters"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = learningList[currentIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        title: Column(
          children: [
            const Text('Learning Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${currentIndex + 1} of ${learningList.length}', style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white70 : Colors.black54)),
          ],
        ),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(icon: Icon(onlyCustom ? Icons.star : Icons.star_border, color: onlyCustom ? Colors.amber : null), tooltip: 'Custom Questions', onPressed: toggleOnlyCustom),
          IconButton(
            icon: Icon(shuffle ? Icons.shuffle_on_outlined : Icons.shuffle, color: shuffle ? Colors.purple : null),
            tooltip: 'Shuffle Questions',
            onPressed: toggleShuffle,
          ),
          IconButton(
            icon: Icon(reviewOnly ? Icons.bookmark : Icons.bookmark_border, color: reviewOnly ? Colors.red : null),
            tooltip: 'Review Questions',
            onPressed: toggleReviewOnly,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.secondary.withOpacity(0.1), Theme.of(context).scaffoldBackgroundColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (currentIndex + 1) / learningList.length,
                      backgroundColor: Colors.grey.shade200,
                      color: colorScheme.secondary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Question card with swipe navigation
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable swipe to prevent user navigation
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                      reveal = false;
                    });
                  },
                  itemCount: learningList.length,
                  itemBuilder: (context, index) {
                    final currentQuestion = learningList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: currentQuestion.markedForReview ? Colors.red.withOpacity(0.5) : Colors.transparent,
                            width: currentQuestion.markedForReview ? 2 : 0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Question header
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                                          child: Text('Question', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer, fontSize: 12)),
                                        ),
                                        if (currentQuestion.markedForReview)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.bookmark, color: Colors.red, size: 12),
                                                const SizedBox(width: 4),
                                                const Text('Review', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(currentQuestion.questionText ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)),
                                  ],
                                ),
                              ),

                              // Question image if available
                              if (currentQuestion.imagePath != null)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 1)]),
                                        child:
                                            currentQuestion.imagePath!.startsWith('assets/')
                                                ? Image.asset(currentQuestion.imagePath!, fit: BoxFit.contain)
                                                : Image.file(File(currentQuestion.imagePath!), fit: BoxFit.contain),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const Expanded(child: SizedBox()),

                              // Answer reveal
                              if (reveal)
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                              const SizedBox(width: 8),
                                              Text('Correct Answer', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(currentQuestion.options[currentQuestion.correctIndex], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom action area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -4))],
                ),
                child: Row(
                  children: [
                    // Mark review button
                    IconButton(
                      onPressed: toggleMarkReview,
                      icon: Icon(question.markedForReview ? Icons.bookmark : Icons.bookmark_border, color: question.markedForReview ? Colors.red : null),
                      tooltip: question.markedForReview ? 'Remove from review' : 'Mark for review',
                    ),

                    const Spacer(),

                    // Navigation/reveal action buttons
                    if (!reveal)
                      ElevatedButton(
                        onPressed: showAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: const Text('Reveal Answer'),
                      )
                    else
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: back,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: next,
                            icon: const Text('Next'),
                            label: const Icon(Icons.arrow_forward),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
