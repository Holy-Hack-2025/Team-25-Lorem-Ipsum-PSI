import 'dart:developer';
import 'dart:typed_data';
import 'dart:async';

import 'package:app/models/cost_estimate.dart';
import 'package:app/models/meal.dart';
import 'package:app/models/nutrition_facts.dart';
import 'package:app/models/recipe.dart';
import 'package:dio/dio.dart';

class SausProvider {
  final dio = Dio();

  static const baseUrl = 'https://holyhack.breitburg.com/saus';

  Future<(String title, String description)> ideate(String value) async {
    log('Ideating...');
    final response = await dio.get(
      '$baseUrl/ideate',
      queryParameters: {'idea': value},
    );

    return (
      response.data['title'] as String,
      response.data['description'] as String,
    );
  }

  Future<Uint8List> imagine(String description) async {
    log('Fetching image...');
    final response = await dio.get(
      '$baseUrl/imagine',
      queryParameters: {'description': description},
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(response.data);
  }

  Future<List<String>> fetchSuggestions(String description) async {
    log('Fetching suggestions...');
    final response = await dio.get(
      '$baseUrl/suggest',
      queryParameters: {'description': description},
    );

    return List<String>.from(response.data['suggestions']);
  }

  Future<(String title, String description)> modify(
    String description,
    String modification,
  ) async {
    log('Modifying ideation...');
    final response = await dio.get(
      '$baseUrl/modify',
      queryParameters: {
        'description': description,
        'modification': modification,
      },
    );

    return (
      response.data['title'] as String,
      response.data['description'] as String,
    );
  }

  /// Function to stream recipe data from separate API endpoints
  Stream<MealResult> craft(MealIdea idea) async* {
    final result = MealResult();

    try {
      // Request 1: Get recipe
      final recipeResponse = await dio.get(
        '$baseUrl/craft/recipe',
        queryParameters: {'description': idea.description},
      );
      log('Got recipe: ${recipeResponse.data}');
      result.recipe = Recipe.fromJson(recipeResponse.data);
      yield result;

      // Request 2: Get nutrition facts
      final nutritionResponse = await dio.get(
        '$baseUrl/craft/nutrition',
        queryParameters: {
          'ingredients': result.recipe!.ingredients.join('\n'),
          'number_of_servings': result.recipe!.numberOfServings,
        },
      );
      log('Got nutrition: ${nutritionResponse.data}');
      result.nutritionFacts = NutritionFacts.fromJson(nutritionResponse.data);
      yield result;

      // Request 3: Get cost estimate
      final costResponse = await dio.get(
        '$baseUrl/craft/cost',
        queryParameters: {
          'ingredients': result.recipe!.ingredients.join('\n'),
          'number_of_servings': result.recipe!.numberOfServings,
          'minutes_required': result.recipe!.minutesRequired,
        },
      );
      log('Got cost estimate: ${costResponse.data}');
      result.costEstimate = CostEstimate.fromJson(costResponse.data);
      yield result;
    } catch (e) {
      // Handle errors
      log('Failed to fetch recipe data: $e');
      throw Exception('Failed to fetch recipe data: $e');
    }
  }
}
