import 'package:isar/isar.dart';

/// A model representing a saved/suggested recipe in the app
/// 
/// This is used with Isar database to store recipes that users have either
/// liked or being displayed based on the location
@Collection()
class Recipe {
  // Unique ID for the recipe, increments based by Isar
  Id id = Isar.autoIncrement;

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
}