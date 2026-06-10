import 'package:flutter/material.dart';

import '../../../business/recipe_service.dart';
import '../../../data/models/recipe.dart';

class CookingModeScreen extends StatefulWidget {
  final int recipeId;

  const CookingModeScreen({
    super.key,
    required this.recipeId,
  });

  @override
  State<CookingModeScreen> createState() {
    return _CookingModeScreenState();
  }
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  final RecipeService _recipeService = RecipeService();

  Recipe? _recipe;
  List<String> _steps = [];

  final Set<int> _completedSteps = {};

  int _currentStep = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    try {
      final Recipe? recipe =
      await _recipeService.getRecipeById(widget.recipeId);

      if (!mounted) return;

      if (recipe == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Recipe not found.';
        });
        return;
      }

      final List<String> steps = recipe.instructions
          .split(RegExp(r'\n+'))
          .map((step) => step.trim())
          .where((step) => step.isNotEmpty)
          .toList();

      setState(() {
        _recipe = recipe;
        _steps = steps;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Cooking mode could not be loaded.';
      });
    }
  }

  void _markCurrentStepCompleted() {
    setState(() {
      if (_completedSteps.contains(_currentStep)) {
        _completedSteps.remove(_currentStep);
      } else {
        _completedSteps.add(_currentStep);
      }
    });
  }

  void _goToPreviousStep() {
    if (_currentStep <= 0) return;

    setState(() {
      _currentStep--;
    });
  }

  void _goToNextStep() {
    if (_currentStep >= _steps.length - 1) return;

    setState(() {
      _completedSteps.add(_currentStep);
      _currentStep++;
    });
  }

  void _resetProgress() {
    setState(() {
      _completedSteps.clear();
      _currentStep = 0;
    });
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

    if (_steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cooking Mode'),
        ),
        body: const Center(
          child: Text('No cooking steps were found.'),
        ),
      );
    }

    final Recipe recipe = _recipe!;
    final bool isCurrentStepCompleted =
    _completedSteps.contains(_currentStep);

    final double progress =
        _completedSteps.length / _steps.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Mode'),
        actions: [
          IconButton(
            onPressed: _resetProgress,
            tooltip: 'Reset Progress',
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                recipe.title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(20),
              ),
              const SizedBox(height: 8),

              Text(
                '${_completedSteps.length} of ${_steps.length} steps completed',
              ),
              const SizedBox(height: 24),

              Text(
                'Step ${_currentStep + 1} / ${_steps.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          _steps[_currentStep],
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                value: isCurrentStepCompleted,
                onChanged: (_) {
                  _markCurrentStepCompleted();
                },
                title: const Text(
                  'Mark this step as completed',
                ),
                controlAffinity:
                ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentStep == 0
                          ? null
                          : _goToPreviousStep,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                      _currentStep == _steps.length - 1
                          ? null
                          : _goToNextStep,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                    ),
                  ),
                ],
              ),

              if (_completedSteps.length == _steps.length) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle),
                        SizedBox(width: 8),
                        Text(
                          'Recipe completed!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}