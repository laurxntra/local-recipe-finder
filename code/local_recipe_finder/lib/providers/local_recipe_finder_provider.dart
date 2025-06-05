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
    _recipes = isar.recipes.where().findAllSync();
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

  void updatedRecipe (Recipe updatedRecipe) {
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
    // Indicates loading started
    //_currentIndex = 0;
    _isLoading = true;
    notifyListeners();

    //this is for mock data
    //_recipes = RecipeMocker.getMockRecipe;

    // this is to see if there is already a recipe
    final existingRecipe =
        await isar.recipes.filter().locationEqualTo(area).findAll();

    if (existingRecipe.isNotEmpty) {
      // If recipes already exist for this area, load them from Isar
      _recipes = existingRecipe;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Construct url to filter recipes by location
    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/filter.php?a=$area',
    );

    try {
      // HTTP get request
      final response = await http.get(url);

      // Checking for a successful response
      if (response.statusCode == 200) {
        // Decodes JSON response body
        final data = jsonDecode(response.body);
        // Extracts the 'meals' array
        final meals = data['meals'] as List<dynamic>?;

        // If no meals are found, clear the recipe list
        if (meals == null) {
          _recipes = [];
          // Otherwise, prepare a list to hold recipe objects
        } else {
          List<Recipe> detailedRecipes = [];

          // For each meal, fetch the information based off their ID
          for (var meal in meals) {
            final id = meal['idMeal'] as String;
            final detailedRecipe = await fetchRecipeDetails(id, area);
            if (detailedRecipe != null) {
              detailedRecipes.add(detailedRecipe);
            }
          }
          // Update the recipe list with the detailed recipes
          _recipes = detailedRecipes;

          // Save the recipes to the Isar database
          await isar.writeTxn(() async {
            await isar.recipes.putAll(_recipes);
          });
        }
        // An error has occurred, clear the recipes list
      } else {
        _recipes = [];
      }
      // An error has occurred, clear the recipes list
    } catch (e) {
      _recipes = [];
    }

    // Loading complete, now notify listeners
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
    // Consturct URL to look up meal by ID
    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id',
    );

    try {
      // HTTP get request
      final response = await http.get(url);

      // Checking if response is successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meals = data['meals'] as List<dynamic>?;

        // No meal details were found, so return null
        if (meals == null || meals.isEmpty) {
          return null;
        }

        // Extracts the first meal detail object
        final meal = meals[0];

        // Extracts ingredients with their measurements (limiting to 20)
        List<String> ingredients = [];
        for (int i = 1; i <= 20; i++) {
          // Getting the ingredient name
          final ingredient = meal['strIngredient$i'];
          // Getting the measurement amount
          final measure = meal['strMeasure$i'];
          // If the ingredient is not empty, we're going to format the string to our list
          if (ingredient != null && ingredient.toString().isNotEmpty) {
            ingredients.add(
              '${measure?.toString().trim() ?? ''} ${ingredient.toString().trim()}'
                  .trim(),
            );
          }
        }
        // Instructions string from the API
        final instructionsRaw = meal['strInstructions'] as String? ?? '';

        // Splits instruction into individual steps
        List<String> instructions =
            instructionsRaw
                .split(RegExp(r'\.\s+'))
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();

        //print('it worked!');
        // Creates and return a Recipe object populated with all the data
        return Recipe(
          name: meal['strMeal'] ?? 'Unknown',
          imageUrl: meal['strMealThumb'] ?? '',
          ingredients: ingredients,
          instructions: instructions,
          location: area,
          notes: '',
        );
      }
      // Returns null if any errors occurs
    } catch (e) {
      print('an error as occured: $e');
      return null;
    }
    // Returns null if unsuccessful response
    return null;
  }

  /// Adds a recipe to the list of saved recipes
  ///
  /// Parameters:
  /// - recipe: The recipe object to be saved
  Future<void> saveRecipe(Recipe recipe) async {
    if (!likedRecipes.contains(recipe)) {
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


}
