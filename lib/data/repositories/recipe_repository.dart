import '../dao/recipe_dao.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final RecipeDao recipeDao;

  RecipeRepository({
    RecipeDao? recipeDao,
  }) : recipeDao = recipeDao ?? RecipeDaoImpl();

  Future<List<Recipe>> getAllRecipes() {
    return recipeDao.getAllRecipes();
  }

  Future<List<Recipe>> getRecipesByCategory(
      int categoryId,
      ) {
    return recipeDao.getRecipesByCategory(categoryId);
  }

  Future<Recipe?> getRecipeById(int id) {
    return recipeDao.getRecipeById(id);
  }

  Future<List<Recipe>> getFavoriteRecipes() {
    return recipeDao.getFavoriteRecipes();
  }

  Future<int> addRecipe(Recipe recipe) {
    return recipeDao.insertRecipe(recipe);
  }

  Future<int> updateRecipe(Recipe recipe) {
    return recipeDao.updateRecipe(recipe);
  }

  Future<int> deleteRecipe(int id) {
    return recipeDao.deleteRecipe(id);
  }

  Future<int> updateFavorite(
      int id,
      bool isFavorite,
      ) {
    return recipeDao.updateFavorite(
      id,
      isFavorite,
    );
  }
}