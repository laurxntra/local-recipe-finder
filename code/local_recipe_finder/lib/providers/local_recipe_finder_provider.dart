import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:local_recipe_finder/util/recipe_mocker.dart';
import '../models/recipe.dart';
import 'dart:async';

/// Provider class that manages fetching/storing recipes from TheMealDB API
/// Filters recipes by a given location/area and exposes loading data and data
class LocalRecipeFinderProvider extends ChangeNotifier {
  final Isar isar;

  LocalRecipeFinderProvider(this.isar) {
    // Load saved recipes and all recipes synchronously on provider init
    likedRecipes = isar.recipes.where().findAllSync();
    _recipes = isar.recipes.where().findAllSync();
    notifyListeners(); // notify UI after loading
  }

  // Private list to store fetched recipes
  List<Recipe> _recipes = [];

  // List to store saved recipes
  List<Recipe> likedRecipes = [];

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  // Getter to get recipes list
  List<Recipe> get recipes => _recipes;

  // Indicates if data is loading or not
  bool _isLoading = false;

  // Getter for loading state
  bool get isLoading => _isLoading;

  void nextRecipe() {
    if (_currentIndex < _recipes.length) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousRecipe() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void resetIndex() {
    _currentIndex = 0;
    notifyListeners();
  }

  void updatedRecipe(Recipe updatedRecipe) {
    final index = likedRecipes.indexWhere((r) => r.id == updatedRecipe.id);
    if (index != -1) {
      likedRecipes[index] = updatedRecipe;
      notifyListeners();
    }
  }

  /// Fetches recipes filtered by location from TheMealDB API
  ///
  /// Parameters:
  /// - area: the location to filter recipes by
  Future<void> fetchRecipesByLocation(String area) async {
    _isLoading = true;
    notifyListeners();

    final existingRecipe = await isar.recipes.filter().locationEqualTo(area).findAll();

    if (existingRecipe.isNotEmpty) {
      _recipes = existingRecipe;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/filter.php?a=$area',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meals = data['meals'] as List<dynamic>?;

        if (meals == null) {
          _recipes = [];
        } else {
          List<Recipe> detailedRecipes = [];

          for (var meal in meals) {
            final id = meal['idMeal'] as String;
            final detailedRecipe = await fetchRecipeDetails(id, area);
            if (detailedRecipe != null) {
              detailedRecipes.add(detailedRecipe);
            }
          }
          _recipes = detailedRecipes;

          await isar.writeTxn(() async {
            await isar.recipes.putAll(_recipes);
          });
        }
      } else {
        _recipes = [];
      }
    } catch (e) {
      _recipes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetches detailed recipe information by meal ID from TheMealDB API
  ///
  /// Parameters:
  /// - id: the ID of the meal to look up
  /// - area: the location associated with the recipe
  ///
  /// Returns:
  /// - A Recipe object populated with the data needed if successful, otherwise returns null
  Future<Recipe?> fetchRecipeDetails(String id, String area) async {
    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meals = data['meals'] as List<dynamic>?;

        if (meals == null || meals.isEmpty) {
          return null;
        }

        final meal = meals[0];

        List<String> ingredients = [];
        for (int i = 1; i <= 20; i++) {
          final ingredient = meal['strIngredient$i'];
          final measure = meal['strMeasure$i'];
          if (ingredient != null && ingredient.toString().isNotEmpty) {
            ingredients.add(
              '${measure?.toString().trim() ?? ''} ${ingredient.toString().trim()}'.trim(),
            );
          }
        }

        final instructionsRaw = meal['strInstructions'] as String? ?? '';
        List<String> instructions = instructionsRaw
            .split(RegExp(r'\.\s+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        return Recipe(
          name: meal['strMeal'] ?? 'Unknown',
          imageUrl: meal['strMealThumb'] ?? '',
          ingredients: ingredients,
          instructions: instructions,
          location: area,
          notes: '',
        );
      }
    } catch (e) {
      print('an error has occurred: $e');
      return null;
    }

    return null;
  }

  /// Adds a recipe to the list of saved recipes and saves it in Isar
  ///
  /// Parameters:
  /// - recipe: The recipe object to be saved
  Future<void> saveRecipe(Recipe recipe) async {
    // Avoid duplicates by checking the id
    final exists = likedRecipes.any((r) => r.id == recipe.id);
    if (!exists) {
      likedRecipes.add(recipe);
    }

    await isar.writeTxn(() async {
      final id = await isar.recipes.put(recipe);
      if (recipe.id == null || recipe.id == 0) {
        recipe.id = id;
      }
    });
    notifyListeners();
  }

  /// Removes a saved recipe from the list and deletes from Isar
  Future<void> removeRecipe(Recipe recipe) async {
    likedRecipes.removeWhere((r) => r.id == recipe.id);
    await isar.writeTxn(() async {
      if (recipe.id != null) {
        await isar.recipes.delete(recipe.id!);
      }
    });
    notifyListeners();
  }
}
