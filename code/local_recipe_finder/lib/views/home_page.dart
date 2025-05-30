import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../models/recipe.dart';
import '../providers/local_recipe_finder_provider.dart';

/// Displays the swipeable recipe cards based on location
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MatchEngine _matchEngine;
  // List of swipeable cards that is displayed on UI
  final List<SwipeItem> _swipeItems = [];

  @override
  /// Called when the widget is first created
  /// *Fetches recipe data based on the sample location -- currently Canada for now
  void initState() {
    super.initState();
    final provider = Provider.of<LocalRecipeFinderProvider>(context, listen: false);
    provider.fetchRecipesByLocation("Canadian"); // sample area
  }

  @override
  /// Called when the dependencies change
  /// Initalizes the list of SwipeItems and the MatchEngine
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<LocalRecipeFinderProvider>(context);
    // removes any previous swipe items
    _swipeItems.clear();

    // Creates swipe items from the fetched recipes
    for (var recipe in provider.recipes) {
      _swipeItems.add(SwipeItem(
        content: recipe,
        // Saves recipe when swiping right
        likeAction: () => provider.saveRecipe(recipe),
        // Does nothing on swiping left
        nopeAction: () {},
      ));
    }
    // Assigns the list of swipe items to the match engine
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  @override
  /// Builds the user interface for the home page, this includes our
  /// AppBar, swipeable cards, instructions, and our bottom navigation bar
  Widget build(BuildContext context) {
    final provider = Provider.of<LocalRecipeFinderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Local Recipe Finder"),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            // *Default to canada for now until fully implement location
            child: Text(
              '📍 Current Location: Richmond, British Columbia',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
      body: provider.isLoading
      // Indicates that it is loading
          ? const Center(child: CircularProgressIndicator())
          : provider.recipes.isEmpty
          // If nothing is found, show this message
              ? const Center(child: Text("No recipes found at the moment, try again later!"))
              : Column(
                  children: [
                    Expanded(
                      child: SwipeCards(
                        matchEngine: _matchEngine,
                        itemBuilder: (context, index) {
                          final recipe = provider.recipes[index];

                          // Each swipe card displays a recipe
                          return Card(
                            margin: const EdgeInsets.all(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Recipe name
                                    Text(recipe.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    // Recipe image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(recipe.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(height: 12),
                                    // Recipe ingredients
                                    const Text("Ingredients:", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ...recipe.ingredients.map((item) => Text("• $item")),
                                    const SizedBox(height: 12),
                                    // Recipe instructions
                                    const Text("Instructions:", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ...recipe.instructions.map((step) => Text("• $step")),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        onStackFinished: () {
                          // This is called when all available cards have been swiped
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No more recipes. Come back later!")),
                          );
                        },
                      ),
                    ),
                    // Swiping instructions/labels
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: const [
                          Text("swipe right if you like it, swipe left if you don't!", style: TextStyle(fontStyle: FontStyle.italic)),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("NO", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text("YES", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      // * Bottom navigation bar - currently not functional
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
