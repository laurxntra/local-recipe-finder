import 'package:flutter/material.dart';
import 'package:local_recipe_finder/providers/local_recipe_finder_provider.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import 'package:isar/isar.dart';

/// A page to view full details of a single recipe,
/// including an editable notes section similar to a journal entry.
///
/// Parameters:
/// - recipe: The Recipe object to display and edit notes for
class RecipeDetailsPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  // Local editable state for the notes field
  late String currentNotes;

  @override
  void initState() {
    super.initState();
    // Initialize notes from recipe or empty string
    currentNotes = widget.recipe.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe.name), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.recipe.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Ingredients",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...widget.recipe.ingredients.map((item) => Text("- $item")),
            const SizedBox(height: 16),

            const Text(
              "Instructions:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...widget.recipe.instructions.asMap().entries.map(
              (entry) => Text("${entry.key + 1}. ${entry.value}"),
            ),
            const SizedBox(height: 24),

            const Text(
              "Notes:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Editable text field for notes, updates local state
            TextFormField(
              initialValue: currentNotes,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Write any notes about this recipe here",
              ),
              onChanged: (value) {
                setState(() {
                  currentNotes = value;
                });
              },
            ),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _popBack(),
                child: const Text("Save Notes"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates an updated Recipe object with the new notes and
  /// returns it to the previous screen via Navigator.pop
  Future<void> _popBack() async {
    final updatedRecipe = Recipe(
      id: widget.recipe.id,
      name: widget.recipe.name,
      location: widget.recipe.location,
      imageUrl: widget.recipe.imageUrl,
      ingredients: widget.recipe.ingredients,
      instructions: widget.recipe.instructions,
      notes: currentNotes,
    );

    final provider = Provider.of<LocalRecipeFinderProvider>(
      context,
      listen: false,
    );

    // Save to Isar database
    await provider.isar.writeTxn(() async {
      await provider.isar.recipes.put(updatedRecipe);
    });

    Navigator.pop(context, updatedRecipe);
  }
}
