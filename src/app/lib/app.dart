import 'package:app/helpers/theming.dart';
import 'package:app/i18n/strings.g.dart';
import 'package:app/models/meal.dart';
import 'package:app/models/recipe.dart';
import 'package:app/screens/delivery_map_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/meal_builder_screen.dart';
import 'package:app/screens/meal_creation_screen.dart';
import 'package:app/screens/recipe_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/builder',
      builder:
          (context, state) => MealBuilderScreen(
            initialTitle: (state.extra as (String name, String description)).$1,
            initialDescription:
                (state.extra as (String name, String description)).$2,
          ),
    ),
    GoRoute(
      path: '/create',
      builder:
          (context, state) => MealCreationScreen(idea: state.extra as MealIdea),
    ),
    GoRoute(
      path: '/recipe',
      builder: (context, state) => RecipeViewScreen(state.extra as Recipe),
    ),
    GoRoute(
      path: '/delivery',
      builder: (context, state) => DeliveryMapScreen(state.extra as MealIdea),
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
