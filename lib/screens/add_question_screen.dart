import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';

import '../models/question.dart';

class AddQuestionScreen extends StatefulWidget {
  final Question? editingQuestion;
  final int? indexToEdit;

  const AddQuestionScreen({super.key, this.editingQuestion, this.indexToEdit});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (_) => TextEditingController());

  int correctIndex = 0;
  File? imageFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize with editing data if available
    if (widget.editingQuestion != null) {
      _questionTextController.text = widget.editingQuestion!.questionText ?? '';
      for (int i = 0; i < widget.editingQuestion!.options.length && i < 4; i++) {
        _optionControllers[i].text = widget.editingQuestion!.options[i];
      }
      correctIndex = widget.editingQuestion!.correctIndex;
      if (widget.editingQuestion!.imagePath != null) {
        imageFile = File(widget.editingQuestion!.imagePath!);
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(picked.path);
    final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');

    setState(() {
      imageFile = savedImage;
    });
  }

  void saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final options = _optionControllers.map((c) => c.text).toList();
        final question = Question(
          questionText: _questionTextController.text.isEmpty ? null : _questionTextController.text,
          imagePath: imageFile?.path,
          options: options,
          correctIndex: correctIndex,
          isCustom: true,
        );

        final box = Hive.box<Question>('questionsBox');

        if (widget.indexToEdit != null) {
          await box.putAt(widget.indexToEdit!, question);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Question updated successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          await box.add(question);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Question added successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }

        Navigator.pop(context);
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.editingQuestion != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Question' : 'Create Question'), elevation: 0, centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colorScheme.surface, colorScheme.surface.withOpacity(0.8)]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Text Input
                  Text('Question Text', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface.withOpacity(0.8))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _questionTextController,
                    decoration: InputDecoration(
                      hintText: 'Enter your question here (optional)',
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.1))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                  const SizedBox(height: 24),

                  // Image Picker Section
                  Text('Question Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface.withOpacity(0.8))),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
                      ),
                      child:
                          imageFile != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Positioned.fill(child: Image.file(imageFile!, fit: BoxFit.cover)),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white),
                                          onPressed: () {
                                            setState(() {
                                              imageFile = null;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined, size: 48, color: colorScheme.onSurface.withOpacity(0.4)),
                                  const SizedBox(height: 8),
                                  Text('No image selected', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Options Section
                  Text('Answer Options', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface.withOpacity(0.8))),
                  const SizedBox(height: 16),

                  // Option Fields
                  for (int i = 0; i < 4; i++) _buildOptionField(i, colorScheme),

                  const SizedBox(height: 24),

                  // Correct Answer Dropdown
                  Text('Correct Answer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface.withOpacity(0.8))),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<int>(
                        value: correctIndex,
                        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                        borderRadius: BorderRadius.circular(12),
                        items: List.generate(
                          4,
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text('Option ${String.fromCharCode(65 + i)}', style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            correctIndex = val!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : saveQuestion,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        child:
                            _isSubmitting
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : Text(isEditing ? 'Update Question' : 'Save Question', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionField(int index, ColorScheme colorScheme) {
    final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: correctIndex == index ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1), shape: BoxShape.circle),
            child: Center(child: Text(optionLabel, style: TextStyle(fontWeight: FontWeight.bold, color: correctIndex == index ? colorScheme.onPrimary : colorScheme.onSurface))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(
                hintText: 'Enter option $optionLabel',
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.error, width: 1)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Option $optionLabel is required' : null,
              onTap: () {
                // Set this as correct answer on double tap
                if (_optionControllers[index].text.isNotEmpty) {
                  setState(() {
                    correctIndex = index;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
