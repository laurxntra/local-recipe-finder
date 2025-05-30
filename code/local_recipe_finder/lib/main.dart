import 'package:flutter/material.dart';
import 'package:local_recipe_finder/models/recipe.dart';
import 'package:local_recipe_finder/views/home_page.dart';
import 'package:provider/provider.dart';
import '../providers/local_recipe_finder_provider.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocalRecipeFinderProvider(),
      child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Local Recipe Finder',
      home: const RecipeListScreen(),
    );
  }
}

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Local Recipe Finder',
      home: HomePage(),
    );
  }
}
