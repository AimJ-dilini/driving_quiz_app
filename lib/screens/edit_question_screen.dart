import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/question.dart';

class EditQuestionScreen extends StatefulWidget {
  final Question question;
  final int index;

  const EditQuestionScreen({super.key, required this.question, required this.index});

  @override
  State createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  late TextEditingController questionText;
  late TextEditingController option1;
  late TextEditingController option2;
  late TextEditingController option3;
  late TextEditingController option4;
  late int correctIndex;
  String? imagePath;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    questionText = TextEditingController(text: widget.question.questionText);
    option1 = TextEditingController(text: widget.question.options[0]);
    option2 = TextEditingController(text: widget.question.options[1]);
    option3 = TextEditingController(text: widget.question.options[2]);
    option4 = TextEditingController(text: widget.question.options[3]);
    correctIndex = widget.question.correctIndex;
    imagePath = widget.question.imagePath;
  }

  @override
  void dispose() {
    questionText.dispose();
    option1.dispose();
    option2.dispose();
    option3.dispose();
    option4.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please check your inputs')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedQuestion = Question(
        questionText: questionText.text.trim(),
        imagePath: imagePath,
        options: [option1.text.trim(), option2.text.trim(), option3.text.trim(), option4.text.trim()],
        correctIndex: correctIndex,
        isCustom: true,
      );

      final box = Hive.box<Question>('questionsBox');
      box.putAt(widget.index, updatedQuestion);

      Navigator.pop(context);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question updated successfully!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating question: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('Edit Question', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.primary), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Question Details',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: colorScheme.primary),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Edit your question and answers below',
                  style: GoogleFonts.poppins(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.7)),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 32),

                // Question text field
                _buildInputField(controller: questionText, label: 'Question', hint: 'Enter your question here', maxLines: 3, isRequired: true).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

                // Image section
                _buildImageSection().animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 32),

                // Options section title
                Text('Answer Options', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.primary)).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 16),

                // Options
                _buildOptionField(controller: option1, label: 'Option 1', index: 0).animate().fadeIn(delay: 500.ms),

                _buildOptionField(controller: option2, label: 'Option 2', index: 1).animate().fadeIn(delay: 600.ms),

                _buildOptionField(controller: option3, label: 'Option 3', index: 2).animate().fadeIn(delay: 700.ms),

                _buildOptionField(controller: option4, label: 'Option 4', index: 3).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 40),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading ? const CircularProgressIndicator() : Text('Save Changes', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required String hint, int maxLines = 1, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question Image', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3), width: 1),
            ),
            child:
                imagePath != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imagePath!.startsWith('assets/') ? Image.asset(imagePath!, fit: BoxFit.cover) : Image.file(File(imagePath!), fit: BoxFit.cover),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 12),
                        Text('Tap to add an image', style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionField({required TextEditingController controller, required String label, required int index}) {
    final isCorrect = correctIndex == index;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCorrect ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.2), width: isCorrect ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: isCorrect ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
              const Spacer(),
              Row(
                children: [
                  Text('Correct answer', style: GoogleFonts.poppins(fontSize: 14, color: isCorrect ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(width: 8),
                  Switch(
                    value: isCorrect,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (value) {
                      if (value) {
                        setState(() => correctIndex = index);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter answer option',
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
              filled: true,
              fillColor: isCorrect ? theme.colorScheme.primary.withOpacity(0.05) : theme.colorScheme.surfaceVariant.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Option cannot be empty';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
