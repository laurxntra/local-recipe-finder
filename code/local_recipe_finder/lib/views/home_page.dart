import 'package:flutter/material.dart';
import 'package:local_recipe_finder/util/location_utils.dart';
import 'package:provider/provider.dart';
import '../providers/local_recipe_finder_provider.dart';
import 'package:local_recipe_finder/providers/position_provider.dart';

/// This class is the view for the homepage.
/// It extends StatefulWidget to allow it to manage state.
/// It shows a recipe one-by-one that is swipeable.
/// Also it shows user's current country location.
/// Fields:
/// - _dragX: tracks horizontal drag distance when swiping
/// - _lastArea: area user was last in/was last calculated
/// - _countryName: name of country user is in
class HomePage extends StatefulWidget {
  /// Constructor for the HomePage widget, initializes it
  const HomePage({super.key});

  /// Creates state for this widget
  /// Parameters: N/A
  /// Returns: A new instance of _HomePageState
  @override
  State<HomePage> createState() => _HomePageState();
}

/// This class is the state for the HomePage widget. It extends `State<HomePage>` for this reason.
/// Fields:
/// - _dragX: tracks horizontal drag distance when swiping
/// - _lastArea: area user was last in/was last calculated
/// - _countryName: name of country user is in
class _HomePageState extends State<HomePage> {
  // Tracks horizontal drag distance during swiping gestures
  double _dragX = 0;
  // Area user was last in/was last calculated
  String? _lastArea;
  // Name of country user is in
  String? _countryName;

  /// This function initializes the state. It gets the location and fetches relevant recipes
  /// once the widget is built.
  /// Parameters: N/A
  /// Returns: N/A
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final positionProvider = context.read<PositionProvider>();
      final recipeProvider = context.read<LocalRecipeFinderProvider>();

      positionProvider.addListener(() async {
        // if we know position, calculate area
        if (positionProvider.positionKnown) {
          final lat = positionProvider.latitude!;
          final long = positionProvider.longitude!;

          final data = getAreaFromCoords(lat, long);
          final area = data[0];
          final country = data[1];

          // If the area has changed, fetch new recipes
          if (_lastArea != area) {
            _lastArea = area;
            await recipeProvider.fetchRecipesByLocation(area);
          }

          // If the country has changed, update the UI
          if (mounted && _countryName != country) {
            setState(() {
              _countryName = country;
            });
          }
        }
      });
    });
  }

  /// This function handles when the user first starts dragging/swiping
  /// Parameters:
  /// - details: the drag start details
  /// - provider: the recipe provider used to access and save recipes
  void _panStart(DragStartDetails details, LocalRecipeFinderProvider provider) {
    setState(() {
      _dragX = 0;
    });
  }

  /// This function handles the update of the drag/swipe gesture
  /// Parameters:
  /// - details: the drag update details
  /// - provider: the recipe provider used to access and save recipes
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
                                      label: '{$step}',
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
