import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calculator/calculation_history.dart';
import 'package:calculator/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpApp(WidgetTester tester) async {
    final history = await CalculationHistory.load();
    await tester.pumpWidget(CalculatorApp(history: history));
  }

  Future<void> tapKeys(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      await tester.tap(find.widgetWithText(FilledButton, key));
      await tester.pump();
    }
  }

  testWidgets('adds two numbers by tapping the keypad', (tester) async {
    await pumpApp(tester);

    await tapKeys(tester, ['1', '2', '+', '3', '=']);

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

  testWidgets('history lists calculations newest first and can be cleared', (
    tester,
  ) async {
    await pumpApp(tester);

    await tapKeys(tester, ['1', '2', '+', '3', '=']);
    await tapKeys(tester, ['6', '×', '7', '=']);
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect((tiles[0].title! as Text).data, '6 × 7 = 42');
    expect((tiles[1].title! as Text).data, '12 + 3 = 15');

    await tester.tap(find.byTooltip('Clear history'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Clear'));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
    expect(find.text('No calculations yet'), findsOneWidget);
  });
}
