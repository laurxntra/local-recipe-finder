import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_recipe_finder/util/location_utils.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/local_recipe_finder_provider.dart';
import 'package:local_recipe_finder/providers/position_provider.dart';
import 'package:geocoding/geocoding.dart';

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
  String? _lastArea;

  String? _countryName;

  @override
  /// Called when the widget is inserted into the tree
  /// Sets a timer that fetches new recipes from the provider every *BLANK* seconds
  void initState() {
    super.initState();
    // Schedule the fetch to happen after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final positionProvider = context.read<PositionProvider>();
      final recipeProvider = context.read<LocalRecipeFinderProvider>();

      positionProvider.addListener(() async {
        if (positionProvider.positionKnown) {
          final lat = positionProvider.latitude!;
          final long = positionProvider.longitude!;

          final data = getAreaFromCoords(lat, long);
          final area = data[0];
          final country = data[1];

          // final placemarks = await placemarkFromCoordinates(lat, long);
          // final country = placemarks.isNotEmpty ? placemarks.first.country : null;

          if(_lastArea != area) {
            _lastArea = area;
            await recipeProvider.fetchRecipesByLocation(area);

          }

          if (mounted && _countryName != country) {
            setState(() {
              _countryName = country;
            });
          }
        }
      });
      // Provider.of<LocalRecipeFinderProvider>(
      //   context,
      //   listen: false,
      // ).fetchRecipesByLocation("Mexican"); // sample area
    });
  }

  void _panStart(DragStartDetails details, LocalRecipeFinderProvider provider) {
    setState(() {
      _dragX = 0;
    });
  }

  void _panUpdate(
    DragUpdateDetails details,
    LocalRecipeFinderProvider provider,
  ) {
    setState(() {
      _dragX += details.delta.dx;
    });
  }

  /// Called when the user horizontally swipe gestures
  ///
  /// Parameters:
  /// - provider: the recipe provider used to access and save recipes
  ///
  /// Returns:
  /// - Updates the UI state
  void _onPanEnd(DragEndDetails details, LocalRecipeFinderProvider provider) {
    // Certain amount of pixels when swiping
    const swipe = 100;

    // If the user swipes right, they saved the recipe
    if (_dragX > swipe) {
      provider.saveRecipe(provider.recipes[provider.currentIndex]);
      setState(() {
        provider.saveRecipe(provider.recipes[provider.currentIndex]);
        provider.nextRecipe();
        _dragX = 0;
      });
      // If the user swipes left, they skip the recipe
    } else if (_dragX < -swipe) {
      setState(() {
        _dragX = 0;
        provider.nextRecipe();
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
    return Consumer<LocalRecipeFinderProvider>(
      builder: (context, provider, child) {
        // Displays loading indicator while recipes are loading
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Displays the message "no recipes found..." if no recipes have been found
        if (provider.recipes.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text("No recipes found at the moment, try again later!"),
            ),
          );
        }

        // If the user swipes through all the available recipes at that given location
        if (provider.currentIndex >= provider.recipes.length) {
          return Scaffold(
            appBar: AppBar(title: const Text("Local Recipe Finder")),
            body: const Center(
              child: Text("No more recipes. Come back later!"),
            ),
          );
        }

        // Recipe to display
        final recipe = provider.recipes[provider.currentIndex];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Local Recipe Finder"),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(24),
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                //child: Consumer<PositionProvider>(
                  //builder: (context, positionProvider, child) {
                    //String locationText;

                    // if (!positionProvider.positionKnown) {
                    //   locationText = "Locating...";
                    // } else if (positionProvider.latitude != null && positionProvider.longitude != null) {
                    //   locationText = "Lat: ${positionProvider.latitude!.toStringAsFixed(2)}, "
                    //   "Lon: ${positionProvider.longitude!.toStringAsFixed(2)}";
                    // } else {
                    //   locationText = "Location is unavailable";
                    // }
                    child: Text(
                      '📍 Current Location: ${_countryName ?? "Locating..."}',
                      style: const TextStyle(fontSize: 14),
                    ),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: Semantics(
                    label:
                        'Recipe card, Swipe right to like, swipe left to skip',
                    child: GestureDetector(
                      onPanStart: (details) => _panStart(details, provider),
                      onPanUpdate: (details) => _panUpdate(details, provider),
                      onPanEnd: (details) => _onPanEnd(details, provider),
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
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      recipe.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Recipe image
                                  Semantics(
                                    label: 'Recipe image for ${recipe.name}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        recipe.imageUrl,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Recipe ingredients
                                  Semantics(
                                    container: true,
                                    child: Text(
                                      "Ingredients:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ...recipe.ingredients.map(
                                    (item) => Semantics(
                                      label: 'Ingredient: $item',
                                      excludeSemantics: true,
                                      child: Text("- $item"),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Recipe instructions
                                  Semantics(
                                    container: true,
                                    child: Text(
                                      "Instructions:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ...recipe.instructions.map(
                                    (step) => Semantics(
                                      label: 'Instructions: $step',
                                      excludeSemantics: true,
                                      child: Text("- $step"),
                                    ),
                                  ),
                                ],
                              ),
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
                child: Semantics(
                  child: Column(
                    children: [
                      const Text(
                        "Swipe right if you like it, swipe left if you don't!",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "NO",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _dragX < -10 ? Colors.red : Colors.black,
                            ),
                          ),
                          Text(
                            "YES",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _dragX > 10 ? Colors.green : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
