import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
part 'recipe.g.dart';

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

  @Index()
  late String userId;

  /// Constructor for creating a Recipe object when loading from Isar
  ///
  /// Parameters:
  /// - id: unique id used by isar
  /// - name: name of recipe
  /// - imageUrl: image URL of the recipe
  /// - ingredients: list of ingredients
  /// - instructions: list of instructions
  /// - location: location where recipe was discovered
  /// - notes: user entered notes
  Recipe({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.location,
    required this.userId,
    this.notes = '',
  });

  Recipe clone({
    int? id,
    String? name,
    String? imageUrl,
    List<String>? ingredient,
    List<String>? instruction,
    String? notes,
    String? userId,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? List<String>.from(this.ingredients),
      instructions: instructions ?? List<String>.from(this.instructions),
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
    );
  }

  /// Factory constructor to create a Recipe from a JSON object
  ///
  /// Used when parsing API responses into local Recipe object
  ///
  /// Parameters:
  /// - json: A map containing keys for name, imageUrl, ingredients, instructions, location
  /// and notes
  ///
  /// Returns:
  /// - A Recipe populated with the provided JSON data
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      location: json['location'] ?? '',
      notes: json['notes'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  /// Converts Recipe object into a JSON map
  ///
  /// Returns:
  /// - A [Map<String, dynamic>] representing the recipe -- this is used for our API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'location': location,
      'notes': notes,
      'userId': userId,
    };
  }

  /// Factory constructor to create a placeholder recipe object for loading screen / testing purpose
  ///
  /// Returns:
  /// - A recipe with sample content
  factory Recipe.placeholder() {
    return Recipe(
      name: 'Example Recipe',
      imageUrl: '',
      ingredients: ['Ingredient  1', 'Ingredient 2'],
      instructions: ['Instruction 1', 'Instruction 2'],
      location: 'Unknown',
      userId: 'UserId',
    );
  }
}
