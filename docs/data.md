# Data

## Data Design

Firstly, we have a Recipe class which includes the recipe id, name, image url, ingredients, instructions, location where it was suggested from, user notes, and userId of the user who stored the recipe. More specifically, here is pseudocode of what this data structure looks like:
```
Recipe {
  Id? id;
  String name;
  String imageUrl;
  List<String> ingredients;
  List<String> instructions;
  String location;
  String? notes;
  String userId;
}
```
Feel free to see the full code in `providers/recipe.dart`. 

We have 3 providers. The first is LocalRecipeFinderProvider, which stores all the fetched recipes local to the user. This stores a list of fetched recipes, a list of liked recipes (i.e. saved recipes) by the user, the current index in the fetched recipes list that we will display on the homepage for the user to swipe on, and whether the data is currently loading/being fetched. In pseudocode:
```
LocalRecipeFinderProvider {
  List<Recipe> recipes;
  List<Recipe> likedRecipes;
  int currentIndex;
  bool isLoading;
}
```
See the actual code in `providers/local_recipe_finder_provider.dart`. 
The second provider is the NotesProvider. This stores the notes for a single recipe that the user is on. It stores the string currentNotes which is the cached/most recent version of the user's notes, and 2 lists pastNotes and futureNotes to implement undo/redo. Here is pseudocode:

```
NotesProvider {
  String currentNotes;
  List<String> pastNotes;
  List<String> futureNotes;
}
```
See the actual code in `providers/notes_provider.dart`. 

Finally, the last provider is PositionProvider. This stores the data for the user's current location, like their longitude, latitude, whether their position is known, and a string for an error message. Psuedocode is:
```
Position Provider {
  double longitude;
  double latitude;
  bool positionKnown;
  String positionError;
}
```
Full code is in `providers/position_provider.dart`. 

Also, outside of the local data, we store data persistently and fetch it to update the local data. First, we use the uuid package to generate a userId string for the user if the device doesn't already have one. We save it persistently on the device using the SharedPreferences library. Then, we store (and fetch from) a collection in the Isar database which has all the `Recipe`s. 

Now let me explain how this data connects together and is cohesive, in the next section.

## Data Flow

As mentioned previously, we architected our app to use 3 providers to store the changing data. The purpose of LocalRecipeFinderProvider is to store all the recipes to swipe through on the homepage and store which one is currently being viewed. The purpose of NotesProvider is to store the current recipe's notes and implement undo/redo for it. The purpose of PositionProvider is to store the user's current location data. In `main.dart`, we create all of these providers. The Homepage view is a consumer of LocalRecipeFinderProvider. It gets the location from the PositionProvider, calculates the more generic area based on the exact location, and fetches the recipes based on this area using the LocalRecipeFinderProvider's function. Homepage then allows you to swipe through all the recipes that are stored in LocalRecipeFinderProvider and update it. 

Our second view is the SavedPage to see a list of all the saved recipes. These are also stored in LocalRecipeFinderProvider, so SavedPage view uses that as well. The third view is the RecipeDetailsPage, which shows the recipe details when you click on a recipe from the saved page. This is a consumer of the NotesProvider because it has the display to type notes, undo what you wrote, and redo what you wrote. When the note is saved (on click of back button), it is saved in the list in the LocalRecipeFinderProvider. 

To clarify how the database fits into this, first when the app first renders, it checks if SharedPreferences has a userId field. If not, it creates it. Then it indexes Isar for the collections under the userId. If it exists, it gets those saved recipes and populates the LocalRecipeFinderProvider. It also creates the 3 providers, which would get the location and recipes by location. 

Therefore, the data flow in our app is very structured and organized to use 3 providers, and persistence as well. 

All the changes are propagated in a reactive way because when the user saves a recipe (by swiping right), that calls a function in LocalRecipeFinderProvider to add it to the saved list. When the user swipes in any direction, also calls a function in LocalRecipeFinderProvider to update the currentIndex. When the user is on the SavedPage view and clicks on a recipe, that shows the RecipeDetailsPage view. When the user adds notes or presses undo/redo, that calls corresponding functions in the NotesProvider. When the user reruns the app, PositionProvider's constructor is called to get the location and fetch recipes by location. 