import 'package:flutter/material.dart';
import 'package:local_recipe_finder/providers/local_recipe_finder_provider.dart';
import 'package:local_recipe_finder/providers/notes_provider.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';

/// This class is the recipe details page to show a single recipe.
/// It extends StatefulWidget to allow it to have state.
/// Fields:
/// - recipe: the recipe to show details for
class RecipeDetailsPage extends StatefulWidget {
  final Recipe recipe; // the current recipe

  /// Constructor that initializes recipe field
  /// Parameters:
  /// - recipe: the recipe to show details for
  /// Returns: N/A
  const RecipeDetailsPage({super.key, required this.recipe});

  /// This creates the state for this widget.
  /// Parameters: N/A
  /// Returns: new instance of _RecipeDetailsPageState
  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

/// This is a class for the sate of the RecipeDetailsPage.
/// It extends `State<RecipeDetailsPage>` to manage the state of the widget.
/// Fields:
/// - _controller: TextEditingController to manage the notes text field
class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late TextEditingController _controller; // text controller for notes

  /// This initializes the state of the widget.
  /// It sets up the TextEditingController and initializes the notes provider.
  /// It also adds a listener to the controller to update the notes provider when the text changes.
  /// Parameters: N/A
  /// Returns: N/A
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(); // creates controller

    // resets the recipe notes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteProvider = Provider.of<NotesProvider>(context, listen: false);
      noteProvider.reset(widget.recipe.notes ?? '');
      _controller.text = noteProvider.note;

      // listens for changes in text field
      _controller.addListener(() {
        final noteProvider = Provider.of<NotesProvider>(context, listen: false);
        if (_controller.text != noteProvider.note) {
          noteProvider.setNote(_controller.text);
        }
      });
    });
  }

  /// This function disposes of the controller and cleans up state
  /// Parameters: N/A
  /// Returns: N/A
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// This function handles when user taps back button. It saves the note and current recipe state.
  /// Parameters: N/A
  /// Returns: Future that resolves when the note is saved and the page is popped.
  Future<void> _popBack() async {
    // get provider and recipe
    final noteProvider = Provider.of<NotesProvider>(context, listen: false);
    final updatedRecipe = widget.recipe.clone(notes: noteProvider.note);

    final provider = Provider.of<LocalRecipeFinderProvider>(
      context,
      listen: false,
    );

    // saves the updated recipe to the database
    await provider.isar.writeTxn(() async {
      await provider.isar.recipes.put(updatedRecipe);
    });

    await provider.isar.writeTxn(() async {
      await provider.isar.recipes.put(updatedRecipe);
    });
    if (!mounted) return;
    Navigator.pop(context, updatedRecipe);
  }

  /// This function builds the widget for the recipe details page.
  /// It displays all recipe information and notes.
  /// Parameters:
  /// - context: to access the provider and build the UI
  /// Returns:
  /// - A Scaffold widget containing the recipe details and notes
  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Semantics(header: true, child: Text(widget.recipe.name)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Recipe image for ${widget.recipe.name}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.recipe.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: const Text(
                // ingredients
                "Ingredients",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...widget.recipe.ingredients.map(
              (item) => Semantics(
                label: '{$item}',
                excludeSemantics: true,
                child: Text("- $item"),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: const Text(
                // instructions
                "Instructions:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...widget.recipe.instructions.asMap().entries.map(
              (entry) => Semantics(
                label: 'Step ${entry.key + 1}: ${entry.value}',
                excludeSemantics: true,
                child: Text("${entry.key + 1}. ${entry.value}"),
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: const Text(
                // notes
                "Notes:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              // undo/redo buttons
              label: "Undo and Redo buttons for notes",
              container: true,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: noteProvider.canUndo ? noteProvider.undo : null,
                    tooltip: "Undo",
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo),
                    onPressed: noteProvider.canRedo ? noteProvider.redo : null,
                    tooltip: "Redo",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Consumer<NotesProvider>(
              builder: (context, provider, _) {
                if (_controller.text != provider.note) {
                  _controller.text = provider.note;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                }

                return Semantics(
                  label:
                      'Notes text field, enter your notes about the recipe here!',
                  child: TextFormField(
                    controller: _controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Write any notes about this recipe here",
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            Align(
              // back button to save
              alignment: Alignment.centerRight,
              child: Semantics(
                button: true,
                label: "Save notes",
                child: ElevatedButton(
                  onPressed: _popBack,
                  child: const Text("Save Notes"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
