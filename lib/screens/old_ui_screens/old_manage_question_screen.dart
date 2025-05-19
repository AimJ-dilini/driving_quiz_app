import 'dart:io';
import 'package:driving_quiz_app/models/question.dart';
import 'package:driving_quiz_app/screens/edit_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; 

class OldManageQuestionsScreen extends StatefulWidget {
  const OldManageQuestionsScreen({super.key});

  @override
  State<OldManageQuestionsScreen> createState() => _OldManageQuestionsScreenState();
}

class _OldManageQuestionsScreenState extends State<OldManageQuestionsScreen> {
  late Box<Question> questionBox;

  @override
  void initState() {
    super.initState();
    questionBox = Hive.box<Question>('questionsBox');
  }

  void deleteQuestion(int index) {
    questionBox.deleteAt(index);
    setState(() {});
  }

  void editQuestion(int index) {
    final question = questionBox.getAt(index);
    if (question != null) {
      // Navigator.push(context, MaterialPageRoute(builder: (_) => AddQuestionScreen(editingQuestion: question, indexToEdit: index))).then((_) => setState(() {}));
      Navigator.push(context, MaterialPageRoute(builder: (_) => EditQuestionScreen(question: question, index: index))).then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customQuestions = questionBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Questions')),
      body: ListView.builder(
        itemCount: customQuestions.length,
        itemBuilder: (context, index) {
          final question = customQuestions[index];
          return ListTile(
            leading:
                question.imagePath != null
                    ? Image(
                      image: question.imagePath!.startsWith('assets/') ? AssetImage(question.imagePath!) : FileImage(File(question.imagePath!)) as ImageProvider,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                    : const Icon(Icons.image_not_supported),
            title: Text(question.options[question.correctIndex], overflow: TextOverflow.ellipsis),
            subtitle: Text('Options: ${question.options.join(', ')}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => editQuestion(index)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteQuestion(index)),
              ],
            ),
          );
        },
      ),
    );
  }
}
