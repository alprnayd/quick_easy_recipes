import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/about/about_screen.dart';
import '../ui/screens/categories/categories_screen.dart';
import '../ui/screens/category_recipes/category_recipes_screen.dart';
import '../ui/screens/cooking_mode/cooking_mode_screen.dart';
import '../ui/screens/favorites/favorites_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/recipe_detail/recipe_detail_screen.dart';
import '../ui/screens/recipe_form/recipe_form_screen.dart';
import '../ui/screens/recipes/recipes_screen.dart';
import '../ui/screens/shopping_list/shopping_list_screen.dart';
import '../ui/shell/app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: '/recipes',
          builder: (context, state) {
            return const RecipesScreen();
          },
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) {
            return const FavoritesScreen();
          },
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) {
            return const CategoriesScreen();
          },
        ),
        GoRoute(
          path: '/shopping',
          builder: (context, state) {
            return const ShoppingListScreen();
          },
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) {
            return const AboutScreen();
          },
        ),
      ],
    ),

    GoRoute(
      path: '/category/:id',
      builder: (context, state) {
        final int? categoryId = int.tryParse(
          state.pathParameters['id'] ?? '',
        );

        final String categoryName =
            state.uri.queryParameters['name'] ??
                'Category Recipes';

        if (categoryId == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid category id.'),
            ),
          );
        }

        return CategoryRecipesScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        );
      },
    ),

    GoRoute(
      path: '/recipe/new',
      builder: (context, state) {
        return const RecipeFormScreen();
      },
    ),

    GoRoute(
      path: '/recipe/:id/edit',
      builder: (context, state) {
        final int? recipeId = int.tryParse(
          state.pathParameters['id'] ?? '',
        );

        if (recipeId == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid recipe id.'),
            ),
          );
        }

        return RecipeFormScreen(
          recipeId: recipeId,
        );
      },
    ),

    GoRoute(
      path: '/recipe/:id/cooking',
      builder: (context, state) {
        final int? recipeId = int.tryParse(
          state.pathParameters['id'] ?? '',
        );

        if (recipeId == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid recipe id.'),
            ),
          );
        }

        return CookingModeScreen(
          recipeId: recipeId,
        );
      },
    ),

    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) {
        final int? recipeId = int.tryParse(
          state.pathParameters['id'] ?? '',
        );

        if (recipeId == null) {
          return const Scaffold(
            body: Center(
              child: Text('Invalid recipe id.'),
            ),
          );
        }

        return RecipeDetailScreen(
          recipeId: recipeId,
        );
      },
    ),
  ],

  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
        ),
      ),
    );
  },
);