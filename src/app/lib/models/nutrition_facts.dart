/// Nutrition facts model
class NutritionFacts {
  final double totalCalories;
  final double totalFat;
  final double totalProtein;
  final double totalCarbs;
  final double totalSugar;

  NutritionFacts({
    required this.totalCalories,
    required this.totalFat,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalSugar,
  });

  factory NutritionFacts.fromJson(Map<String, dynamic> json) {
    return NutritionFacts(
      totalCalories: json['total_calories'].toDouble(),
      totalFat: json['total_fat'].toDouble(),
      totalProtein: json['total_protein'].toDouble(),
      totalCarbs: json['total_carbs'].toDouble(),
      totalSugar: json['total_sugar'].toDouble(),
    );
  }
}
