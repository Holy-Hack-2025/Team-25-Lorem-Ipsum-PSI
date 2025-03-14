import 'package:app/helpers/theming.dart';
import 'package:app/i18n/strings.g.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/meal_builder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/builder',
      builder:
          (context, state) =>
              MealBuilderScreen(initialDescription: state.extra as String),
    ),
  ],
);

class GlobalKitchenApp extends StatelessWidget {
  const GlobalKitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      locale: TranslationProvider.of(context).flutterLocale,
      theme: buildTheme(context),
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: _router,
    );
  }
}
