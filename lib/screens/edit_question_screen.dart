import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import '../models/question.dart';

class EditQuestionScreen extends StatefulWidget {
  final Question question;
  final int index;

  const EditQuestionScreen({super.key, required this.question, required this.index});

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  late TextEditingController questionText;
  late TextEditingController option1;
  late TextEditingController option2;
  late TextEditingController option3;
  late TextEditingController option4;
  late int correctIndex;
  String? imagePath;

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

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  void saveChanges() {
    final updatedQuestion = Question(
      questionText: questionText.text,
      imagePath: imagePath,
      options: [option1.text, option2.text, option3.text, option4.text],
      correctIndex: correctIndex,
      isCustom: true,
    );

    final box = Hive.box<Question>('questionsBox');
    box.putAt(widget.index, updatedQuestion);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Question')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(controller: questionText, decoration: const InputDecoration(labelText: 'Question Text')),
              const SizedBox(height: 10),
              if (imagePath != null)
                Image(
                  image:
                      imagePath!.startsWith('assets/')
                          ? AssetImage(imagePath!) //
                          : FileImage(File(imagePath!)) as ImageProvider,
                  height: 200,
                ),
              TextButton.icon(onPressed: pickImage, icon: const Icon(Icons.photo), label: const Text('Change Image')),
              TextField(controller: option1, decoration: const InputDecoration(labelText: 'Option 1')),
              TextField(controller: option2, decoration: const InputDecoration(labelText: 'Option 2')),
              TextField(controller: option3, decoration: const InputDecoration(labelText: 'Option 3')),
              TextField(controller: option4, decoration: const InputDecoration(labelText: 'Option 4')),
              const SizedBox(height: 10),
              DropdownButton<int>(
                value: correctIndex,
                onChanged: (value) => setState(() => correctIndex = value!),
                items: [for (int i = 0; i < 4; i++) DropdownMenuItem(value: i, child: Text('Correct Answer: Option ${i + 1}'))],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: saveChanges, icon: const Icon(Icons.save), label: const Text('Save Changes')),
            ],
          ),
        ),
      ),
    );
  }
}
