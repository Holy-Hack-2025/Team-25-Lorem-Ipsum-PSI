import 'package:app/models/recipe.dart';
import 'package:app/widgets/global_kitchen_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class RecipeViewScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeViewScreen(this.recipe, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalKitchenAppBar(title: Text('Recipe')),
      body: ListView(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).padding.left + 20,
          right: MediaQuery.of(context).padding.right + 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
          top: 20,
        ),
        children: [
          Text(
            '${recipe.minutesRequired} minutes to make\n${recipe.numberOfServings} servings',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const Gap(40),
          Text('Ingredients', style: Theme.of(context).textTheme.headlineSmall),
          const Gap(10),
          for (final (index, step) in recipe.ingredients.indexed)
            ListTile(
              title: Text(step, style: Theme.of(context).textTheme.bodyMedium),
              leading: SizedBox.fromSize(
                size: Size.square(30),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          const Gap(40),
          Text('Steps', style: Theme.of(context).textTheme.headlineSmall),
          const Gap(10),
          for (final (index, step) in recipe.steps.indexed)
            ListTile(
              title: Text(step, style: Theme.of(context).textTheme.bodyMedium),
              leading: SizedBox.fromSize(
                size: Size.square(30),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
