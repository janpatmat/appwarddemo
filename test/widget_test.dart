import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calculator/calculator_screen.dart';
import 'package:calculator/fahh_sound.dart';
import 'package:calculator/main.dart';
import 'package:calculator/theme_controller.dart';

Future<void> pumpApp(WidgetTester tester) async {
  final themeController = await ThemeController.load();
  await tester.pumpWidget(CalculatorApp(themeController: themeController));
}

Brightness currentBrightness(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold))).brightness;

class _FakeFahhSound implements FahhSound {
  int plays = 0;

  @override
  Future<void> play() async => plays++;

  @override
  Future<void> dispose() async {}
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('adds two numbers by tapping the keypad', (tester) async {
    await pumpApp(tester);

    for (final key in ['1', '2', '+', '3', '=']) {
      await tester.tap(find.widgetWithText(FilledButton, key));
      await tester.pump();
    }

    expect(find.text('15'), findsOneWidget);
    expect(find.text('12 + 3 ='), findsOneWidget);
  });

  testWidgets('backspace button removes the last digit', (tester) async {
    await pumpApp(tester);

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
  group('theme toggle', () {
    tearDown(() {
      final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
      dispatcher.clearPlatformBrightnessTestValue();
    });

    testWidgets('follows the system theme on first launch', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await pumpApp(tester);

      expect(currentBrightness(tester), Brightness.dark);
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    });

    testWidgets('switches between light and dark', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await pumpApp(tester);
      expect(currentBrightness(tester), Brightness.light);

      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pumpAndSettle();
      expect(currentBrightness(tester), Brightness.dark);

      await tester.tap(find.byIcon(Icons.light_mode_outlined));
      await tester.pumpAndSettle();
      expect(currentBrightness(tester), Brightness.light);
    });

    testWidgets('remembers the chosen theme across launches', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pumpAndSettle();

      // Simulate reopening the app with a fresh controller.
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(currentBrightness(tester), Brightness.dark);
    });
  });
}
