import 'package:flutter/material.dart';
import 'package:local_recipe_finder/providers/local_recipe_finder_provider.dart';
import 'package:local_recipe_finder/providers/notes_provider.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  State<RecipeDetailsPage> createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteProvider = Provider.of<NotesProvider>(context, listen: false);
      noteProvider.reset(widget.recipe.notes ?? '');
      _controller.text = noteProvider.note;

      _controller.addListener(() {
        final noteProvider = Provider.of<NotesProvider>(context, listen: false);
        if (_controller.text != noteProvider.note) {
          noteProvider.setNote(_controller.text);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _popBack() async {
    final noteProvider = Provider.of<NotesProvider>(context, listen: false);
    final updatedRecipe = widget.recipe.clone(notes: noteProvider.note);

    final provider = Provider.of<LocalRecipeFinderProvider>(
      context,
      listen: false,
    );

    await provider.isar.writeTxn(() async {
      await provider.isar.recipes.put(updatedRecipe);
    });

    await provider.isar.writeTxn(() async {
      await provider.isar.recipes.put(updatedRecipe);
    });
    Navigator.pop(context, updatedRecipe);
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Semantics (
        header: true,
        child: Text(widget.recipe.name),
        ), 
        centerTitle: true
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
                "Ingredients",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...widget.recipe.ingredients.map(
              (item) => Semantics(
                label: 'Ingredient: $item',
                child: Text("- $item")
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: const Text(
                "Instructions:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...widget.recipe.instructions.asMap().entries.map(
                  (entry) => Semantics(
                    label: 'Step ${entry.key + 1}: ${entry.value}',
                    child: Text("${entry.key + 1}. ${entry.value}"),
                  ),
            ),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: const Text(
                "Notes:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
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
                  label: 'Notes text field, enter your notes about the recipe here!',
                  child:  TextFormField(
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
