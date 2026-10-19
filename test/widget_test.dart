import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculator/calculator_screen.dart';
import 'package:calculator/main.dart';

void main() {
  testWidgets('adds two numbers by tapping the keypad', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    for (final key in ['1', '2', '+', '3', '=']) {
      await tester.tap(find.widgetWithText(FilledButton, key));
      await tester.pump();
    }

    expect(find.text('15'), findsOneWidget);
    expect(find.text('12 + 3 ='), findsOneWidget);
  });

  testWidgets('backspace button removes the last digit', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.widgetWithText(FilledButton, '4'));
    await tester.tap(find.widgetWithText(FilledButton, '2'));
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();

    expect(find.text('4'), findsNWidgets(2));
  });

  testWidgets('random button puts a number in the display to calculate with', (
    tester,
  ) async {
    final expected = 1 + Random(1).nextInt(100);
    await tester.pumpWidget(
      MaterialApp(home: CalculatorScreen(random: Random(1))),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Random'));
    await tester.pump();
    expect(find.text('$expected'), findsWidgets);

    for (final key in ['+', '5', '=']) {
      await tester.tap(find.widgetWithText(FilledButton, key));
      await tester.pump();
    }
    expect(find.text('${expected + 5}'), findsOneWidget);
    expect(find.text('$expected + 5 ='), findsOneWidget);
  });
}
