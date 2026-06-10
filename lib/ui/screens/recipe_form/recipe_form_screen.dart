import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../business/category_service.dart';
import '../../../business/recipe_service.dart';
import '../../../data/models/category.dart';
import '../../../data/models/recipe.dart';

class RecipeFormScreen extends StatefulWidget {
  final int? recipeId;

  const RecipeFormScreen({
    super.key,
    this.recipeId,
  });

  @override
  State<RecipeFormScreen> createState() {
    return _RecipeFormScreenState();
  }
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final RecipeService _recipeService = RecipeService();
  final CategoryService _categoryService = CategoryService();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController _descriptionController =
  TextEditingController();

  final TextEditingController _ingredientsController =
  TextEditingController();

  final TextEditingController _instructionsController =
  TextEditingController();

  final TextEditingController _cookingTimeController =
  TextEditingController();

  List<Category> _categories = [];

  Recipe? _existingRecipe;
  int? _selectedCategoryId;
  String? _imagePath;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSelectingImage = false;

  bool get _isEditing {
    return widget.recipeId != null;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories =
      await _categoryService.getAllCategories();

      Recipe? recipe;

      if (_isEditing) {
        recipe = await _recipeService.getRecipeById(
          widget.recipeId!,
        );
      }

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _existingRecipe = recipe;

        if (recipe != null) {
          _titleController.text = recipe.title;
          _descriptionController.text = recipe.description;
          _ingredientsController.text = recipe.ingredients;
          _instructionsController.text = recipe.instructions;
          _cookingTimeController.text =
              recipe.cookingTime.toString();

          _selectedCategoryId = recipe.categoryId;
          _imagePath = recipe.imagePath;
        } else if (categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Form data could not be loaded.',
          ),
        ),
      );
    }
  }

  Future<void> _selectImage() async {
    try {
      setState(() {
        _isSelectingImage = true;
      });

      final XFile? selectedImage =
      await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1400,
      );

      if (selectedImage == null) {
        if (!mounted) return;

        setState(() {
          _isSelectingImage = false;
        });

        return;
      }

      final Directory appDirectory =
      await getApplicationDocumentsDirectory();

      final String extension =
      path.extension(selectedImage.path);

      final String fileName =
          'recipe_${DateTime.now().millisecondsSinceEpoch}$extension';

      final String permanentPath = path.join(
        appDirectory.path,
        fileName,
      );

      final File temporaryFile = File(selectedImage.path);

      final File savedFile = await temporaryFile.copy(
        permanentPath,
      );

      if (!mounted) return;

      setState(() {
        _imagePath = savedFile.path;
        _isSelectingImage = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSelectingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image could not be selected.',
          ),
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a category.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Recipe recipe = Recipe(
        id: _existingRecipe?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: _ingredientsController.text.trim(),
        instructions: _instructionsController.text.trim(),
        cookingTime: int.parse(
          _cookingTimeController.text.trim(),
        ),
        categoryId: _selectedCategoryId!,
        isFavorite:
        _existingRecipe?.isFavorite ?? false,
        imagePath: _imagePath,
      );

      if (_isEditing) {
        await _recipeService.updateRecipe(recipe);
      } else {
        await _recipeService.addRecipe(recipe);
      }

      if (!mounted) return;

      context.pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recipe could not be saved: $error',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _cookingTimeController.dispose();

    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Recipe' : 'Add Recipe',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImageSection(),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a recipe title.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a description.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ingredientsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Ingredients',
                  hintText:
                  'Write each ingredient on a new line.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter ingredients.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _instructionsController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  hintText:
                  'Write each preparation step on a new line.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter instructions.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cookingTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cooking Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final int? cookingTime =
                  int.tryParse(value ?? '');

                  if (cookingTime == null ||
                      cookingTime <= 0) {
                    return 'Please enter a valid cooking time.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                  _isSaving ? null : _saveRecipe,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.save),
                  label: Text(
                    _isEditing
                        ? 'Update Recipe'
                        : 'Save Recipe',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final String? currentImagePath = _imagePath;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
          ),
          clipBehavior: Clip.antiAlias,
          child: currentImagePath != null &&
              File(currentImagePath).existsSync()
              ? Image.file(
            File(currentImagePath),
            fit: BoxFit.cover,
          )
              : const Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 60,
              ),
              SizedBox(height: 8),
              Text('No recipe image selected'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                _isSelectingImage ? null : _selectImage,
                icon: _isSelectingImage
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.photo_library),
                label: Text(
                  currentImagePath == null
                      ? 'Select Image'
                      : 'Change Image',
                ),
              ),
            ),

            if (currentImagePath != null) ...[
              const SizedBox(width: 10),
              IconButton(
                onPressed: _removeImage,
                tooltip: 'Remove Image',
                icon: const Icon(
                  Icons.delete_outline,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}