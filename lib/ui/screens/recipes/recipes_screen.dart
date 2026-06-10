import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../business/recipe_service.dart';
import '../../../data/models/recipe.dart';
import '../../widgets/recipe_card.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final RecipeService _recipeService = RecipeService();

  final TextEditingController _searchController =
  TextEditingController();

  List<Recipe> _recipes = [];

  bool _isLoading = true;
  String? _errorMessage;
  String _searchText = '';

  // null means no cooking time filter.
  int? _maximumCookingTime;

  List<Recipe> get _filteredRecipes {
    final search = _searchText.toLowerCase().trim();

    return _recipes.where((recipe) {
      final matchesSearch =
          search.isEmpty ||
              recipe.title.toLowerCase().contains(search) ||
              recipe.description.toLowerCase().contains(search) ||
              recipe.ingredients.toLowerCase().contains(search);

      final matchesCookingTime =
          _maximumCookingTime == null ||
              recipe.cookingTime <= _maximumCookingTime!;

      return matchesSearch && matchesCookingTime;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    _loadRecipes();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await _recipeService.getAllRecipes();

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
        _errorMessage = 'Recipes could not be loaded.';
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

  Future<void> _openAddRecipeScreen() async {
    final result = await context.push<bool>(
      '/recipe/new',
    );

    if (result == true) {
      await _loadRecipes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recipe added successfully.',
          ),
        ),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
  }

  void _changeCookingTimeFilter(int? time) {
    setState(() {
      _maximumCookingTime = time;
    });
  }

  void _clearAllFilters() {
    _searchController.clear();

    setState(() {
      _maximumCookingTime = null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            onPressed: _loadRecipes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              4,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Recipes',
                hintText: 'Search by title or ingredient',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              4,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Maximum Cooking Time',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              children: [
                _buildTimeFilterChip(
                  label: 'All',
                  value: null,
                ),
                const SizedBox(width: 8),
                _buildTimeFilterChip(
                  label: '10 min',
                  value: 10,
                ),
                const SizedBox(width: 8),
                _buildTimeFilterChip(
                  label: '20 min',
                  value: 20,
                ),
                const SizedBox(width: 8),
                _buildTimeFilterChip(
                  label: '30 min',
                  value: 30,
                ),
              ],
            ),
          ),

          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddRecipeScreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Recipe'),
      ),
    );
  }

  Widget _buildTimeFilterChip({
    required String label,
    required int? value,
  }) {
    final bool isSelected =
        _maximumCookingTime == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        _changeCookingTimeFilter(value);
      },
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

    final recipes = _filteredRecipes;

    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 60,
            ),
            const SizedBox(height: 12),
            const Text(
              'No recipe matches your filters.',
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _clearAllFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecipes,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 90,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];

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