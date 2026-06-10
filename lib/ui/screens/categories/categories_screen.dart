import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../business/category_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() {
    return _CategoriesScreenState();
  }
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _categoryService = CategoryService();

  List<CategoryWithCount> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories =
      await _categoryService.getCategoriesWithCounts();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Categories could not be loaded.';
      });
    }
  }

  Future<void> _openCategory(
      CategoryWithCount item,
      ) async {
    final categoryId = item.category.id;

    if (categoryId == null) return;

    final categoryName = Uri.encodeComponent(
      item.category.name,
    );

    await context.push(
      '/category/$categoryId?name=$categoryName',
    );

    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: _loadCategories,
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
              onPressed: _loadCategories,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text('No categories found.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          final item = _categories[index];

          return Card(
            child: ListTile(
              onTap: () {
                _openCategory(item);
              },
              leading: CircleAvatar(
                child: Text(
                  item.category.name
                      .substring(0, 1)
                      .toUpperCase(),
                ),
              ),
              title: Text(
                item.category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${item.recipeCount} recipe(s)',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ),
          );
        },
      ),
    );
  }
}