import '../dao/shopping_item_dao.dart';
import '../models/shopping_item.dart';

class ShoppingItemRepository {
  final ShoppingItemDao shoppingItemDao;

  ShoppingItemRepository({
    ShoppingItemDao? shoppingItemDao,
  }) : shoppingItemDao =
      shoppingItemDao ?? ShoppingItemDaoImpl();

  Future<List<ShoppingItem>> getAllItems() {
    return shoppingItemDao.getAllItems();
  }

  Future<int> addItem(ShoppingItem item) {
    return shoppingItemDao.insertItem(item);
  }

  Future<void> addItems(List<ShoppingItem> items) {
    return shoppingItemDao.insertItems(items);
  }

  Future<int> updateChecked(
      int id,
      bool isChecked,
      ) {
    return shoppingItemDao.updateChecked(
      id,
      isChecked,
    );
  }

  Future<int> deleteItem(int id) {
    return shoppingItemDao.deleteItem(id);
  }

  Future<int> deleteCheckedItems() {
    return shoppingItemDao.deleteCheckedItems();
  }

  Future<int> deleteAllItems() {
    return shoppingItemDao.deleteAllItems();
  }
}