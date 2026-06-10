import '../data/models/category.dart';
import '../data/repositories/category_repository.dart';

class CategoryWithCount {
  final Category category;
  final int recipeCount;

  const CategoryWithCount({
    required this.category,
    required this.recipeCount,
  });
}

class CategoryService {
  final CategoryRepository repository;

  CategoryService({
    CategoryRepository? repository,
  }) : repository =
      repository ?? CategoryRepository();

  Future<List<Category>> getAllCategories() {
    return repository.getAllCategories();
  }

  Future<List<CategoryWithCount>>
  getCategoriesWithCounts() async {
    final categories =
    await repository.getAllCategories();

    final recipeCounts =
    await repository.getRecipeCounts();

    return categories.map((category) {
      final categoryId = category.id;

      return CategoryWithCount(
        category: category,
        recipeCount: categoryId == null
            ? 0
            : recipeCounts[categoryId] ?? 0,
      );
    }).toList();
  }
}