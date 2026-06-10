import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../business/recipe_service.dart';
import '../../../business/shopping_item_service.dart';
import '../../../data/models/recipe.dart';
import '../../../data/models/shopping_item.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<RecipeDetailScreen> createState() {
    return _RecipeDetailScreenState();
  }
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _recipeService = RecipeService();

  final ShoppingItemService _shoppingItemService =
  ShoppingItemService();

  Recipe? _recipe;

  bool _isLoading = true;
  bool _isAddingIngredients = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    try {
      final Recipe? recipe =
      await _recipeService.getRecipeById(
        widget.recipeId,
      );

      if (!mounted) return;

      setState(() {
        _recipe = recipe;
        _isLoading = false;
        _errorMessage =
        recipe == null ? 'Recipe not found.' : null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Recipe could not be loaded.';
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final Recipe? recipe = _recipe;

    if (recipe == null || recipe.id == null) {
      return;
    }

    final bool newFavoriteValue =
    !recipe.isFavorite;

    try {
      await _recipeService.updateFavorite(
        recipe.id!,
        newFavoriteValue,
      );

      if (!mounted) return;

      setState(() {
        _recipe = recipe.copyWith(
          isFavorite: newFavoriteValue,
        );
      });
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

  Future<void> _editRecipe() async {
    final Recipe? recipe = _recipe;

    if (recipe == null || recipe.id == null) {
      return;
    }

    final bool? result = await context.push<bool>(
      '/recipe/${recipe.id}/edit',
    );

    if (result == true) {
      await _loadRecipe();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recipe updated successfully.',
          ),
        ),
      );
    }
  }

  void _startCooking() {
    final Recipe? recipe = _recipe;

    if (recipe == null || recipe.id == null) {
      return;
    }

    context.push(
      '/recipe/${recipe.id}/cooking',
    );
  }

  Future<void> _addIngredientsToShoppingList() async {
    final Recipe? recipe = _recipe;

    if (recipe == null || recipe.id == null) {
      return;
    }

    final List<String> ingredientNames =
    recipe.ingredients
        .split(RegExp(r'\n+'))
        .map((ingredient) => ingredient.trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();

    if (ingredientNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No ingredients were found.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isAddingIngredients = true;
    });

    try {
      final List<ShoppingItem> shoppingItems =
      ingredientNames.map((ingredientName) {
        return ShoppingItem(
          name: ingredientName,
          recipeId: recipe.id,
        );
      }).toList();

      await _shoppingItemService.addItems(
        shoppingItems,
      );

      if (!mounted) return;

      setState(() {
        _isAddingIngredients = false;
      });

      final GoRouter router = GoRouter.of(context);

      final ScaffoldMessengerState messenger =
      ScaffoldMessenger.of(context);

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${shoppingItems.length} ingredient(s) added '
                'to the shopping list.',
          ),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              messenger.hideCurrentSnackBar();
              router.go('/shopping');
            },
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isAddingIngredients = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingredients could not be added.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteRecipe() async {
    final Recipe? recipe = _recipe;

    if (recipe == null || recipe.id == null) {
      return;
    }

    final bool? shouldDelete =
    await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: Text(
            'Are you sure you want to delete '
                '"${recipe.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _recipeService.deleteRecipe(
        recipe.id!,
      );

      if (!mounted) return;

      context.pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recipe could not be deleted.',
          ),
        ),
      );
    }
  }

  bool _isAssetImage(Recipe recipe) {
    final String? imagePath = recipe.imagePath;

    return imagePath != null &&
        imagePath.startsWith('assets/');
  }

  bool _isLocalImage(Recipe recipe) {
    final String? imagePath = recipe.imagePath;

    return imagePath != null &&
        imagePath.isNotEmpty &&
        !_isAssetImage(recipe) &&
        File(imagePath).existsSync();
  }

  Widget _buildRecipeImage(
      BuildContext context,
      Recipe recipe,
      ) {
    if (_isAssetImage(recipe)) {
      return Image.asset(
        recipe.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _buildImagePlaceholder(context);
        },
      );
    }

    if (_isLocalImage(recipe)) {
      return Image.file(
        File(recipe.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _buildImagePlaceholder(context);
        },
      );
    }

    return _buildImagePlaceholder(context);
  }

  Widget _buildImagePlaceholder(
      BuildContext context,
      ) {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 70,
          ),
          SizedBox(height: 10),
          Text('No recipe image'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || _recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            _errorMessage ?? 'Recipe not found.',
          ),
        ),
      );
    }

    final Recipe recipe = _recipe!;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            tooltip: 'Favorite',
            icon: Icon(
              recipe.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: recipe.isFavorite
                  ? Colors.red
                  : null,
            ),
          ),
          IconButton(
            onPressed: _editRecipe,
            tooltip: 'Edit Recipe',
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 250,
              child: _buildRecipeImage(
                context,
                recipe,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${recipe.cookingTime} minutes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Ingredients',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipe.ingredients,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isAddingIngredients
                          ? null
                          : _addIngredientsToShoppingList,
                      icon: _isAddingIngredients
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(
                        Icons.add_shopping_cart,
                      ),
                      label: const Text(
                        'Add Ingredients to Shopping List',
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Instructions',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipe.instructions,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _startCooking,
                      icon: const Icon(
                        Icons.play_arrow,
                      ),
                      label: const Text(
                        'Start Cooking',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _deleteRecipe,
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
                      label: const Text(
                        'Delete Recipe',
                      ),
                      style:
                      OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}