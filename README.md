
# 🚗 Driving Test Quiz App

A Flutter-based mobile application to help users practice for their driving license test. It includes two modes — **Quiz Mode** and **Learning Mode** — and supports both system-defined and custom user-generated questions. The app also supports marking questions for review and saving data locally using Hive.

---

## ✨ Features

- 📖 **Learning Mode** — View questions and reveal correct answers at your pace.
- ❓ **Quiz Mode** — Take quizzes with multiple-choice questions.
- 📸 **Image Support** — Each question can optionally include a road sign image.
- 🏷️ **Mark for Review** — Mark tricky questions to revisit later.
- ⭐ **Custom Questions** — Add your own questions with text and images.
- 🔍 **Filter Options** — Toggle custom-only, review-only, and shuffle questions.
- 💾 **Local Storage** — Persistent data storage using Hive.

---
<!--
## 📱 Screenshots

> *(Add screenshots)*

---
-->
## 🛠️ Getting Started

### Prerequisites

- Flutter SDK (3.x recommended)
- Dart SDK
- Android Studio or VS Code (recommended)

### Run Locally

```bash
git clone https://github.com/AimJ-dilini/driving_quiz_app.git
cd driving-quiz-app
flutter pub get
flutter run
````

### Hive Setup

Make sure to initialize Hive in your `main.dart` and register the `Question` adapter:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(QuestionAdapter());
  await Hive.openBox<Question>('customQuestions');
  runApp(const MyApp());
}
```

---

## 📁 Project Structure

```
lib/
├── data/
│   ├── questions.dart       // Default questions
│   └── question_data.dart   // Hive logic
├── models/
│   └── question.dart        // Question model
├── screens/
│   ├── quiz_screen.dart     // Quiz mode
│   ├── learning_screen.dart // Learning mode
│   └── add_question_screen.dart // Add your own question
│   └── manage_questions_screen.dart // View, Edit, Delete custom questions

├── widgets/
│   └── option_button.dart   // Answer buttons
└── main.dart
```

---
<!--
## 🚀 Upcoming Features (Ideas)
 
* Category/tag-based filtering (e.g., road signs, rules)
* Firebase sync (cloud backup of custom questions)
* Dark mode
* Leaderboard & timed challenges

---
 -->

## 🙌 Acknowledgments

Made with Flutter ❤️ to help future drivers ace their driving test!


---

[AimJ-dilini](https://github.com/AimJ-dilini)

✨
