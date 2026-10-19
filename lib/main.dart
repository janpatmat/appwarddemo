import 'package:flutter/material.dart';

import 'calculator_screen.dart';
import 'theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = await ThemeController.load();
  runApp(CalculatorApp(themeController: themeController));
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: 'Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        darkTheme: ThemeData(
          colorScheme: .fromSeed(
            seedColor: Colors.deepPurple,
            brightness: .dark,
          ),
        ),
        themeMode: themeController.themeMode,
        home: CalculatorScreen(themeController: themeController),
      ),
    );
  }
}
