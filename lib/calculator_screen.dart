import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'calculator_engine.dart';
import 'theme_controller.dart';

final _googleUrl = Uri.parse('https://www.google.com');

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _engine = CalculatorEngine();

  void _press(VoidCallback action) => setState(action);

  /// Opens Google in the default browser, or in a new tab on web, so the
  /// calculation in progress is kept.
  Future<void> _openGoogle() async {
    bool opened;
    try {
      opened = await launchUrl(
        _googleUrl,
        mode: .externalApplication,
        webOnlyWindowName: '_blank',
      );
    } on PlatformException {
      // Android reports a missing browser this way instead of returning false.
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Couldn't open Google")));
    }
  }

  Map<ShortcutActivator, VoidCallback> get _keyboardShortcuts => {
    for (var i = 0; i <= 9; i++)
      CharacterActivator('$i'): () => _press(() => _engine.inputDigit('$i')),
    const CharacterActivator('.'): () => _press(_engine.inputDecimal),
    const CharacterActivator('+'): () =>
        _press(() => _engine.setOperation(Operation.add)),
    const CharacterActivator('-'): () =>
        _press(() => _engine.setOperation(Operation.subtract)),
    const CharacterActivator('*'): () =>
        _press(() => _engine.setOperation(Operation.multiply)),
    const CharacterActivator('/'): () =>
        _press(() => _engine.setOperation(Operation.divide)),
    const CharacterActivator('%'): () => _press(_engine.percent),
    const CharacterActivator('='): () => _press(_engine.equals),
    const SingleActivator(LogicalKeyboardKey.enter): () =>
        _press(_engine.equals),
    const SingleActivator(LogicalKeyboardKey.numpadEnter): () =>
        _press(_engine.equals),
    const SingleActivator(LogicalKeyboardKey.backspace): () =>
        _press(_engine.backspace),
    const SingleActivator(LogicalKeyboardKey.escape): () =>
        _press(_engine.clear),
    const SingleActivator(LogicalKeyboardKey.delete): () =>
        _press(_engine.clear),
  };

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: _keyboardShortcuts,
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      Align(
                        alignment: .centerRight,
                        child: TextButton.icon(
                          onPressed: _openGoogle,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Google'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _Display(
                          expression: _engine.expression,
                          value: _engine.display,
                        ),
                      ),
                      Expanded(flex: 5, child: _buildKeypad()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    Widget digit(String digit) => _CalcButton(
      label: digit,
      onPressed: () => _press(() => _engine.inputDigit(digit)),
    );

    Widget function(String label, VoidCallback action) => _CalcButton(
      label: label,
      kind: .function,
      onPressed: () => _press(action),
    );

    Widget operation(Operation operation) => _CalcButton(
      label: operation.symbol,
      kind: _engine.activeOperation == operation
          ? .selectedOperation
          : .operation,
      onPressed: () => _press(() => _engine.setOperation(operation)),
    );

    final rows = [
      [
        function('C', _engine.clear),
        _CalcButton(
          icon: Icons.backspace_outlined,
          kind: .function,
          onPressed: () => _press(_engine.backspace),
        ),
        function('%', _engine.percent),
        operation(.divide),
      ],
      [digit('7'), digit('8'), digit('9'), operation(.multiply)],
      [digit('4'), digit('5'), digit('6'), operation(.subtract)],
      [digit('1'), digit('2'), digit('3'), operation(.add)],
      [
        function('±', _engine.toggleSign),
        digit('0'),
        _CalcButton(label: '.', onPressed: () => _press(_engine.inputDecimal)),
        _CalcButton(
          label: '=',
          kind: .equals,
          onPressed: () => _press(_engine.equals),
        ),
      ],
    ];

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        for (final row in rows)
          Expanded(
            child: Row(
              crossAxisAlignment: .stretch,
              children: [
                for (final button in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: button,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == .dark;
    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => controller.toggle(brightness),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display({required this.expression, required this.value});

  final String expression;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisAlignment: .end,
        crossAxisAlignment: .end,
        children: [
          FittedBox(
            fit: .scaleDown,
            child: Text(
              expression,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: .scaleDown,
            child: Text(
              value,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ButtonKind { digit, function, operation, selectedOperation, equals }

class _CalcButton extends StatelessWidget {
  const _CalcButton({
    required this.onPressed,
    this.label,
    this.icon,
    this.kind = .digit,
  });

  final VoidCallback onPressed;
  final String? label;
  final IconData? icon;
  final _ButtonKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (background, foreground) = switch (kind) {
      .digit => (colors.surfaceContainerHighest, colors.onSurface),
      .function => (colors.secondaryContainer, colors.onSecondaryContainer),
      .operation => (colors.primaryContainer, colors.onPrimaryContainer),
      .selectedOperation || .equals => (colors.primary, colors.onPrimary),
    };

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: theme.textTheme.headlineMedium,
      ),
      child: icon != null ? Icon(icon, size: 28) : Text(label!),
    );
  }
}
