/// Cost estimate model
class CostEstimate {
  final double totalIngredientsCost;
  final double totalCostLabour;
  final double totalCost;

  CostEstimate({
    required this.totalIngredientsCost,
    required this.totalCostLabour,
    required this.totalCost,
  });

  factory CostEstimate.fromJson(Map<String, dynamic> json) {
    return CostEstimate(
      totalIngredientsCost: json['total_ingredients_cost'].toDouble(),
      totalCostLabour: json['total_cost_labour'].toDouble(),
      totalCost: json['total_cost'].toDouble(),
    );
  }
}
