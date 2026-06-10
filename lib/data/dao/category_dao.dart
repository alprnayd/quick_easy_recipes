import '../database/database_helper.dart';
import '../models/category.dart';

abstract class CategoryDao {
  Future<List<Category>> getAllCategories();

  Future<Map<int, int>> getRecipeCounts();
}

class CategoryDaoImpl implements CategoryDao {
  final DatabaseHelper databaseHelper;

  CategoryDaoImpl({
    DatabaseHelper? databaseHelper,
  }) : databaseHelper =
      databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Category>> getAllCategories() async {
    final database = await databaseHelper.database;

    final List<Map<String, Object?>> maps =
    await database.query(
      'categories',
      orderBy: 'name ASC',
    );

    return maps
        .map(
          (map) => Category.fromMap(
        Map<String, dynamic>.from(map),
      ),
    )
        .toList();
  }

  @override
  Future<Map<int, int>> getRecipeCounts() async {
    final database = await databaseHelper.database;

    final List<Map<String, Object?>> maps =
    await database.rawQuery(
      '''
      SELECT categoryId, COUNT(*) AS recipeCount
      FROM recipes
      GROUP BY categoryId
      ''',
    );

    final Map<int, int> counts = {};

    for (final map in maps) {
      final int categoryId =
      (map['categoryId'] as num).toInt();

      final int recipeCount =
      (map['recipeCount'] as num).toInt();

      counts[categoryId] = recipeCount;
    }

    return counts;
  }
}