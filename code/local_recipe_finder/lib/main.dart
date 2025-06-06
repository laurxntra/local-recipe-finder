import 'package:flutter/material.dart';
import 'package:local_recipe_finder/models/recipe.dart';
import 'package:local_recipe_finder/providers/notes_provider.dart';
import 'package:local_recipe_finder/views/home_page.dart';
import 'package:local_recipe_finder/views/saved_page.dart';
import 'package:provider/provider.dart';
import '../providers/local_recipe_finder_provider.dart';
import 'providers/position_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// This is the main entry point of the Local Recipe Finder app.
/// It initializes the app, sets up the database, and provides the necessary providers for state management.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // make sure it is initialized

  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open([RecipeSchema], directory: dir.path); // get isar

  final prefs = await SharedPreferences.getInstance(); // get userid
  String? userId = prefs.getString('userId');
  if (userId == null) {
    userId = const Uuid().v4(); // generate random UUID if first time
    await prefs.setString('userId', userId);
  }

  runApp(
    MultiProvider(
      providers: [
        // all providers
        ChangeNotifierProvider(
          create: (_) => LocalRecipeFinderProvider(isar, userId!),
        ),
        ChangeNotifierProvider(create: (_) => PositionProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

/// This class is the widget for the main app. It extends StatefulWidget to allow for it to have state.
/// Field: N/A
class MainApp extends StatefulWidget {
  /// Constructor for MainApp, initializes the widget
  /// Parameters: N/A
  /// Returns: N/A
  const MainApp({super.key});

  /// This creates the state for this widget.
  /// Parameters: N/A
  /// Returns: new instance of _MainAppState
  @override
  State<MainApp> createState() => _MainAppState();
}

/// This class is the state for the MainApp widget.
/// It extends `State<MainApp>` to manage the state of the widget.
/// Fields:
/// - _index: the current index of the bottom navigation bar to see which page to show
/// - _pages: a list of pages to show in the app, containing HomePage and SavedPage widgets.
class _MainAppState extends State<MainApp> {
  int _index = 0; // current index of bottom navigation bar

  /// This is a list of pages to show in the app.
  /// It contains the HomePage and SavedPage widgets.
  /// Parameters: N/A
  /// Returns: N/A
  final List<Widget> _pages = [const HomePage(), SavedPage()];

  /// function to handle when an item in the bottom navigation bar is tapped
  /// It updates the state to show the selected page.
  /// Parameters:
  /// - index: the index of the tapped item in the bottom navigation bar
  /// Returns: N/A
  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  /// This builds the widget for the main app.
  /// It sets up the MaterialApp with a title, a Scaffold with a body containing the current page,
  /// and a BottomNavigationBar to switch between pages.
  /// Parameters:
  /// - context: the BuildContext for the widget
  /// Returns: a MaterialApp widget with the main app structure
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Recipe Finder',
      home: Scaffold(
        body: _pages[_index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index, // index in bottom navigation bar
          onTap: _onItemTapped, // callback
          items: const [
            // the actual items in it (tabs)
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home Page"),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: "Saved",
            ),
          ],
        ),
      ),
    );
  }
}
