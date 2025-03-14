import 'package:flutter/material.dart';

ThemeData buildTheme(BuildContext context, {Brightness? brightness}) {
  final effectiveBrightness = brightness ?? Theme.of(context).brightness;

  final baseTheme = ThemeData(
    splashFactory: NoSplash.splashFactory,
    fontFamily: 'Inter',
    shadowColor: Colors.transparent,
    scaffoldBackgroundColor: switch (effectiveBrightness) {
      Brightness.dark => const Color(0xFF000000),
      Brightness.light => const Color(0xFFFFFFFF),
    },
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey,
      brightness: effectiveBrightness,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 17, height: 1.4, letterSpacing: 0),
      bodyLarge: TextStyle(
        fontSize: 17,
        height: 1.4,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
      ),
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        height: 1.2,
        fontFamily: 'Inter Display',
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.2,
        fontFamily: 'Inter Display',
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        fontFamily: 'Inter Display',
        letterSpacing: 0,
      ),
      labelLarge: TextStyle(fontSize: 15, height: 1.3, letterSpacing: 0.1),
    ),
  );

  return baseTheme.copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: baseTheme.textTheme.bodyLarge,
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: baseTheme.textTheme.bodyLarge?.color,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: const CircleBorder(),
      foregroundColor: baseTheme.colorScheme.onSurface,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: baseTheme.textTheme.bodyLarge,
        iconColor: baseTheme.textTheme.bodyLarge!.color,
        foregroundColor: baseTheme.textTheme.bodyLarge!.color,
      ),
    ),
    dividerTheme: DividerThemeData(
      space: 1,
      color: baseTheme.colorScheme.secondaryNetrual,
    ),
  );
}

extension GlobalKitchenTextTheme on TextTheme {
  TextStyle? get bodyMedium50 =>
      bodyMedium?.copyWith(color: bodyMedium?.color?.withAlpha(127));

  TextStyle? get bodyMediumCode => bodyMedium?.copyWith(fontFamily: 'Menlo');

  TextStyle? get bodyLarge50 =>
      bodyLarge?.copyWith(color: bodyLarge?.color?.withAlpha(127));

  TextStyle? get labelLarge50 =>
      labelLarge?.copyWith(color: labelLarge?.color?.withAlpha(127));

  TextStyle? get labelLarge70 =>
      labelLarge?.copyWith(color: labelLarge?.color?.withAlpha(178));
}

extension GlobalKitchenColorScheme on ColorScheme {
  Color get secondaryNetrual =>
      brightness == Brightness.dark
          ? const Color(0xFF333333)
          : const Color(0xFFEEEEEE);
}
