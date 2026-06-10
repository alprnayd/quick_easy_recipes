class ShoppingItem {
  final int? id;
  final String name;
  final bool isChecked;
  final int? recipeId;

  const ShoppingItem({
    this.id,
    required this.name,
    this.isChecked = false,
    this.recipeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isChecked': isChecked ? 1 : 0,
      'recipeId': recipeId,
    };
  }

  factory ShoppingItem.fromMap(
      Map<String, dynamic> map,
      ) {
    return ShoppingItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      isChecked: map['isChecked'] == 1,
      recipeId: map['recipeId'] as int?,
    );
  }

  ShoppingItem copyWith({
    int? id,
    String? name,
    bool? isChecked,
    int? recipeId,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      recipeId: recipeId ?? this.recipeId,
    );
  }
}