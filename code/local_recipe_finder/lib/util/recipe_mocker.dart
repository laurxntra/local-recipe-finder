import 'package:local_recipe_finder/models/recipe.dart';

// copied from DB API Canadian database and edited to match our requirements
class RecipeMocker {
  static List<Recipe> getMockRecipe() {
    return [
      Recipe(
        name: "BeaverTails",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/ryppsv1511815505.jpg",
        ingredients: ["Flour", "Yeast", "Milk", "Sugar", "Butter"],
        instructions: [
          "Mix ingredients",
          "Shape dough",
          "Fry until golden brown",
        ],
        location: "Canada",
      ),
      Recipe(
        name: "Breakfast Potatoes",
        imageUrl: "https://www.themealdb.com/images/media/meals/1550441882.jpg",
        ingredients: ["Potatoes", "Oil", "Salt", "Pepper"],
        instructions: ["Cut potatoes", "Fry in oil", "Season and serve"],
        location: "Canada",
      ),
      Recipe(
        name: "Canadian Butter Tarts",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/wpputp1511812960.jpg",
        ingredients: [
          "Pastry",
          "Butter",
          "Brown Sugar",
          "Corn Syrup",
          "Raisins",
        ],
        instructions: ["Prepare filling", "Fill tart shells", "Bake until set"],
        location: "Canada",
      ),
      Recipe(
        name: "Montreal Smoked Meat",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/uttupv1511815050.jpg",
        ingredients: ["Beef Brisket", "Salt", "Peppercorns", "Mustard Seeds"],
        instructions: ["Brine meat", "Smoke slowly", "Serve on rye bread"],
        location: "Canada",
      ),
      Recipe(
        name: "Nanaimo Bars",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/vwuprt1511813703.jpg",
        ingredients: [
          "Butter",
          "Cocoa",
          "Graham Crumbs",
          "Custard Powder",
          "Chocolate",
        ],
        instructions: [
          "Prepare base",
          "Add custard filling",
          "Top with chocolate",
        ],
        location: "Canada",
      ),
      Recipe(
        name: "Pate Chinois",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/yyrrxr1511816289.jpg",
        ingredients: ["Ground Beef", "Corn", "Mashed Potatoes"],
        instructions: ["Layer beef, corn, and potatoes", "Bake until golden"],
        location: "Canada",
      ),
      Recipe(
        name: "Pouding chomeur",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/yqqqwu1511816912.jpg",
        ingredients: ["Flour", "Butter", "Maple Syrup", "Sugar", "Milk"],
        instructions: ["Mix batter", "Pour syrup", "Bake until golden"],
        location: "Canada",
      ),
      Recipe(
        name: "Poutine",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/uuyrrx1487327597.jpg",
        ingredients: ["Fries", "Cheese Curds", "Gravy"],
        instructions: [
          "Prepare fries",
          "Top with cheese curds",
          "Pour hot gravy",
        ],
        location: "Canada",
      ),
      Recipe(
        name: "Rappie Pie",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/ruwpww1511817242.jpg",
        ingredients: ["Potatoes", "Chicken", "Onions", "Broth"],
        instructions: [
          "Grate potatoes",
          "Layer with chicken",
          "Bake until golden",
        ],
        location: "Canada",
      ),
      Recipe(
        name: "Split Pea Soup",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/xxtsvx1511814083.jpg",
        ingredients: ["Split Peas", "Ham", "Onion", "Carrots", "Celery"],
        instructions: [
          "Simmer peas and vegetables",
          "Add ham",
          "Cook until soft",
        ],
        location: "Canada",
      ),
      Recipe(
        name: "Sugar Pie",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/yrstur1511816601.jpg",
        ingredients: ["Pie Crust", "Brown Sugar", "Cream", "Butter", "Flour"],
        instructions: ["Prepare filling", "Fill crust", "Bake until set"],
        location: "Canada",
      ),
      Recipe(
        name: "Timbits",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/txsupu1511815755.jpg",
        ingredients: ["Flour", "Sugar", "Baking Powder", "Eggs", "Milk", "Oil"],
        instructions: ["Make dough", "Shape balls", "Fry until golden"],
        location: "Canada",
      ),
      Recipe(
        name: "Tourtiere",
        imageUrl:
            "https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg",
        ingredients: ["Ground Pork", "Pie Crust", "Onion", "Spices"],
        instructions: ["Prepare filling", "Fill crust", "Bake until golden"],
        location: "Canada",
      ),
    ];
  }
}
