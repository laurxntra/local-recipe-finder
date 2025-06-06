# Reflection on this project

## Course topics we applied
### Course topics we applied, how we applied them, and how the app design reflects our learnings about the design principles in lecture

Our app design reflects our learnings about the design principles in these ways:
- We use high contrast for the foreground and background colors, as per design tip #2. We made sure to keep the background light (white) with font colors and borders being black or dark gray.
- We made UI changes obvious (as per design tip 6a) by always displaying something on the screen regardless of what is happening - we show a loading screen when data is being fetched, an error message if we could not fetch data, or the actual data if successful. 
- On top of that, we also made sure that redundant cues were used when we made the cues for swiping for recipes through multiple ways like showing green/red color based on the swipe direction and displaying the Yes/No text to the correct location (swiping right for yes, and swiping left for no).

Here are some of the course topics we applied:
-  data persistance - we used Isar database to persistently store the user's saved recipes and notes. We used SharedPreferences to store a device-specific user id so the user can see only their data. Overall, with this, users could open the app with their saved recipes without having to save/like recipes all over again. 
- Another course topic we applied was modularizing our code into multiple providers, where each provider handles storing different type of data. We had a Provider that managed the state of recipes that needed to display on the home screen, so that if we needed to show the recipes on the home page, they would be updated correctly as a result for the user to swipe left or right on. 
- With this, two more course topics we applied were through our use of APIs and phone sensors, where the MealDB API we used would fetch current local recipes given a general location. We used the GPS phone sensor as taught in lecture to actually get the user's location and not only display it on the homepage, but also input it when fetching recipes. 
- We also implemented gesture detection with onPan to allow for swiping.
- We also implemented undo/redo for the notes.
## Citations
### Here we cite anything or anyone that assisted us in creation our solution

We used many resources to understand our APIs and how to use flutter.

**General**
- https://medium.com/@viachaslau.pratasenia/the-easiest-way-to-use-environments-in-flutter-fa7b2cf0ed8d
- https://www.themealdb.com/api.php
- https://pub.dev/packages/geolocator
- https://api.flutter.dev/flutter/widgets/GestureDetector-class.html
- https://docs.flutter.dev/cookbook/networking/fetch-data,
- https://api.flutter.dev/flutter/widgets/PopScope-class.html,
- https://stackoverflow.com/questions/66279804/flutter-navigator-2-0-how-to-return-data-from-a-screen
- https://stackoverflow.com/questions/77357118/getting-the-other-values-in-a-record-if-given-the-id-in-isar-database-using-flut

**SwipeCards** (we used these articles to help in our initial implementation with SwipeCards, but we changed it to not use those and instead use GestureDetector later; so, these are now irrelevant)
- https://pub.dev/documentation/swipe_cards/latest/
- https://anupkumarpanwar.medium.com/tinder-like-swipe-cards-in-flutter-2865a76158e3
- https://github.com/AnupKumarPanwar/swipe_cards

**ChatGPT Prompt**:
- asked: `can you give me some example API that could help me with finding local recipes?`
- answered: 
```
  Absolutely! Here are some popular public recipe APIs you can use to fetch recipe data for your app — many have free tiers or open access with some limits:
  1. TheMealDB,
  URL: https://www.themealdb.com/api.php

  Description: Free, open API for meal recipes with images, ingredients, instructions, and categories.

  Key Features: Search meals by name, category, or area (cuisine). Lookup meal details by ID.

  2. Spoonacular,
  URL: https://spoonacular.com/food-api

  Description: Large, comprehensive recipe API with rich search filters, nutrition info, and images.

  Free Tier: Limited free calls (requires API key).
  ```
- We ended up choosing to use MealDB.
 
**Previous Assignments**

We used previous code from AS5, AS6, and AS7 to implement geolocator, undo/redo, and isar. 

## Challenges
### Here we discuss how doing this project challenged and/or deepened each of our understanding of these topics.

- Firstly, this project deepened our understanding of the topic of APIs since we had to integrate a completely different API than what we were used to using in class to update our recipes displaying. We were able to identify an adequate API for our use and purpose with this app, and we think that's important and worth mentioning, since we had several choices in terms of the API we wanted to utilize for this application. This is because there exists more than 1 API for finding recipes. 
- Additionally, we deepened our knowledge of Providers, because we had to identify what state we wanted to keep track of and manage, and since the previous assignments would heavily hint as to what state we would have to keep track of, it was a great experience to be able to identify what we wanted to keep track of in the Provider we had. 
- This project also challenged our understanding of stateful widgets and how they are built, because we faced many issues initially with updating state while they were being built. So, this project taught us where we are allowed to update state and where we can't. 

## Our Original Concept to Final Implementation
### Here we describe what changed from our original concept to our final implementation and explains why our group made those changes from our original design vision.
- In our original concept, we wanted to find recipes local to the specific city that the user was in. However, we were unable to find an API for this, and instead broadened it to the country. We still access the specific location they are in, but only use the country to get recipes.
- In our original concept, we wanted to show the notes in the recipe card previews in the saved page. However, we thought about it more and realized that the notes are much more niche data that the user might not always need to access when scrolling through their recipes, so we made it show in the RecipeDetailsPage and not in each card preview in the Saved Page. 
- In our original concept even before the design doc, we wanted to present users with the option to delete items from the saved recipes section. However, due to timing and having delays related to setup for our project, we were unable to incorporate this idea into our final application. Additionally, we also had an unliked recipes section before we even started on our Figma that we submitted, which would display all of the user's recipes that they swiped left on (said no to). However, we decided to scrap this idea because we thought that people wouldn't find that section at all useful, since users wouldn't want to continue to see recipes they don't like.

## Areas of Future work
### Here we escribe two areas of future work for our app, including how we could increase the accessibility and usability of this app. 
- One area of future work for our app would be to have some sort of user login and password credentials created so that multiple users can access the application without user data being compromised. This would allow data integrity across multiple users so that every user would have their own unique saved recipes. One way to do this is with Firebase. Currently, we use SharedPreferences to store that device-specific userid, but with login/password, it would allow the user to see all their data even on multiple devices if they log into the same account. This increases accessibility and usability because if the user's phone gets broken or unusable, they won't lose their data. TThis would also increase the accessibility since we would ideally want to have error suggestions for users when incorporating the login feature on the landing page, as well as expanding to multiple users. 

- Another area of future work for our app would be to allow the user to search for recipes for specific locations, not just from their current location. This still keeps the core idea of being able to explore your local cuisine, but if users are curious about other places, they can view that as well. This would broaden the users that would be interested in this application, since it could be the case that a user that has lived in a certain location for so long may already know all the recipes provided, or they do not want recipes that are local to them and would rather like recipes from a different location. As a result, more users could come to our app without having the recipes just be restricted to their location. We could increase the usability and accessibility of this app with this by ensuring that users are greeted with this new feature at the top of the home page so they can search for a location that they'd like to get recipes from, which would result in the recipes getting updated.

## Value in CSE 340
### Here we list what we feel was the most valuable thing we learned in CSE 340 that will help us beyond this class, and why.
- The most valuable thing we learned in CSE 340 that will help us beyond this class would be the structure of reactive applications and how they behave when there needs to be an update to the state. It seems to be a core concept with lots of applications that involve this sort of setting state, and rebuilding, like with Javascript and React for example. For this reason, we think that the most valuable thing we learned in CSE 340 would be this, since it's a core concept in how applications are structured and rebuilt when there is a change in state. 
- Another thing most valuable is how to go through the process of taking an idea, formulating it into a design and design doc, and then coding up each piece one by one. This is really useful, because in industry we may not always get a fully-fleshed out specification, we will have to know how to make it ourselves.

## Advice
### Here we list if we could give future CSE 340 students 2-3 pieces of advice at the beginning of the class, what we would say and why.
- Firstly, we would advise that it's good to get familiar with Dart and Flutter with the first two assignments, since they're core to all the future assignments. So, for the first two assignments, try to do more research on both Dart and Flutter when working on the first and second assignment respectively instead of finishing the assignments quickly. 
- Secondly, the other piece of advice we would give to future students would be to attend lecture as much as possible and do the exercises in lecture that are practiced, since they are similar concepts that are practiced in the homework assignments that we are given throughout the quarter, which makes the assignments much more manageable. 
- Thirdly, we would advise students to start thinking of project ideas from the beginning of the class, because there is only about 1 week to do the final project. So, if you already have a fleshed-out idea in mind, that will make the process go faster.