import '../data/models/shopping_item.dart';
import '../data/repositories/shopping_item_repository.dart';

class ShoppingItemService {
  final ShoppingItemRepository repository;

  ShoppingItemService({
    ShoppingItemRepository? repository,
  }) : repository =
      repository ?? ShoppingItemRepository();

  Future<List<ShoppingItem>> getAllItems() {
    return repository.getAllItems();
  }

  Future<int> addItem(ShoppingItem item) {
    _validateItem(item);

    return repository.addItem(item);
  }

  Future<void> addItems(
      List<ShoppingItem> items,
      ) {
    final validItems = items.where((item) {
      return item.name.trim().isNotEmpty;
    }).toList();

    if (validItems.isEmpty) {
      throw ArgumentError(
        'Shopping list items cannot be empty.',
      );
    }

    return repository.addItems(validItems);
  }

  Future<int> updateChecked(
      int id,
      bool isChecked,
      ) {
    if (id <= 0) {
      throw ArgumentError(
        'Shopping item id must be greater than zero.',
      );
    }

    return repository.updateChecked(
      id,
      isChecked,
    );
  }

  Future<int> deleteItem(int id) {
    if (id <= 0) {
      throw ArgumentError(
        'Shopping item id must be greater than zero.',
      );
    }

    return repository.deleteItem(id);
  }

  Future<int> deleteCheckedItems() {
    return repository.deleteCheckedItems();
  }

  Future<int> deleteAllItems() {
    return repository.deleteAllItems();
  }

  void _validateItem(ShoppingItem item) {
    if (item.name.trim().isEmpty) {
      throw ArgumentError(
        'Shopping item name cannot be empty.',
      );
    }
  }
}