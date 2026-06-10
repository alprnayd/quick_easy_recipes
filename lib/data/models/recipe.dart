class Recipe {
  final int? id;
  final String title;
  final String description;
  final String ingredients;
  final String instructions;
  final int cookingTime;
  final int categoryId;
  final bool isFavorite;
  final String? imagePath;

  const Recipe({
    this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.categoryId,
    this.isFavorite = false,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookingTime': cookingTime,
      'categoryId': categoryId,
      'isFavorite': isFavorite ? 1 : 0,
      'imagePath': imagePath,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      ingredients: map['ingredients'] as String,
      instructions: map['instructions'] as String,
      cookingTime: (map['cookingTime'] as num).toInt(),
      categoryId: (map['categoryId'] as num).toInt(),
      isFavorite: map['isFavorite'] == 1,
      imagePath: map['imagePath'] as String?,
    );
  }

  Recipe copyWith({
    int? id,
    String? title,
    String? description,
    String? ingredients,
    String? instructions,
    int? cookingTime,
    int? categoryId,
    bool? isFavorite,
    String? imagePath,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      cookingTime: cookingTime ?? this.cookingTime,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}