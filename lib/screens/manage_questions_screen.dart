import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:driving_quiz_app/screens/edit_question_screen.dart';
import '../models/question.dart';
import 'add_question_screen.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  late Box<Question> questionBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    questionBox = Hive.box<Question>('questionsBox');
    // Simulate loading for smooth transitions
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void deleteQuestion(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Question'),
            content: const Text('Are you sure you want to delete this question? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  questionBox.deleteAt(index);
                  Navigator.pop(context);
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Question deleted'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      action: SnackBarAction(label: 'Dismiss', textColor: Colors.white, onPressed: () {}),
                    ),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void editQuestion(int index) {
    final question = questionBox.getAt(index);
    if (question != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => EditQuestionScreen(question: question, index: index))).then((_) => setState(() {}));
    }
  }

  void addNewQuestion() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddQuestionScreen())).then((_) => setState(() {}));
  }

  String _getTruncatedOptions(List<String> options) {
    const maxLength = 20;
    final result = options.join(', ');
    if (result.length <= maxLength) return result;
    return '${result.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final customQuestions = questionBox.values.where((q) => q.isCustom).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Manage Questions'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Help'),
                      content: const Text('Here you can view, edit, and delete your custom questions. Tap on a question to see more details.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : customQuestions.isEmpty
              ? _buildEmptyState(colorScheme)
              : _buildQuestionsList(customQuestions, colorScheme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNewQuestion,
        icon: const Icon(Icons.add),
        label: const Text('New Question'),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: colorScheme.primaryContainer.withOpacity(0.3), shape: BoxShape.circle),
            child: Icon(Icons.quiz_outlined, size: 64, color: colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text('No Custom Questions Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Text('Tap the button below to create your first question', style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.7)), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: addNewQuestion,
            icon: const Icon(Icons.add),
            label: const Text('Create Question'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(List<Question> questions, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        return Future.delayed(const Duration(milliseconds: 500));
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: QuestionCard(question: question, index: index, onEdit: () => editQuestion(index), onDelete: () => deleteQuestion(index)),
            );
          },
        ),
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final Question question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const QuestionCard({super.key, required this.question, required this.index, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = question.imagePath != null;
    final correctAnswer = question.options[question.correctIndex];
    final questionText = question.questionText ?? 'Visual Question';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => _buildDetailSheet(context));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage) _buildImagePreview(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                        child: Text('Q${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(questionText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Correct: $correctAnswer',
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ActionButton(
                        icon: Icons.visibility,
                        label: 'View',
                        color: colorScheme.tertiary,
                        onTap: () {
                          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => _buildDetailSheet(context));
                        },
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(icon: Icons.edit, label: 'Edit', color: colorScheme.secondary, onTap: onEdit),
                      const SizedBox(width: 8),
                      _ActionButton(icon: Icons.delete, label: 'Delete', color: colorScheme.error, onTap: onDelete),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final image = question.imagePath!.startsWith('assets/') ? AssetImage(question.imagePath!) as ImageProvider : FileImage(File(question.imagePath!));

    return SizedBox(width: double.infinity, height: 140, child: Image(image: image, fit: BoxFit.cover));
  }

  Widget _buildDetailSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = question.imagePath != null;
    final questionText = question.questionText ?? 'Visual Question';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.onSurface.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text('Question Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface), textAlign: TextAlign.center),
                    const SizedBox(height: 24),

                    // Question text/image
                    _DetailSection(
                      title: 'Question',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(questionText, style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
                          if (hasImage) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(
                                image: question.imagePath!.startsWith('assets/') ? AssetImage(question.imagePath!) as ImageProvider : FileImage(File(question.imagePath!)),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Options
                    _DetailSection(
                      title: 'Options',
                      child: Column(
                        children: List.generate(
                          question.options.length,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _OptionItem(option: question.options[i], letter: String.fromCharCode(65 + i), isCorrect: i == question.correctIndex, colorScheme: colorScheme),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onEdit();
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.onError,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.secondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.outlineVariant)),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String option;
  final String letter;
  final bool isCorrect;
  final ColorScheme colorScheme;

  const _OptionItem({required this.option, required this.letter, required this.isCorrect, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect ? colorScheme.primaryContainer.withOpacity(0.4) : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isCorrect ? colorScheme.primary : colorScheme.outlineVariant, width: isCorrect ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: isCorrect ? colorScheme.primary : colorScheme.surfaceVariant, shape: BoxShape.circle),
            child: Center(child: Text(letter, style: TextStyle(fontWeight: FontWeight.bold, color: isCorrect ? colorScheme.onPrimary : colorScheme.onSurfaceVariant))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(option, style: TextStyle(color: colorScheme.onSurface, fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal))),
          if (isCorrect) Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon, color: color, size: 20), const SizedBox(height: 4), Text(label, style: TextStyle(color: color, fontSize: 12))],
          ),
        ),
      ),
    );
  }
}
