import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../business/recipe_service.dart';
import '../../../data/models/recipe.dart';
import '../../widgets/recipe_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final recipes = await _recipeService.getFavoriteRecipes();

      if (!mounted) return;

      setState(() {
        _favoriteRecipes = recipes;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Favorite recipes could not be loaded.';
      });
    }
  }

  Future<void> _removeFromFavorites(Recipe recipe) async {
    if (recipe.id == null) return;

    try {
      await _recipeService.updateFavorite(
        recipe.id!,
        false,
      );

      await _loadFavorites();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe could not be removed from favorites.'),
        ),
      );
    }
  }

  Future<void> _openRecipeDetail(Recipe recipe) async {
    if (recipe.id == null) return;

    await context.push('/recipe/${recipe.id}');

    // Detay ekranında favori durumu değişmiş olabilir.
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
        actions: [
          IconButton(
            onPressed: _loadFavorites,
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
              onPressed: _loadFavorites,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_favoriteRecipes.isEmpty) {
      return const Center(
        child: Text('You have no favorite recipes yet.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        itemCount: _favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _favoriteRecipes[index];

          return RecipeCard(
            recipe: recipe,
            onTap: () {
              _openRecipeDetail(recipe);
            },
            onFavoritePressed: () {
              _removeFromFavorites(recipe);
            },
          );
        },
      ),
    );
  }
}