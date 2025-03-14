/// Recipe model to store recipe data
class Recipe {
  final List<String> ingredients;
  final List<String> steps;
  final int minutesRequired;
  final int numberOfServings;

  Recipe({
    required this.ingredients,
    required this.steps,
    required this.minutesRequired,
    required this.numberOfServings,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      minutesRequired: json['minutes_required'],
      numberOfServings: json['number_of_servings'],
    );
  }
}
