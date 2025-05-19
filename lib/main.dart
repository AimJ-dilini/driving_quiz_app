import 'package:driving_quiz_app/models/question.dart';
import 'package:driving_quiz_app/screens/add_question_screen.dart';
import 'package:driving_quiz_app/screens/manage_questions_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/quiz_screen.dart';
import 'screens/learning_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  Hive.registerAdapter(QuestionAdapter());
  await Hive.openBox<Question>('questionsBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driving Quiz App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
          primary: Colors.blue.shade600,
          secondary: Colors.amber.shade600,
          tertiary: Colors.teal.shade500,
        ),
        textTheme: const TextTheme(headlineMedium: TextStyle(fontWeight: FontWeight.bold), titleLarge: TextStyle(fontWeight: FontWeight.w600)),
        buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme),

              // Stats Overview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: FadeTransition(opacity: _fadeAnimation, child: SlideTransition(position: _slideAnimation, child: _buildStatsCard(colorScheme))),
              ),

              // Mode Selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Choose Mode', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8))),
              ),

              // Main Feature Cards
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFeatureCard(
                          context,
                          title: 'Quiz Mode',
                          description: 'Test your knowledge with timed questions',
                          icon: Icons.timer,
                          color: colorScheme.primary,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
                          },
                        ),
                        _buildFeatureCard(
                          context,
                          title: 'Learning Mode',
                          description: 'Study at your own pace with detailed explanations',
                          icon: Icons.menu_book,
                          color: colorScheme.tertiary,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Admin Section Title
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 8),
                child: Text('Customize', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8))),
              ),

              // Admin Actions
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildAdminCard(
                          context,
                          title: 'Add Question',
                          icon: Icons.add_circle_outline,
                          color: colorScheme.secondary,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddQuestionScreen()));
                          },
                        ),
                        _buildAdminCard(
                          context,
                          title: 'Manage Questions',
                          icon: Icons.list_alt,
                          color: Colors.deepPurple,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageQuestionsScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tips Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(position: _slideAnimation, child: Padding(padding: const EdgeInsets.all(16.0), child: _buildTipCard(colorScheme))),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)]),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text('Driving Test', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                ),
              ),
              CircleAvatar(
                backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
                child: IconButton(
                  icon: Icon(Icons.settings_outlined, color: colorScheme.onPrimary),
                  onPressed: () {
                    // Show settings or help dialog
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('About'),
                            content: const Text('Driving Test App helps you prepare for your driving license exam with practice questions and learning materials.'),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Opacity(opacity: 0.8, child: Text('Master your driving knowledge', style: TextStyle(color: colorScheme.onPrimary, fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          _buildStatItem(colorScheme, title: 'Your Progress', value: ValueNotifier(0.75), label: '75%', color: colorScheme.primary),
          const SizedBox(width: 20),
          _buildStatItem(colorScheme, title: 'Questions', value: null, label: '120+', color: colorScheme.tertiary, icon: Icons.help_outline),
          const SizedBox(width: 20),
          _buildStatItem(
            colorScheme,
            title: 'Custom',
            value: null,
            label: 'Questions',
            color: colorScheme.secondary,
            icon: Icons.extension,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageQuestionsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ColorScheme colorScheme, {
    required String title,
    required String label,
    required Color color,
    ValueNotifier<double>? value,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(title, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 12)),
            const SizedBox(height: 8),
            value != null
                ? SizedBox(
                  height: 50,
                  width: 50,
                  child: ValueListenableBuilder<double>(
                    valueListenable: value,
                    builder: (context, progress, _) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(value: progress, strokeWidth: 6, backgroundColor: color.withOpacity(0.2), valueColor: AlwaysStoppedAnimation<Color>(color)),
                          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 12)),
                        ],
                      );
                    },
                  ),
                )
                : Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                  child: Center(child: icon != null ? Icon(icon, color: color, size: 24) : Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color))),
                ),
            if (icon != null)
              Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required String title, required String description, required IconData icon, required Color color, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(height: 8),
                  Text(title, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.lightbulb_outline, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tip of the Day', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  'Practice regularly with random questions to better prepare for the real test.',
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
