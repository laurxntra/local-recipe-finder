import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/local_recipe_finder_provider.dart';

/// Displays a scrollable list of recipes saved by the user
class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  /// Builds the widget for the saved recipes page
  /// 
  /// Parameters:
  /// - context: Used to access the provider
  /// 
  /// Returns:
  /// - The UI of lists of saved recipe cards/a message indicating no saved recipes yet
  Widget build(BuildContext context) {
    // Accesses the provider to retrieve the list of liked recipes
    final provider = Provider.of<LocalRecipeFinderProvider>(context);
    final savedRecipes = provider.likedRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        centerTitle: true,
      ),
      body: savedRecipes.isEmpty
      // Displays a message if no recipes have been saved yet
          ? const Center(
              child: Text(
                "No saved recipes yet. Start swiping!",
                style: TextStyle(fontSize: 16),
              ),
            )
            // If there are saved recipes, showing the user in a scrollable list
          : ListView.builder(
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipe name
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Recipe image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            recipe.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Recipe Ingredients
                        const Text(
                          'Ingredients:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...recipe.ingredients.map((item) => Text("• $item")),
                        const SizedBox(height: 10),
                        // Recipe instructions
                        const Text(
                          'Instructions:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          recipe.instructions.isNotEmpty
                              ? recipe.instructions.first
                              : "No instructions available.",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
