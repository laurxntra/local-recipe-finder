import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeDetailsPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recipe.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Ingredients",
              style: TextStyle(
                fontSize:18,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((item) => Text("- $item")),
            const SizedBox(height: 16),
            const Text(
              "Instructions:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.instructions.asMap().entries.map(
              (entry) => Text("${entry.key + 1}. ${entry.value}")),
          ],
        ),
      ),
    );
  }
}