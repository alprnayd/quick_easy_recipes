# Quick & Easy Recipes

A Flutter-based offline recipe management application designed for users who want to discover, organize, and prepare simple meals quickly.

## Overview

Quick & Easy Recipes allows users to browse recipes, manage their own recipe collection, save favorites, follow step-by-step cooking instructions, and create a shopping list from recipe ingredients. All data is stored locally with SQLite, so the main features work without an internet connection.

## Features

- View 35 ready-made recipes across 5 categories
- Create, edit, and delete recipes
- Search recipes by title, description, or ingredients
- Filter recipes by maximum cooking time
- Add and remove favorite recipes
- Browse recipes by category
- Select recipe images from the device gallery
- Follow instructions with step-by-step Cooking Mode
- Add recipe ingredients directly to the Shopping List
- Add, check, and delete shopping items
- Store all data locally using SQLite

## Categories

- Breakfast
- Main Course
- Dessert
- Snack
- Drink

## Technologies Used

- Flutter
- Dart
- SQLite
- sqflite
- go_router
- image_picker
- path

## Architecture

The project follows a layered architecture:

```text
Presentation Layer
        ↓
Business / Service Layer
        ↓
Repository Layer
        ↓
DAO Layer
        ↓
SQLite Database
```

### Project Structure

```text
lib/
  main.dart
  router/
  business/
  data/
    database/
    models/
    dao/
    repositories/
  ui/
    screens/
    widgets/
    shell/
```

## Main Screens

- Home
- Recipes
- Recipe Detail
- Add / Edit Recipe
- Favorites
- Categories
- Cooking Mode
- Shopping List
- About

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android Emulator or physical Android device

### Installation

1. Clone the repository:

```bash
git clone https://github.com/alprnayd/quick_easy_recipes.git
```

2. Open the project folder:

```bash
cd quick_easy_recipes
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

## Testing

The project was checked with:

```bash
flutter analyze
flutter test
```

All implemented features were also manually tested on an Android emulator.

## Current Limitations

- No user authentication
- No cloud synchronization
- No online recipe sharing, comments, or ratings
- Cooking Mode progress is not saved after closing the application
- Duplicate ingredients may be added to the Shopping List

## Future Improvements

- Firebase authentication
- Cloud backup and multi-device synchronization
- Nutrition and calorie information
- Portion scaling
- Weekly meal planning
- Recipe sharing and rating system
- Shopping-list duplicate prevention

## Course Information

This project was developed for:

**CEN306 - Mobile Application Design and Development**  
**Istanbul Topkapi University**

## Author

**Alperen Aydin**

## License

This project was created for educational purposes.
