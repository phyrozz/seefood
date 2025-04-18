class FoodItem {
  final String food;
  final String description;
  final double confidence;
  final List<dynamic> otherPossibleMatches;

  FoodItem({
    required this.food,
    required this.description,
    required this.confidence,
    required this.otherPossibleMatches,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      food: json['food'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      otherPossibleMatches: (json['otherPossibleMatches'] as List<dynamic>)
          .map((item) => PossibleMatches.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PossibleMatches {
  final String food;
  final String description;
  final double confidence;

  PossibleMatches({
    required this.food,
    required this.description,
    required this.confidence,
  });

  factory PossibleMatches.fromJson(Map<String, dynamic> json) {
    return PossibleMatches(
      food: json['food'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}