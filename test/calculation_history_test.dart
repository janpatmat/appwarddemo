import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calculator/calculation_history.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts empty', () async {
    final history = await CalculationHistory.load();
    expect(history.entries, isEmpty);
  });

  test('keeps the newest calculation first', () async {
    final history = await CalculationHistory.load();
    history.add('1 + 1 = 2');
    history.add('2 + 2 = 4');
    expect(history.entries, ['2 + 2 = 4', '1 + 1 = 2']);
  });

  test('survives reloading', () async {
    (await CalculationHistory.load()).add('12 + 3 = 15');

    final reloaded = await CalculationHistory.load();
    expect(reloaded.entries, ['12 + 3 = 15']);
  });

  test('clear removes everything', () async {
    final history = await CalculationHistory.load();
    history.add('1 + 1 = 2');
    history.clear();
    expect(history.entries, isEmpty);
    expect((await CalculationHistory.load()).entries, isEmpty);
  });
}
