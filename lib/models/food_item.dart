class FoodItem {
  final String food;
  final String description;
  final double confidence;

  FoodItem({
    required this.food,
    required this.description,
    required this.confidence,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      food: json['food'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
