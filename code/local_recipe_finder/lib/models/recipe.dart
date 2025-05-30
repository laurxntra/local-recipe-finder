import 'package:isar/isar.dart';

/// A model representing a saved/suggested recipe in the app
/// 
/// This is used with Isar database to store recipes that users have either
/// liked or being displayed based on the location
@Collection()
class Recipe {
  // Unique ID for the recipe
  Id? id;

  // The name of the recipe
  late String name;

  // The URL pointing to an image of the recipe
  late String imageUrl;

  // A list of ingredients required for the recipe
  late List<String> ingredients;

  // A list of instructions on how to make the recipe
  late List<String> instructions;

  // The location where the recipe was found/suggested from
  late String location;

  // Notes that can be added by the user for this recipe
  String? notes;

  /// Factory constructor that creates a Recipe with default or provided values
  /// 
  /// Parameters:
  /// - name: name of the recipe
  /// - imageUrl: URL of the recipe image
  /// - ingredients: list of ingredients
  /// - instructions: list of instructions
  /// - location: location tag for the recipe
  /// - notes: notes about the recipe
  /// 
  /// Returns:
  /// - A recipe with all fields initalized
  factory Recipe.fromData({
    String name = '',
    String imageUrl = '',
    List<String> ingredients = const [],
    List<String> instructions = const [],
    String location = '',
    String? notes,
  }) {
    return Recipe(
      name: name,
      imageUrl: imageUrl,
      ingredients: ingredients,
      instructions: instructions,
      location: location,
      notes: notes,
    );
  }

  /// Main constructor for creating a Recipe
  /// 
  /// Parameters:
  /// - id: unique id
  /// - name: name of the recipe
  /// - imageUrl: image URL
  /// - ingredients: list of ingredients
  /// - instructions: list of instructions
  /// - location: location tag
  /// - notes: user notes
  Recipe({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.location,
    this.notes,
  });

  /// Factory constructor that creates an empty Recipe with default values
  /// 
  /// Returns:
  /// - A Recipe with empty or default fields
  factory Recipe.empty() {
    return Recipe(
      name: '',
      imageUrl: '',
      ingredients: [],
      instructions: [],
      location: '',
      notes: '',
    );
  }

  /// Constructor that creates a new Recipe by copying an existing one and updating notes
  /// 
  /// Parameters:
  /// - recipe: original Recipe to copy from
  /// - newNotes: new notes to set for the copied recipe
  /// 
  /// Returns:
  /// - A recipe with updated notes and other fields copied from the original
  Recipe.withUpdatedNotes(Recipe recipe, String newNotes)
    : id = recipe.id,
      name = recipe.name,
      imageUrl = recipe.imageUrl,
      ingredients = recipe.ingredients,
      instructions = recipe.instructions,
      location = recipe.location,
      notes = newNotes;
}