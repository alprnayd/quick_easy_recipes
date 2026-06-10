import '../database/database_helper.dart';
import '../models/recipe.dart';

abstract class RecipeDao {
  Future<List<Recipe>> getAllRecipes();

  Future<List<Recipe>> getRecipesByCategory(int categoryId);

  Future<Recipe?> getRecipeById(int id);

  Future<List<Recipe>> getFavoriteRecipes();

  Future<int> insertRecipe(Recipe recipe);

  Future<int> updateRecipe(Recipe recipe);

  Future<int> deleteRecipe(int id);

  Future<int> updateFavorite(int id, bool isFavorite);
}

class RecipeDaoImpl implements RecipeDao {
  final DatabaseHelper databaseHelper;

  RecipeDaoImpl({
    DatabaseHelper? databaseHelper,
  }) : databaseHelper =
      databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Recipe>> getAllRecipes() async {
    final database = await databaseHelper.database;

    final List<Map<String, Object?>> maps =
    await database.query(
      'recipes',
      orderBy: 'title ASC',
    );

    return maps.map((map) {
      return Recipe.fromMap(
        Map<String, dynamic>.from(map),
      );
    }).toList();
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(
      int categoryId,
      ) async {
    final database = await databaseHelper.database;

    final List<Map<String, Object?>> maps =
    await database.query(
      'recipes',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'title ASC',
    );

    return maps.map((map) {
      return Recipe.fromMap(
        Map<String, dynamic>.from(map),
      );
    }).toList();
  }

  @override
  Future<Recipe?> getRecipeById(int id) async {
    final database = await databaseHelper.database;

    final List<Map<String, Object?>> maps =
    await database.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Recipe.fromMap(
      Map<String, dynamic>.from(maps.first),
    );
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    final database = await databaseHelper.database;

    final List<Map<String, Object?>> maps =
    await database.query(
      'recipes',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'title ASC',
    );

    return maps.map((map) {
      return Recipe.fromMap(
        Map<String, dynamic>.from(map),
      );
    }).toList();
  }

  @override
  Future<int> insertRecipe(Recipe recipe) async {
    final database = await databaseHelper.database;

    final Map<String, dynamic> map = recipe.toMap();
    map.remove('id');

    return database.insert(
      'recipes',
      map,
    );
  }

  @override
  Future<int> updateRecipe(Recipe recipe) async {
    if (recipe.id == null) {
      throw ArgumentError(
        'Recipe id cannot be null.',
      );
    }

    final database = await databaseHelper.database;

    final Map<String, dynamic> map = recipe.toMap();
    map.remove('id');

    return database.update(
      'recipes',
      map,
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  @override
  Future<int> deleteRecipe(int id) async {
    final database = await databaseHelper.database;

    return database.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> updateFavorite(
      int id,
      bool isFavorite,
      ) async {
    final database = await databaseHelper.database;

    return database.update(
      'recipes',
      {
        'isFavorite': isFavorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}