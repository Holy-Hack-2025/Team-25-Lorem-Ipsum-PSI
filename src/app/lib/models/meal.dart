import 'dart:typed_data';

import 'package:app/models/cost_estimate.dart';
import 'package:app/models/nutrition_facts.dart';
import 'package:app/models/recipe.dart';

class MealIdea {
  final String? title;
  final String description;
  final Uint8List imageBytes;

  const MealIdea({
    required this.title,
    required this.description,
    required this.imageBytes,
  });
}

class MealResult {
  Recipe? recipe;
  NutritionFacts? nutritionFacts;
  CostEstimate? costEstimate;

  MealResult({this.recipe, this.nutritionFacts, this.costEstimate});

  bool get isComplete =>
      recipe != null && nutritionFacts != null && costEstimate != null;
}
