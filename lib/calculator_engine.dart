import 'dart:math';

/// The four arithmetic operations the calculator supports.
enum Operation {
  add('+'),
  subtract('−'),
  multiply('×'),
  divide('÷');

  const Operation(this.symbol);

  final String symbol;

  double apply(double a, double b) => switch (this) {
    Operation.add => a + b,
    Operation.subtract => a - b,
    Operation.multiply => a * b,
    Operation.divide => a / b,
  };
}

/// Holds the calculator state and applies key presses to it.
///
/// Operations are evaluated left to right as they are entered, like a pocket
/// calculator, so `2 + 3 × 4 =` gives 20.
class CalculatorEngine {
  CalculatorEngine({Random? random}) : _random = random ?? Random();

  static const errorText = 'Error';
  static const _maxDigits = 15;

  /// The range of numbers [inputRandom] picks from, inclusive.
  // TODO(GIT-6): confirm the range with the product owner.
  static const randomMin = 1;
  static const randomMax = 100;

  final Random _random;

  String _display = '0';
  String _expression = '';
  double? _accumulator;
  Operation? _pending;

  /// The next digit replaces the display instead of appending to it.
  bool _startNewNumber = true;

  /// The display holds a second operand for [_pending].
  bool _operandEntered = false;
  bool _hasError = false;

  /// The number shown in the main display.
  String get display => _display;

  /// The calculation in progress, e.g. `12 +` or `12 + 3 =`.
  String get expression => _expression;

  /// The operator that is waiting for its second operand, if any.
  Operation? get activeOperation => _operandEntered ? null : _pending;

  double get _value => double.parse(_display);

  void inputDigit(String digit) {
    if (_hasError) clear();
    if (_startNewNumber) {
      _beginNumber(digit);
    } else if (_display == '0') {
      _display = digit;
    } else if (_display.replaceAll(RegExp(r'\D'), '').length < _maxDigits) {
      _display += digit;
    }
    _operandEntered = true;
  }

  void inputDecimal() {
    if (_hasError) clear();
    if (_startNewNumber) {
      _beginNumber('0.');
    } else if (!_display.contains('.')) {
      _display += '.';
    }
    _operandEntered = true;
  }

  /// Puts a random whole number from [randomMin] to [randomMax] in the
  /// display, to be used like a typed number.
  void inputRandom() {
    if (_hasError) clear();
    final value = randomMin + _random.nextInt(randomMax - randomMin + 1);
    _beginNumber('$value');
    // The next digit replaces the random number instead of appending to it.
    _startNewNumber = true;
    _operandEntered = true;
  }

  void setOperation(Operation operation) {
    if (_hasError) return;
    if (_pending == null) {
      _accumulator = _value;
    } else if (_operandEntered && !_calculate()) {
      return;
    }
    // Otherwise an operator was pressed twice in a row, so it is replaced.
    _pending = operation;
    _expression = '${_format(_accumulator!)} ${operation.symbol}';
    _startNewNumber = true;
    _operandEntered = false;
  }

  void equals() {
    final operation = _pending;
    if (_hasError || operation == null) return;
    final left = _accumulator!;
    final right = _value;
    if (!_calculate()) return;
    _expression = '${_format(left)} ${operation.symbol} ${_format(right)} =';
    _accumulator = null;
    _pending = null;
    _startNewNumber = true;
    _operandEntered = false;
  }

  void clear() {
    _display = '0';
    _expression = '';
    _accumulator = null;
    _pending = null;
    _startNewNumber = true;
    _operandEntered = false;
    _hasError = false;
  }

  void backspace() {
    if (_hasError) {
      clear();
      return;
    }
    // Results can't be edited, only replaced.
    if (_startNewNumber) return;
    _display = _display.substring(0, _display.length - 1);
    if (_display.isEmpty || _display == '-' || _display == '-0') {
      _display = '0';
    }
  }

  void toggleSign() {
    if (_hasError || _value == 0) return;
    _display = _display.startsWith('-') ? _display.substring(1) : '-$_display';
    _operandEntered = true;
  }

  void percent() {
    if (_hasError) return;
    _display = _format(_value / 100);
    _startNewNumber = true;
    _operandEntered = true;
  }

  void _beginNumber(String text) {
    // Typing after `=` starts a new calculation, so drop the old expression.
    if (_pending == null) _expression = '';
    _display = text;
    _startNewNumber = false;
  }

  /// Applies [_pending] to the accumulator and the display.
  ///
  /// Returns false and enters the error state if the result is not a finite
  /// number, e.g. after dividing by zero.
  bool _calculate() {
    final result = _pending!.apply(_accumulator!, _value);
    if (!result.isFinite) {
      clear();
      _display = errorText;
      _hasError = true;
      return false;
    }
    _accumulator = result;
    _display = _format(result);
    return true;
  }

  /// Formats [value] without floating point noise, so 0.1 + 0.2 shows 0.3.
  static String _format(double value) {
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    final parts = value.toStringAsPrecision(12).split('e');
    var mantissa = parts[0];
    if (mantissa.contains('.')) {
      mantissa = mantissa.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return parts.length == 2 ? '${mantissa}e${parts[1]}' : mantissa;
  }
}
