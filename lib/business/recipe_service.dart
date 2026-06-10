import '../data/models/recipe.dart';
import '../data/repositories/recipe_repository.dart';

class RecipeService {
  final RecipeRepository repository;

  RecipeService({
    RecipeRepository? repository,
  }) : repository = repository ?? RecipeRepository();

  Future<List<Recipe>> getAllRecipes() {
    return repository.getAllRecipes();
  }

  Future<List<Recipe>> getRecipesByCategory(
      int categoryId,
      ) {
    if (categoryId <= 0) {
      throw ArgumentError(
        'Category id must be greater than zero.',
      );
    }

    return repository.getRecipesByCategory(categoryId);
  }

  Future<Recipe?> getRecipeById(int id) {
    if (id <= 0) {
      throw ArgumentError(
        'Recipe id must be greater than zero.',
      );
    }

    return repository.getRecipeById(id);
  }

  Future<List<Recipe>> getFavoriteRecipes() {
    return repository.getFavoriteRecipes();
  }

  Future<int> addRecipe(Recipe recipe) {
    _validateRecipe(recipe);
    return repository.addRecipe(recipe);
  }

  Future<int> updateRecipe(Recipe recipe) {
    if (recipe.id == null) {
      throw ArgumentError(
        'Recipe id cannot be null.',
      );
    }

    _validateRecipe(recipe);
    return repository.updateRecipe(recipe);
  }

  Future<int> deleteRecipe(int id) {
    if (id <= 0) {
      throw ArgumentError(
        'Recipe id must be greater than zero.',
      );
    }

    return repository.deleteRecipe(id);
  }

  Future<int> updateFavorite(
      int id,
      bool isFavorite,
      ) {
    if (id <= 0) {
      throw ArgumentError(
        'Recipe id must be greater than zero.',
      );
    }

    return repository.updateFavorite(
      id,
      isFavorite,
    );
  }

  void _validateRecipe(Recipe recipe) {
    if (recipe.title.trim().isEmpty) {
      throw ArgumentError(
        'Recipe title cannot be empty.',
      );
    }

    if (recipe.description.trim().isEmpty) {
      throw ArgumentError(
        'Recipe description cannot be empty.',
      );
    }

    if (recipe.ingredients.trim().isEmpty) {
      throw ArgumentError(
        'Ingredients cannot be empty.',
      );
    }

    if (recipe.instructions.trim().isEmpty) {
      throw ArgumentError(
        'Instructions cannot be empty.',
      );
    }

    if (recipe.cookingTime <= 0) {
      throw ArgumentError(
        'Cooking time must be greater than zero.',
      );
    }

    if (recipe.categoryId <= 0) {
      throw ArgumentError(
        'A valid category must be selected.',
      );
    }
  }
}