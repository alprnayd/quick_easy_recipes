import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback onFavoritePressed;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onFavoritePressed,
    this.onTap,
  });

  bool get _isAssetImage {
    final String? imagePath = recipe.imagePath;

    return imagePath != null &&
        imagePath.startsWith('assets/');
  }

  bool get _isLocalImage {
    final String? imagePath = recipe.imagePath;

    return imagePath != null &&
        imagePath.isNotEmpty &&
        !_isAssetImage &&
        File(imagePath).existsSync();
  }

  Widget _buildRecipeImage(BuildContext context) {
    if (_isAssetImage) {
      return Image.asset(
        recipe.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
      );
    }

    if (_isLocalImage) {
      return Image.file(
        File(recipe.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      child: const Icon(
        Icons.restaurant_menu,
        size: 42,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 120,
              child: _buildRecipeImage(context),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  12,
                  4,
                  12,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${recipe.cookingTime} minutes',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onFavoritePressed,
              tooltip: recipe.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              icon: Icon(
                recipe.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: recipe.isFavorite
                    ? Colors.red
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}