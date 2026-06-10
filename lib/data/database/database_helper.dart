import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance =
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final String databaseDirectory =
    await getDatabasesPath();

    final String databasePath = join(
      databaseDirectory,
      'quick_easy_recipes.db',
    );

    return openDatabase(
      databasePath,
      version: 4,
      onConfigure: (Database database) async {
        await database.execute(
          'PRAGMA foreign_keys = ON',
        );
      },
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(
      Database database,
      int version,
      ) async {
    await database.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await database.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        instructions TEXT NOT NULL,
        cookingTime INTEGER NOT NULL,
        categoryId INTEGER NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        imagePath TEXT,
        FOREIGN KEY (categoryId)
          REFERENCES categories(id)
          ON DELETE RESTRICT
      )
    ''');

    await _createShoppingItemsTable(database);
    await _insertCategories(database);
    await _insertDemoRecipes(database);
  }

  Future<void> _upgradeDatabase(
      Database database,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await _createShoppingItemsTable(database);
    }

    if (oldVersion < 3) {
      await _insertCategories(database);
      await _insertDemoRecipes(database);
    }

    if (oldVersion < 4) {
      await _fixRecipeImagePaths(database);
    }
  }

  Future<void> _createShoppingItemsTable(
      Database database,
      ) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS shopping_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        isChecked INTEGER NOT NULL DEFAULT 0,
        recipeId INTEGER,
        FOREIGN KEY (recipeId)
          REFERENCES recipes(id)
          ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _insertCategories(
      Database database,
      ) async {
    final List<Map<String, dynamic>> categories = [
      {'id': 1, 'name': 'Breakfast'},
      {'id': 2, 'name': 'Main Course'},
      {'id': 3, 'name': 'Dessert'},
      {'id': 4, 'name': 'Snack'},
      {'id': 5, 'name': 'Drink'},
    ];

    for (final category in categories) {
      await database.insert(
        'categories',
        category,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Map<String, dynamic> _recipe({
    required String title,
    required String description,
    required String ingredients,
    required String instructions,
    required int cookingTime,
    required int categoryId,
    required String imagePath,
    bool isFavorite = false,
  }) {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookingTime': cookingTime,
      'categoryId': categoryId,
      'isFavorite': isFavorite ? 1 : 0,
      'imagePath': imagePath,
    };
  }

  Future<void> _insertDemoRecipes(
      Database database,
      ) async {
    final List<Map<String, dynamic>> recipes = [
      // BREAKFAST

      _recipe(
        title: 'Avocado Toast',
        description:
        'A quick and healthy breakfast with creamy avocado.',
        ingredients:
        '2 slices of bread\n1 avocado\nSalt\nBlack pepper',
        instructions:
        'Toast the bread.\nMash the avocado.\nSpread it over the bread.\nAdd salt and black pepper.',
        cookingTime: 10,
        categoryId: 1,
        imagePath:
        'assets/images/recipes/breakfast_01.jpg',
      ),

      _recipe(
        title: 'Banana Oatmeal',
        description:
        'Warm oatmeal naturally sweetened with banana.',
        ingredients:
        '1 banana\n1 cup milk\nHalf cup oats\nCinnamon',
        instructions:
        'Add milk and oats to a pot.\nCook for five minutes.\nMash the banana.\nMix everything and add cinnamon.',
        cookingTime: 10,
        categoryId: 1,
        imagePath:
        'assets/images/recipes/breakfast_02.jpg',
      ),

      _recipe(
        title: 'Cheese Omelette',
        description:
        'A soft and simple cheese omelette prepared in minutes.',
        ingredients:
        '2 eggs\nCheese\nSalt\n1 teaspoon butter',
        instructions:
        'Beat the eggs with salt.\nMelt the butter in a pan.\nAdd the eggs.\nAdd cheese and fold the omelette.',
        cookingTime: 8,
        categoryId: 1,
        imagePath:
        'assets/images/recipes/breakfast_03.jpg',
        isFavorite: true,
      ),

      _recipe(
        title: 'Easy Pancakes',
        description:
        'Soft homemade pancakes with simple ingredients.',
        ingredients:
        '1 cup flour\n1 cup milk\n1 egg\n1 teaspoon sugar\n1 teaspoon oil',
        instructions:
        'Mix all ingredients in a bowl.\nHeat a lightly oiled pan.\nPour small portions of batter.\nCook both sides until golden.',
        cookingTime: 20,
        categoryId: 1,
        imagePath:
        'assets/images/recipes/breakfast_04.jpg',
      ),

      _recipe(
        title: 'Egg Sandwich',
        description:
        'A filling breakfast sandwich with egg and cheese.',
        ingredients:
        '2 slices of bread\n1 egg\n1 slice of cheese\nSalt',
        instructions:
        'Cook the egg in a pan.\nToast the bread.\nPlace the egg and cheese between the bread slices.\nServe warm.',
        cookingTime: 12,
        categoryId: 1,
        imagePath:
        'assets/images/recipes/breakfast_05.jpg',
      ),

      _recipe(
        title: 'Peanut Butter Toast',
        description:
        'A fast toast with peanut butter and banana.',
        ingredients:
        '2 slices of bread\nPeanut butter\n1 banana',
        instructions:
        'Toast the bread.\nSpread peanut butter over it.\nSlice the banana.\nPlace the banana slices on top.',
        cookingTime: 5,
        categoryId: 1,
        imagePath:
        'assets/images/recipes/breakfast_06.jpg',
      ),

      _recipe(
        title: 'Yogurt Fruit Bowl',
        description:
        'A refreshing breakfast with yogurt and fresh fruit.',
        ingredients:
        '1 cup yogurt\n1 banana\nStrawberries\n1 teaspoon honey',
        instructions:
        'Put the yogurt in a bowl.\nSlice the fruit.\nPlace the fruit over the yogurt.\nAdd honey.',
        cookingTime: 5,
        categoryId: 1,
        imagePath:
        'assets/images/recipes/breakfast_07.jpg',
      ),

      // MAIN COURSE

      _recipe(
        title: 'Baked Potatoes',
        description:
        'Seasoned potato pieces baked until golden.',
        ingredients:
        '3 potatoes\nOlive oil\nSalt\nBlack pepper\nPaprika',
        instructions:
        'Cut the potatoes into pieces.\nMix with oil and seasonings.\nPlace on a baking tray.\nBake until golden and soft.',
        cookingTime: 30,
        categoryId: 2,
        imagePath:
        'assets/images/recipes/main_course_01.jpg',
      ),

      _recipe(
        title: 'Chicken Rice Bowl',
        description:
        'A practical bowl with chicken, rice and vegetables.',
        ingredients:
        '1 chicken breast\n1 cup cooked rice\nMixed vegetables\nSalt\nOlive oil',
        instructions:
        'Cut the chicken into small pieces.\nCook it with olive oil.\nAdd the vegetables.\nServe over cooked rice.',
        cookingTime: 25,
        categoryId: 2,
        imagePath:
        'assets/images/recipes/main_course_02.jpg',
        isFavorite: true,
      ),

      _recipe(
        title: 'Chicken Wrap',
        description:
        'A quick wrap filled with chicken and vegetables.',
        ingredients:
        '1 tortilla\nCooked chicken\nLettuce\nTomato\nYogurt sauce',
        instructions:
        'Warm the tortilla.\nPlace chicken and vegetables in the center.\nAdd yogurt sauce.\nRoll the tortilla tightly.',
        cookingTime: 20,
        categoryId: 2,
        imagePath:
        'assets/images/recipes/main_course_03.jpg',
      ),

      _recipe(
        title: 'Easy Lentil Soup',
        description:
        'A warm and filling red lentil soup.',
        ingredients:
        '1 cup red lentils\n1 onion\n1 carrot\n4 cups water\nSalt',
        instructions:
        'Wash the lentils.\nChop the onion and carrot.\nBoil everything until soft.\nBlend the soup and add salt.',
        cookingTime: 30,
        categoryId: 2,
        imagePath:
        'assets/images/recipes/main_course_04.jpg',
      ),

      _recipe(
        title: 'Tomato Pasta',
        description:
        'Simple pasta served with a quick tomato sauce.',
        ingredients:
        '200 grams pasta\n2 tomatoes\n1 tablespoon olive oil\nSalt\nBlack pepper',
        instructions:
        'Boil the pasta.\nChop and cook the tomatoes with olive oil.\nAdd salt and pepper.\nMix the pasta with the sauce.',
        cookingTime: 20,
        categoryId: 2,
        imagePath:
        'assets/images/recipes/main_course_05.jpg',
      ),

      _recipe(
        title: 'Tuna Pasta Salad',
        description:
        'A cold pasta salad with tuna and fresh vegetables.',
        ingredients:
        '200 grams pasta\n1 can tuna\nCorn\nCucumber\nYogurt',
        instructions:
        'Boil and cool the pasta.\nDrain the tuna.\nChop the cucumber.\nMix all ingredients together.',
        cookingTime: 15,
        categoryId: 2,
        imagePath:
        'assets/images/recipes/main_course_06.jpg',
      ),

      _recipe(
        title: 'Vegetable Stir Fry',
        description:
        'Colorful vegetables quickly cooked in one pan.',
        ingredients:
        '1 carrot\n1 bell pepper\n1 zucchini\nSoy sauce\nOlive oil',
        instructions:
        'Slice all vegetables.\nHeat olive oil in a pan.\nCook the vegetables until slightly soft.\nAdd soy sauce and mix.',
        cookingTime: 20,
        categoryId: 2,
        imagePath:
        'assets/images/recipes/main_course_07.jpg',
      ),

      // DESSERT

      _recipe(
        title: 'Apple Cinnamon Cups',
        description:
        'Warm apples flavored with cinnamon and honey.',
        ingredients:
        '2 apples\nCinnamon\n1 teaspoon honey\nCrushed biscuits',
        instructions:
        'Chop the apples.\nCook them with cinnamon and honey.\nPlace in small cups.\nAdd crushed biscuits on top.',
        cookingTime: 20,
        categoryId: 3,
        imagePath:
        'assets/images/recipes/dessert_01.jpg',
      ),

      _recipe(
        title: 'Banana Ice Cream',
        description:
        'Creamy homemade ice cream made from frozen banana.',
        ingredients:
        '2 frozen bananas\n1 tablespoon milk\nCocoa powder',
        instructions:
        'Slice and freeze the bananas.\nBlend the frozen banana with milk.\nAdd cocoa if desired.\nServe immediately.',
        cookingTime: 10,
        categoryId: 3,
        imagePath:
        'assets/images/recipes/dessert_02.jpg',
      ),

      _recipe(
        title: 'Biscuit Pudding',
        description:
        'An easy layered pudding dessert with biscuits.',
        ingredients:
        '1 package pudding\n2 cups milk\nPlain biscuits',
        instructions:
        'Cook the pudding with milk.\nPlace biscuits in a dish.\nPour pudding over the biscuits.\nCool before serving.',
        cookingTime: 15,
        categoryId: 3,
        imagePath:
        'assets/images/recipes/dessert_03.jpg',
      ),

      _recipe(
        title: 'Chocolate Mug Cake',
        description:
        'A small chocolate cake prepared quickly in a mug.',
        ingredients:
        '4 tablespoons flour\n2 tablespoons cocoa\n3 tablespoons milk\n2 tablespoons sugar\n1 tablespoon oil',
        instructions:
        'Mix all ingredients in a mug.\nStir until smooth.\nMicrowave for about ninety seconds.\nLet it cool slightly.',
        cookingTime: 8,
        categoryId: 3,
        imagePath:
        'assets/images/recipes/dessert_04.jpg',
        isFavorite: true,
      ),

      _recipe(
        title: 'Chocolate Strawberries',
        description:
        'Fresh strawberries covered with melted chocolate.',
        ingredients:
        'Strawberries\n100 grams chocolate',
        instructions:
        'Wash and dry the strawberries.\nMelt the chocolate.\nDip each strawberry into chocolate.\nLet them cool until firm.',
        cookingTime: 15,
        categoryId: 3,
        imagePath:
        'assets/images/recipes/dessert_05.jpg',
      ),

      _recipe(
        title: 'Easy Rice Pudding',
        description:
        'A creamy milk dessert made with rice.',
        ingredients:
        'Half cup rice\n3 cups milk\nHalf cup sugar\nVanilla',
        instructions:
        'Cook the rice until soft.\nAdd milk and sugar.\nCook while stirring until creamy.\nAdd vanilla and cool.',
        cookingTime: 30,
        categoryId: 3,
        imagePath:
        'assets/images/recipes/dessert_06.jpg',
      ),

      _recipe(
        title: 'Fruit Yogurt Parfait',
        description:
        'Layers of yogurt, fruit and crunchy biscuits.',
        ingredients:
        '1 cup yogurt\nMixed fruit\nCrushed biscuits\nHoney',
        instructions:
        'Add yogurt to a glass.\nAdd fruit and crushed biscuits.\nRepeat the layers.\nFinish with honey.',
        cookingTime: 7,
        categoryId: 3,
        imagePath:
        'assets/images/recipes/dessert_07.jpg',
      ),

      // SNACK

      _recipe(
        title: 'Cheese Crackers',
        description:
        'A very quick snack with crackers and cheese.',
        ingredients:
        'Crackers\nCheese slices\nCucumber',
        instructions:
        'Place cheese on each cracker.\nAdd cucumber slices.\nServe immediately.',
        cookingTime: 5,
        categoryId: 4,
        imagePath:
        'assets/images/recipes/snack_01.jpg',
      ),

      _recipe(
        title: 'Fruit Skewers',
        description:
        'Colorful fresh fruit served on small skewers.',
        ingredients:
        'Banana\nStrawberries\nApple\nGrapes',
        instructions:
        'Wash all fruit.\nCut larger fruit into pieces.\nPlace fruit on skewers.\nServe chilled.',
        cookingTime: 10,
        categoryId: 4,
        imagePath:
        'assets/images/recipes/snack_02.jpg',
      ),

      _recipe(
        title: 'Homemade Popcorn',
        description:
        'Classic warm popcorn prepared in a pot.',
        ingredients:
        'Half cup popcorn kernels\n1 tablespoon oil\nSalt',
        instructions:
        'Heat oil in a pot.\nAdd popcorn kernels.\nCover and shake occasionally.\nAdd salt after popping.',
        cookingTime: 7,
        categoryId: 4,
        imagePath:
        'assets/images/recipes/snack_03.jpg',
        isFavorite: true,
      ),

      _recipe(
        title: 'Hummus Toast',
        description:
        'Crispy toast topped with creamy hummus.',
        ingredients:
        '2 slices of bread\nHummus\nTomato\nBlack pepper',
        instructions:
        'Toast the bread.\nSpread hummus over it.\nAdd tomato slices.\nSprinkle with black pepper.',
        cookingTime: 8,
        categoryId: 4,
        imagePath:
        'assets/images/recipes/snack_04.jpg',
      ),

      _recipe(
        title: 'Mini Sandwiches',
        description:
        'Small sandwiches suitable for a quick snack.',
        ingredients:
        'Bread slices\nCheese\nTomato\nLettuce',
        instructions:
        'Place cheese, tomato and lettuce on bread.\nCover with another bread slice.\nCut into small pieces.',
        cookingTime: 10,
        categoryId: 4,
        imagePath:
        'assets/images/recipes/snack_05.jpg',
      ),

      _recipe(
        title: 'Roasted Chickpeas',
        description:
        'Crispy seasoned chickpeas baked in the oven.',
        ingredients:
        '1 cup cooked chickpeas\nOlive oil\nSalt\nPaprika',
        instructions:
        'Dry the chickpeas.\nMix with oil and seasonings.\nSpread on a baking tray.\nBake until crispy.',
        cookingTime: 25,
        categoryId: 4,
        imagePath:
        'assets/images/recipes/snack_06.jpg',
      ),

      _recipe(
        title: 'Yogurt Herb Dip',
        description:
        'A fresh yogurt dip served with vegetables.',
        ingredients:
        '1 cup yogurt\nMint\nSalt\nCucumber sticks',
        instructions:
        'Mix yogurt, mint and salt.\nPrepare cucumber sticks.\nServe the dip in a small bowl.',
        cookingTime: 8,
        categoryId: 4,
        imagePath:
        'assets/images/recipes/snack_07.jpg',
      ),

      // DRINK

      _recipe(
        title: 'Banana Smoothie',
        description:
        'A refreshing smoothie with banana, milk and honey.',
        ingredients:
        '1 banana\n1 glass of milk\n1 teaspoon honey',
        instructions:
        'Put all ingredients into a blender.\nBlend until smooth.\nPour into a glass.\nServe immediately.',
        cookingTime: 5,
        categoryId: 5,
        imagePath:
        'assets/images/recipes/drink_01.jpg',
      ),

      _recipe(
        title: 'Easy Iced Coffee',
        description:
        'A quick cold coffee prepared with milk and ice.',
        ingredients:
        '1 teaspoon instant coffee\nMilk\nCold water\nIce',
        instructions:
        'Dissolve coffee in a little water.\nAdd milk and cold water.\nAdd ice.\nMix and serve.',
        cookingTime: 5,
        categoryId: 5,
        imagePath:
        'assets/images/recipes/drink_02.jpg',
      ),

      _recipe(
        title: 'Fresh Lemonade',
        description:
        'A cold homemade lemonade for warm days.',
        ingredients:
        '2 lemons\n3 cups water\nSugar\nIce',
        instructions:
        'Squeeze the lemons.\nMix lemon juice with water and sugar.\nAdd ice.\nServe cold.',
        cookingTime: 10,
        categoryId: 5,
        imagePath:
        'assets/images/recipes/drink_03.jpg',
      ),

      _recipe(
        title: 'Hot Chocolate',
        description:
        'A warm chocolate drink made with milk.',
        ingredients:
        '1 cup milk\n1 tablespoon cocoa\n1 teaspoon sugar\nChocolate',
        instructions:
        'Heat the milk.\nAdd cocoa and sugar.\nStir until smooth.\nAdd a small piece of chocolate.',
        cookingTime: 10,
        categoryId: 5,
        imagePath:
        'assets/images/recipes/drink_04.jpg',
      ),

      _recipe(
        title: 'Mint Ayran',
        description:
        'A cold yogurt drink flavored with fresh mint.',
        ingredients:
        '1 cup yogurt\n1 cup cold water\nSalt\nMint',
        instructions:
        'Add yogurt and water to a bowl.\nWhisk until smooth.\nAdd salt and mint.\nServe cold.',
        cookingTime: 5,
        categoryId: 5,
        imagePath:
        'assets/images/recipes/drink_05.jpg',
      ),

      _recipe(
        title: 'Orange Ginger Drink',
        description:
        'A fresh orange drink with a mild ginger flavor.',
        ingredients:
        '2 oranges\nSmall piece of ginger\nHoney\nIce',
        instructions:
        'Squeeze the oranges.\nGrate a small amount of ginger.\nMix with honey.\nAdd ice and serve.',
        cookingTime: 8,
        categoryId: 5,
        imagePath:
        'assets/images/recipes/drink_06.jpg',
      ),

      _recipe(
        title: 'Strawberry Smoothie',
        description:
        'A sweet and creamy strawberry drink.',
        ingredients:
        'Strawberries\n1 glass of milk\n1 teaspoon honey\nIce',
        instructions:
        'Wash the strawberries.\nAdd all ingredients to a blender.\nBlend until smooth.\nServe cold.',
        cookingTime: 5,
        categoryId: 5,
        imagePath:
        'assets/images/recipes/drink_07.jpg',
        isFavorite: true,
      ),
    ];

    for (final recipe in recipes) {
      final List<Map<String, Object?>> existingRecipe =
      await database.query(
        'recipes',
        columns: ['id'],
        where: 'title = ?',
        whereArgs: [recipe['title']],
        limit: 1,
      );

      if (existingRecipe.isEmpty) {
        await database.insert(
          'recipes',
          recipe,
        );
      }
    }
  }

  Future<void> _fixRecipeImagePaths(
      Database database,
      ) async {
    final Map<String, String> imagePaths = {
      'Avocado Toast':
      'assets/images/recipes/breakfast_01.jpg',
      'Banana Oatmeal':
      'assets/images/recipes/breakfast_02.jpg',
      'Cheese Omelette':
      'assets/images/recipes/breakfast_03.jpg',
      'Easy Pancakes':
      'assets/images/recipes/breakfast_04.jpg',
      'Egg Sandwich':
      'assets/images/recipes/breakfast_05.jpg',
      'Peanut Butter Toast':
      'assets/images/recipes/breakfast_06.jpg',
      'Yogurt Fruit Bowl':
      'assets/images/recipes/breakfast_07.jpg',

      'Baked Potatoes':
      'assets/images/recipes/main_course_01.jpg',
      'Chicken Rice Bowl':
      'assets/images/recipes/main_course_02.jpg',
      'Chicken Wrap':
      'assets/images/recipes/main_course_03.jpg',
      'Easy Lentil Soup':
      'assets/images/recipes/main_course_04.jpg',
      'Tomato Pasta':
      'assets/images/recipes/main_course_05.jpg',
      'Tuna Pasta Salad':
      'assets/images/recipes/main_course_06.jpg',
      'Vegetable Stir Fry':
      'assets/images/recipes/main_course_07.jpg',

      'Apple Cinnamon Cups':
      'assets/images/recipes/dessert_01.jpg',
      'Banana Ice Cream':
      'assets/images/recipes/dessert_02.jpg',
      'Biscuit Pudding':
      'assets/images/recipes/dessert_03.jpg',
      'Chocolate Mug Cake':
      'assets/images/recipes/dessert_04.jpg',
      'Chocolate Strawberries':
      'assets/images/recipes/dessert_05.jpg',
      'Easy Rice Pudding':
      'assets/images/recipes/dessert_06.jpg',
      'Fruit Yogurt Parfait':
      'assets/images/recipes/dessert_07.jpg',

      'Cheese Crackers':
      'assets/images/recipes/snack_01.jpg',
      'Fruit Skewers':
      'assets/images/recipes/snack_02.jpg',
      'Homemade Popcorn':
      'assets/images/recipes/snack_03.jpg',
      'Hummus Toast':
      'assets/images/recipes/snack_04.jpg',
      'Mini Sandwiches':
      'assets/images/recipes/snack_05.jpg',
      'Roasted Chickpeas':
      'assets/images/recipes/snack_06.jpg',
      'Yogurt Herb Dip':
      'assets/images/recipes/snack_07.jpg',

      'Banana Smoothie':
      'assets/images/recipes/drink_01.jpg',
      'Easy Iced Coffee':
      'assets/images/recipes/drink_02.jpg',
      'Fresh Lemonade':
      'assets/images/recipes/drink_03.jpg',
      'Hot Chocolate':
      'assets/images/recipes/drink_04.jpg',
      'Mint Ayran':
      'assets/images/recipes/drink_05.jpg',
      'Orange Ginger Drink':
      'assets/images/recipes/drink_06.jpg',
      'Strawberry Smoothie':
      'assets/images/recipes/drink_07.jpg',
    };

    final Batch batch = database.batch();

    for (final entry in imagePaths.entries) {
      batch.update(
        'recipes',
        {
          'imagePath': entry.value,
        },
        where: 'title = ?',
        whereArgs: [entry.key],
      );
    }

    await batch.commit(
      noResult: true,
    );
  }

  Future<void> closeDatabase() async {
    final Database database =
    await this.database;

    await database.close();
    _database = null;
  }
}