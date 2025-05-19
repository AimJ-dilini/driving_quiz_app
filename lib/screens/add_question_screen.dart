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
      final options = _optionControllers.map((c) => c.text).toList();
      final question = Question(
        questionText: _questionTextController.text.isEmpty ? null : _questionTextController.text,
        imagePath: imageFile?.path,
        options: options,
        correctIndex: correctIndex,
        isCustom: true,
      );

      final box = Hive.box<Question>('questionsBox');
      await box.add(question);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question added successfully!')));

      Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Custom Question')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Optional: Enter question text'),
              TextFormField(controller: _questionTextController, decoration: const InputDecoration(labelText: 'Question Text')),
              const SizedBox(height: 10),
              if (imageFile != null) Image.file(imageFile!, height: 150),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(onPressed: () => pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text('Camera')),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(onPressed: () => pickImage(ImageSource.gallery), icon: const Icon(Icons.photo), label: const Text('Gallery')),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Enter 4 options'),
              for (int i = 0; i < 4; i++)
                TextFormField(
                  controller: _optionControllers[i],
                  decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: correctIndex,
                decoration: const InputDecoration(labelText: 'Correct Option'),
                items: List.generate(4, (i) => DropdownMenuItem(value: i, child: Text('Option ${i + 1}'))),
                onChanged: (val) {
                  setState(() {
                    correctIndex = val!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: saveQuestion, child: const Text('Save Question')),
            ],
          ),
        ),
      ),
    );
  }
}
