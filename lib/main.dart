import 'package:flutter/material.dart';

import 'calculation_history.dart';
import 'calculator_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final history = await CalculationHistory.load();
  runApp(CalculatorApp(history: history));
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key, required this.history});

  final CalculationHistory history;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      darkTheme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple, brightness: .dark),
      ),
      home: CalculatorScreen(history: history),
    );
  }
}
