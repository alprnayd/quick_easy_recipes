import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../business/category_service.dart';
import '../../../business/recipe_service.dart';
import '../../../data/models/recipe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _recipeService = RecipeService();
  final CategoryService _categoryService = CategoryService();

  int _recipeCount = 0;
  int _favoriteCount = 0;
  int _categoryCount = 0;

  List<Recipe> _quickRecipes = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final List<Recipe> recipes =
      await _recipeService.getAllRecipes();

      final List<Recipe> favorites =
      await _recipeService.getFavoriteRecipes();

      final categories =
      await _categoryService.getAllCategories();

      if (!mounted) return;

      setState(() {
        _recipeCount = recipes.length;
        _favoriteCount = favorites.length;
        _categoryCount = categories.length;

        _quickRecipes = recipes.take(3).toList();

        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Home page could not be loaded.';
      });
    }
  }

  Future<void> _openRecipe(Recipe recipe) async {
    if (recipe.id == null) return;

    await context.push(
      '/recipe/${recipe.id}',
    );

    await _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quick & Easy Recipes',
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/about');
            },
            icon: const Icon(
              Icons.info_outline,
            ),
            tooltip: 'About',
          ),
          IconButton(
            onPressed: _loadDashboard,
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
              onPressed: _loadDashboard,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),

          Text(
            'Overview',
            style:
            Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatisticCard(
                  title: 'Recipes',
                  value: _recipeCount,
                  icon: Icons.restaurant_menu,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatisticCard(
                  title: 'Favorites',
                  value: _favoriteCount,
                  icon: Icons.favorite,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatisticCard(
                  title: 'Categories',
                  value: _categoryCount,
                  icon: Icons.category,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Quick Access',
            style:
            Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          _buildQuickAccessButton(
            title: 'Browse All Recipes',
            subtitle:
            'Search, filter and manage your recipes',
            icon: Icons.menu_book,
            onTap: () {
              context.go('/recipes');
            },
          ),
          const SizedBox(height: 10),

          _buildQuickAccessButton(
            title: 'Favorite Recipes',
            subtitle:
            'Open your saved favorite recipes',
            icon: Icons.favorite,
            onTap: () {
              context.go('/favorites');
            },
          ),
          const SizedBox(height: 10),

          _buildQuickAccessButton(
            title: 'Recipe Categories',
            subtitle:
            'Browse recipes by category',
            icon: Icons.category,
            onTap: () {
              context.go('/categories');
            },
          ),
          const SizedBox(height: 10),

          _buildQuickAccessButton(
            title: 'Shopping List',
            subtitle:
            'Manage ingredients you need to buy',
            icon: Icons.shopping_cart,
            onTap: () {
              context.go('/shopping');
            },
          ),
          const SizedBox(height: 10),

          _buildQuickAccessButton(
            title: 'About Application',
            subtitle:
            'View project and technology information',
            icon: Icons.info_outline,
            onTap: () {
              context.go('/about');
            },
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Recipe Picks',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),
              TextButton(
                onPressed: () {
                  context.go('/recipes');
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_quickRecipes.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No recipes available.',
                  ),
                ),
              ),
            )
          else
            ..._quickRecipes.map(
              _buildRecipeTile,
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              child: Icon(
                Icons.soup_kitchen,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Discover simple and delicious '
                        'recipes that can be prepared quickly.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
              Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildRecipeTile(Recipe recipe) {
    return Card(
      child: ListTile(
        onTap: () {
          _openRecipe(recipe);
        },
        leading: const CircleAvatar(
          child: Icon(Icons.restaurant),
        ),
        title: Text(
          recipe.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${recipe.cookingTime} minutes',
        ),
        trailing: Icon(
          recipe.isFavorite
              ? Icons.favorite
              : Icons.arrow_forward_ios,
          color:
          recipe.isFavorite ? Colors.red : null,
          size: recipe.isFavorite ? 22 : 18,
        ),
      ),
    );
  }
}