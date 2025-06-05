import 'package:flutter/material.dart';
import 'package:local_recipe_finder/models/recipe.dart';
import 'package:local_recipe_finder/views/home_page.dart';
import 'package:local_recipe_finder/views/saved_page.dart';
import 'package:provider/provider.dart';
import '../providers/local_recipe_finder_provider.dart';
import 'package:isar/isar.dart';
//import 'package:path_provider/path_provider.dart';

void main() async {
  //Are used to make Isar run in a Flutter environment.
  WidgetsFlutterBinding.ensureInitialized();
  //final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    RecipeSchema,
  ], directory: ''); //, directory: dir.path);

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocalRecipeFinderProvider(isar),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _index = 0;

  final List<Widget> _pages = [
    const HomePage(),
    SavedPage(),
    // const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Recipe Finder',
      home: Scaffold(
        body: _pages[_index],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: _onItemTapped,
          items: const [
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

  // @override
  // Widget build(BuildContext context) {
  //   return const MaterialApp(
  //     title: 'Local Recipe Finder',
  //     home: const RecipeListScreen(),
  //   );
  // }

// class RecipeListScreen extends StatelessWidget {
//   const RecipeListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(title: 'Local Recipe Finder', home: HomePage());
//   }
// }
