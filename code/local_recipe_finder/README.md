# Local Recipe Finder

## About this App
Local Recipe Finder is a mobile app that allows users to view recipes that their current location is known for. Users can swipe on recipes to like/dislike them, and see all their liked recipes in a saved page. They can also add custom notes on their saved recipes and use undo/redo functionality for the notes for ease-of-use when typing the notes on a phone. The purpose of this app is to help people explore thier local cuisine and food culture, get recipe ideas, and to encourage people to cook more.

## How to build and run the app

1. Clone the repo
2. Do `cd code/local_recipe_finder`
3. Do `flutter pub get`
4. Do `flutter run --release` to run it in release mode
  * to run it locally, do `flutter run` only

When changing code:
* Change files as desired
  * If changing `recipe.dart`, run `dart run build_runner build` in `code/local_recipe_finder` to regenerate `recipe.g.dart`. NEVER manually modify `recipe.g.dart`. 
* Do `git add .`, `git commit -m "changes"`, and `git push`

If adding dependencies, do `flutter pub add <>` and make sure it got added in `pubspec.yaml`. 

## Requirements

This app works best on an iphone (iOS). It has not been tested thoroughly on an Android or MacOS and it does not work on a Chrome browser. So, it is required to use the app on an iphone. It is also required that for the app to work correctly, to allow the app to access your gps location and for the device to be connected to the internet.

All the dependencies in the app can be viewed in `pubspec.yaml`. Notably, some are flutter, geolocator, uuid, shared_preferences, and http. The instructions for installing these dependencies are listed in the above section. There are no API keys required for this app.

## Layout of Project Structure

Here is the layout of this repository.

`code/local_recipe_finder`: this includes the project
  - `lib/`: this includes the actual project code with widgets to render
    - `/main.dart`: this is the entry point into the app
    - `models/`: this includes our models/global data structures
      - `recipe.dart`: this is the class for the Recipe data structure. It generates `recipe.g.dart` for isar
    - `providers/`: this includes thet 3 providers for the app: LocalRecipeFinderProvider, NotesProvider, and PositionProvider
      - `local_recipe_finder_provider.dart` stores the relevant recipes to swipe through, the user's saved recipes, and the recipe the user is currently swiping on.
      - `notes_provider.dart` stores the notes for the recipe the user is currently viewing, and lists for implementing undo/redo
      - `position_provider.dart` stores the user's location information and whether it is known or if there exists an error fetching it.
    - `util/`: this includes utility functions
      - `location_utils.dart`: this includes a utility function for converting a location (lat/long) into a general area/country. It uses conditionals based on known coordinate ranges. 
    - `views/`: this includes the views for the main pages of the app, such as the homepage, recipe details page, and thet saved page
      - `home_page.dart` shows the current location and recipe to swipe on.
      - `recipe_details_page.dart` shows a specific recipe and the notes textbox for it.
      - `saved_page.dart` shows the page with the list of all user's saved recipes.
    - The other folders like `ios/`, `android/`, `macos/`, `linux/`, `web/`, and `windows/` include configuration for running the app on all those places respectively
    - `/pubspec.yaml`: this file includes all the dependencies for the app that need to be installed

`docs/`: this folder includes all documentation for the project
