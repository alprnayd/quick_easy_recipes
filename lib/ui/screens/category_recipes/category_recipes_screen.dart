import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../business/recipe_service.dart';
import '../../../data/models/recipe.dart';
import '../../widgets/recipe_card.dart';

class CategoryRecipesScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryRecipesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryRecipesScreen> createState() {
    return _CategoryRecipesScreenState();
  }
}

class _CategoryRecipesScreenState
    extends State<CategoryRecipesScreen> {
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes =
      await _recipeService.getRecipesByCategory(
        widget.categoryId,
      );

      if (!mounted) return;

      setState(() {
        _recipes = recipes;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Category recipes could not be loaded.';
      });
    }
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    if (recipe.id == null) return;

    try {
      await _recipeService.updateFavorite(
        recipe.id!,
        !recipe.isFavorite,
      );

      await _loadRecipes();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Favorite status could not be updated.',
          ),
        ),
      );
    }
  }

  Future<void> _openRecipeDetail(Recipe recipe) async {
    if (recipe.id == null) return;

    await context.push('/recipe/${recipe.id}');

    await _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            onPressed: _loadRecipes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadRecipes,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_recipes.isEmpty) {
      return Center(
        child: Text(
          'No recipes found in ${widget.categoryName}.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecipes,
      child: ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];

          return RecipeCard(
            recipe: recipe,
            onTap: () {
              _openRecipeDetail(recipe);
            },
            onFavoritePressed: () {
              _toggleFavorite(recipe);
            },
          );
        },
      ),
    );
  }
}