import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculator/calculator_screen.dart';
import 'package:calculator/fahh_sound.dart';
import 'package:calculator/main.dart';

class _FakeFahhSound implements FahhSound {
  int plays = 0;

  @override
  Future<void> play() async => plays++;

  @override
  Future<void> dispose() async {}
}

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

  testWidgets('FAHH button plays the sound on every tap', (tester) async {
    final sound = _FakeFahhSound();
    await tester.pumpWidget(
      MaterialApp(home: CalculatorScreen(fahhSound: sound)),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'FAHH'));
    expect(sound.plays, 1);

    await tester.tap(find.widgetWithText(FilledButton, 'FAHH'));
    expect(sound.plays, 2);
  });

  testWidgets('FAHH button leaves the calculation alone', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CalculatorScreen(fahhSound: _FakeFahhSound())),
    );

    for (final key in ['1', '2', '+', 'FAHH', '3', 'FAHH', '=']) {
      await tester.tap(find.widgetWithText(FilledButton, key));
      await tester.pump();
    }

    expect(find.text('15'), findsOneWidget);
    expect(find.text('12 + 3 ='), findsOneWidget);
  });
}
