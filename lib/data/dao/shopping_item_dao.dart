import '../database/database_helper.dart';
import '../models/shopping_item.dart';

abstract class ShoppingItemDao {
  Future<List<ShoppingItem>> getAllItems();

  Future<int> insertItem(ShoppingItem item);

  Future<void> insertItems(List<ShoppingItem> items);

  Future<int> updateChecked(
      int id,
      bool isChecked,
      );

  Future<int> deleteItem(int id);

  Future<int> deleteCheckedItems();

  Future<int> deleteAllItems();
}

class ShoppingItemDaoImpl implements ShoppingItemDao {
  final DatabaseHelper databaseHelper;

  ShoppingItemDaoImpl({
    DatabaseHelper? databaseHelper,
  }) : databaseHelper =
      databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<ShoppingItem>> getAllItems() async {
    final database = await databaseHelper.database;

    final List<Map<String, Object?>> maps =
    await database.query(
      'shopping_items',
      orderBy: 'isChecked ASC, id DESC',
    );

    return maps.map((map) {
      return ShoppingItem.fromMap(
        Map<String, dynamic>.from(map),
      );
    }).toList();
  }

  @override
  Future<int> insertItem(ShoppingItem item) async {
    final database = await databaseHelper.database;

    final Map<String, dynamic> map = item.toMap();
    map.remove('id');

    return database.insert(
      'shopping_items',
      map,
    );
  }

  @override
  Future<void> insertItems(
      List<ShoppingItem> items,
      ) async {
    final database = await databaseHelper.database;
    final batch = database.batch();

    for (final item in items) {
      final Map<String, dynamic> map = item.toMap();
      map.remove('id');

      batch.insert(
        'shopping_items',
        map,
      );
    }

    await batch.commit(
      noResult: true,
    );
  }

  @override
  Future<int> updateChecked(
      int id,
      bool isChecked,
      ) async {
    final database = await databaseHelper.database;

    return database.update(
      'shopping_items',
      {
        'isChecked': isChecked ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> deleteItem(int id) async {
    final database = await databaseHelper.database;

    return database.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> deleteCheckedItems() async {
    final database = await databaseHelper.database;

    return database.delete(
      'shopping_items',
      where: 'isChecked = ?',
      whereArgs: [1],
    );
  }

  @override
  Future<int> deleteAllItems() async {
    final database = await databaseHelper.database;

    return database.delete(
      'shopping_items',
    );
  }
}