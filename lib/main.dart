import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/constants/theme.dart';
import 'package:skillsbridge/views/bursary/bursary_screen.dart';
import 'package:skillsbridge/views/learning/learning_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillsBridge',
      theme: AppTheme.lightTheme,
      home: LearningHubScreen(),
    );
  }
}
