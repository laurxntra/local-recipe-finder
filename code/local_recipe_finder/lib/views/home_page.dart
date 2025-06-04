import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/local_recipe_finder_provider.dart';

/// The home page is where users can browse local recipes via swipe gestures
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Tracks horizontal drag distance during swiping gestures
  double _dragX = 0;
  // Index of the current recipe being shown to the user
  int _currentIndex = 0;

  @override
  /// Called when the widget is inserted into the tree
  /// Sets a timer that fetches new recipes from the provider every *BLANK* seconds
  void initState() {
    super.initState();
    // Fetches recipes for location every *BLANK* seconds
    final provider = Provider.of<LocalRecipeFinderProvider>(context, listen: false);
    Timer.periodic(const Duration(seconds: 5), (timer) {
      provider.fetchRecipesByLocation("Canadian"); // *sample area for testing*
    });
  }

  /// Called when the user horizontally swipe gestures
  /// 
  /// Parameters:
  /// - provider: the recipe provider used to access and save recipes
  /// 
  /// Returns:
  /// - Updates the UI state
  void _onPanEnd(LocalRecipeFinderProvider provider) {
    // Certain amount of pixels when swiping
    const swipe = 100;

    // If the user swipes right, they saved the recipe
    if (_dragX > swipe) {
      provider.saveRecipe(provider.recipes[_currentIndex]);
      setState(() {
        _dragX = 0;
        _currentIndex++;
      });
      // If the user swipes left, they skip the recipe
    } else if (_dragX < -swipe) {
      setState(() {
        _dragX = 0;
        _currentIndex++;
      });
      // Drag is not far enough to "qualify" as a swipe
    } else {
      setState(() {
        _dragX = 0;
      });
    }
  }

  /// Builds the home page UI, allows the swipeable recipe card as well as the 
  /// navigation bar
  /// 
  /// Parameters:
  /// - context: Accesses the theme and providers
  /// 
  /// Returns:
  /// - The Scaffold widget that contains the UI
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocalRecipeFinderProvider>(context);

    // Displays loading indicator while recipes are loading
    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Displays the message "no recipes found..." if no recipes have been found 
    if (provider.recipes.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No recipes found at the moment, try again later!")),
      );
    }

    // If the user swipes through all the available recipes at that given location
    if (_currentIndex >= provider.recipes.length) {
      return Scaffold(
        appBar: AppBar(title: const Text("Local Recipe Finder")),
        body: const Center(child: Text("No more recipes. Come back later!")),
      );
    }

    // Recipe to display
    final recipe = provider.recipes[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Recipe Finder"),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              '📍 Current Location: Richmond, British Columbia',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onPanUpdate: (details) {
                  // Updates the drag amount as the user swipes
                  setState(() {
                    _dragX += details.delta.dx;
                  });
                },
                // Handles the end of the swipe gesture
                onPanEnd: (_) {
                  _onPanEnd(provider);
                },
                child: Transform.translate(
                  // Moves the card based off the drag position
                  offset: Offset(_dragX, 0),
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recipe title
                            Text(
                              recipe.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Recipe image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                recipe.imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Recipe ingredients
                            const Text(
                              "Ingredients:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...recipe.ingredients.map((item) => Text("• $item")),
                            const SizedBox(height: 12),
                            // Recipe instructions
                            const Text(
                              "Instructions:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...recipe.instructions.map((step) => Text("• $step")),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Swiping instructions
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: const [
                Text(
                  "Swipe right if you like it, swipe left if you don't!",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "NO",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "YES",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home Page"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Saved"),
        ],
      ),
    );
  }
}
