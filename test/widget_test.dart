import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calculator/main.dart';
import 'package:calculator/theme_controller.dart';

Future<void> pumpApp(WidgetTester tester) async {
  final themeController = await ThemeController.load();
  await tester.pumpWidget(CalculatorApp(themeController: themeController));
}

Brightness currentBrightness(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold))).brightness;

/// Records launches instead of opening a browser.
class _FakeUrlLauncher extends UrlLauncherPlatform {
  _FakeUrlLauncher(this._onLaunch);

  final bool Function() _onLaunch;
  final launches = <(String, LaunchOptions)>[];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launches.add((url, options));
    return _onLaunch();
  }
}

_FakeUrlLauncher _fakeUrlLauncher({bool Function()? onLaunch}) {
  final original = UrlLauncherPlatform.instance;
  addTearDown(() => UrlLauncherPlatform.instance = original);
  final fake = _FakeUrlLauncher(onLaunch ?? () => true);
  UrlLauncherPlatform.instance = fake;
  return fake;
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

  testWidgets('Google button opens Google and keeps the calculation', (
    tester,
  ) async {
    final launcher = _fakeUrlLauncher();
    await tester.pumpWidget(const CalculatorApp());

    for (final key in ['1', '2', '+']) {
      await tester.tap(find.widgetWithText(FilledButton, key));
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(TextButton, 'Google'));
    await tester.pump();

    expect(launcher.launches, hasLength(1));
    final (url, options) = launcher.launches.single;
    expect(url, 'https://www.google.com');
    expect(options.mode, PreferredLaunchMode.externalApplication);
    expect(options.webOnlyWindowName, '_blank');
    expect(find.text('12 +'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('shows a message when Google cannot be opened', (tester) async {
    _fakeUrlLauncher(onLaunch: () => false);
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.widgetWithText(TextButton, 'Google'));
    await tester.pump();

    expect(find.text("Couldn't open Google"), findsOneWidget);
  });

  testWidgets('shows a message when no browser is installed', (tester) async {
    _fakeUrlLauncher(
      onLaunch: () => throw PlatformException(code: 'ACTIVITY_NOT_FOUND'),
    );
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.widgetWithText(TextButton, 'Google'));
    await tester.pump();

    expect(find.text("Couldn't open Google"), findsOneWidget);
  });
}
