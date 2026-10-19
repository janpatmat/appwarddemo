import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:calculator/calculator_engine.dart';

void main() {
  late CalculatorEngine engine;

  setUp(() => engine = CalculatorEngine());

  /// Feeds [keys] to the engine, e.g. `'12+3='`.
  void type(String keys) {
    for (final key in keys.split('')) {
      switch (key) {
        case '+':
          engine.setOperation(Operation.add);
        case '-':
          engine.setOperation(Operation.subtract);
        case '*':
          engine.setOperation(Operation.multiply);
        case '/':
          engine.setOperation(Operation.divide);
        case '=':
          engine.equals();
        case '.':
          engine.inputDecimal();
        case '%':
          engine.percent();
        case 'n':
          engine.toggleSign();
        case '<':
          engine.backspace();
        case 'C':
          engine.clear();
        default:
          engine.inputDigit(key);
      }
    }
  }

  test('starts at zero', () {
    expect(engine.display, '0');
    expect(engine.expression, '');
  });

  test('replaces a leading zero', () {
    type('007');
    expect(engine.display, '7');
  });

  test('does the four basic operations', () {
    type('12+3=');
    expect(engine.display, '15');
    expect(engine.expression, '12 + 3 =');

    type('12-30=');
    expect(engine.display, '-18');

    type('6*7=');
    expect(engine.display, '42');

    type('7/2=');
    expect(engine.display, '3.5');
  });

  test('chains operations left to right', () {
    type('2+3*');
    expect(engine.display, '5');
    expect(engine.expression, '5 ×');

    type('4=');
    expect(engine.display, '20');
  });

  test('replaces an operator pressed twice in a row', () {
    type('5+*3=');
    expect(engine.display, '15');
  });

  test('reuses the display when = follows an operator', () {
    type('5+=');
    expect(engine.display, '10');
  });

  test('hides floating point noise', () {
    type('.1+.2=');
    expect(engine.display, '0.3');
  });

  test('allows only one decimal point', () {
    type('.');
    expect(engine.display, '0.');
    type('5.5');
    expect(engine.display, '0.55');
  });

  test('shows an error when dividing by zero', () {
    type('5/0=');
    expect(engine.display, CalculatorEngine.errorText);

    type('+');
    expect(engine.display, CalculatorEngine.errorText);

    type('8');
    expect(engine.display, '8');
  });

  test('backspace removes the last digit', () {
    type('123<');
    expect(engine.display, '12');
    type('<<<');
    expect(engine.display, '0');
  });

  test('backspace does not edit a result', () {
    type('12+3=<');
    expect(engine.display, '15');
  });

  test('toggles the sign', () {
    type('5n');
    expect(engine.display, '-5');
    type('n');
    expect(engine.display, '5');
    type('C0n');
    expect(engine.display, '0');
  });

  test('negates the second operand', () {
    type('9+3n=');
    expect(engine.display, '6');
  });

  test('converts to a percentage', () {
    type('50%');
    expect(engine.display, '0.5');
  });

  test('clear resets everything', () {
    type('12+3C');
    expect(engine.display, '0');
    expect(engine.expression, '');
    expect(engine.activeOperation, isNull);
  });

  test('typing after a result starts a new calculation', () {
    type('2+2=7');
    expect(engine.display, '7');
    expect(engine.expression, '');
  });

  test('reports the operator waiting for an operand', () {
    type('4+');
    expect(engine.activeOperation, Operation.add);
    type('1');
    expect(engine.activeOperation, isNull);
  });

  test('limits input to 15 digits', () {
    type('1234567890123456789');
    expect(engine.display, '123456789012345');
  });

  test('uses exponent notation for huge results', () {
    type('99999999*99999999=');
    expect(engine.display, '9.9999998e+15');
  });

  group('random number', () {
    test('is a whole number from 1 to 100', () {
      for (var i = 0; i < 500; i++) {
        engine.inputRandom();
        final value = int.parse(engine.display);
        expect(value, inInclusiveRange(1, 100));
      }
    });

    test('can be used in a calculation', () {
      engine = CalculatorEngine(random: Random(1));
      engine.inputRandom();
      final value = int.parse(engine.display);
      type('+5=');
      expect(engine.display, '${value + 5}');
      expect(engine.expression, '$value + 5 =');
    });

    test('can be the second operand', () {
      engine = CalculatorEngine(random: Random(1));
      type('10+');
      engine.inputRandom();
      final value = int.parse(engine.display);
      type('=');
      expect(engine.display, '${10 + value}');
    });

    test('is replaced by the next typed digit', () {
      engine.inputRandom();
      type('7');
      expect(engine.display, '7');
    });

    test('clears an error', () {
      type('5/0=');
      engine.inputRandom();
      expect(int.parse(engine.display), inInclusiveRange(1, 100));
    });

    test('starts a new calculation after a result', () {
      type('2+2=');
      engine.inputRandom();
      expect(engine.expression, '');
    });
  });
}
