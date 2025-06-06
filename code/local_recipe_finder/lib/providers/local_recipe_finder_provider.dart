import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import '../models/recipe.dart';
import 'dart:async';

/// This is a provider class that extends ChangeNotifier to notify listeners
/// It loads the dat from isar and stores the recipes, liked recipes, and current index of viewing recipe
/// It uses the MealDB API to fetch recipes based on area.
/// Fields:
/// - isar: instance of isar db used to store and retrieve recipes
/// - userId: id of user running this app
/// - _recipes: fetched recipes to allow swiping over
/// - likedRecipes: saved recipes
/// - _currentIndex: curr index of recipe being viewed
/// - _isLoading: if data is loading
class LocalRecipeFinderProvider extends ChangeNotifier {
  final Isar isar; // instance of Isar database
  final String userId; // unique user ID

  /// This is the constructor for the provider. It loads the data from the db
  /// parameters:
  /// - isar: instance of Isar db that stores user data
  /// - userId: unique ID of user running this app, used to filter isar info
  LocalRecipeFinderProvider(this.isar, this.userId) {
    _loadInitialData();
  }

  /// Loads initial data from Isar, filtered from userId. Notifies listeners when data is loaded.
  /// Parameters: N/A
  /// Returns: N/A
  Future<void> _loadInitialData() async {
    likedRecipes = await isar.recipes.where().userIdEqualTo(userId).findAll();
    _recipes = await isar.recipes.where().userIdEqualTo(userId).findAll();
    notifyListeners();
  }

  // Private list to store fetched recipes
  List<Recipe> _recipes = [];

  // List to store saved recipes
  List<Recipe> likedRecipes = [];

  // private index to track in _recipes the user is currently swiping on
  int _currentIndex = 0;

  // getter for _currentIndex
  int get currentIndex => _currentIndex;

  // Getter to get recipes list
  List<Recipe> get recipes => _recipes;

  // Indicates if data is loading or not
  bool _isLoading = false;

  // Getter for loading state
  bool get isLoading => _isLoading;

  /// Sets the next recipe by incrementing index and notifying listeners, if it
  /// hasn't reached the end of the list
  /// Parameters: N/A
  /// Returns: N/A
  void nextRecipe() {
    if (_currentIndex < _recipes.length) {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// Sets the previous recipe by decrementing index and notifying listeners, if it
  /// hasn't reached the start of the list
  /// Parameters: N/A
  /// Returns: N/A
  void previousRecipe() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  /// Resets the current index to 0 and notifies listeners
  /// Parameters: N/A
  /// Returns: N/A
  void resetIndex() {
    _currentIndex = 0;
    notifyListeners();
  }

  /// Updates a specific recipe in the likedRecipes list and notifies listeners.
  /// if it is not found, does nothing.
  /// Parameters:
  /// - updatedRecipe: recipe with updated information
  /// Returns: N/A
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

    await isar.writeTxn(() async {
      // Clear existing recipes for the user
      await isar.recipes.filter().userIdEqualTo(userId).deleteAll();
    });

    final existingRecipe =
        await isar.recipes.filter().locationEqualTo(area).findAll();

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
              detailedRecipe.userId = userId;
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
              '${measure?.toString().trim() ?? ''} ${ingredient.toString().trim()}'
                  .trim(),
            );
          }
        }

        final instructionsRaw = meal['strInstructions'] as String? ?? '';
        List<String> instructions =
            instructionsRaw
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
          userId: '',
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
    recipe.userId = userId;

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
