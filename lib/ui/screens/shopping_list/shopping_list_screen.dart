import 'package:flutter/material.dart';

import '../../../business/shopping_item_service.dart';
import '../../../data/models/shopping_item.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() {
    return _ShoppingListScreenState();
  }
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingItemService _shoppingItemService =
  ShoppingItemService();

  final TextEditingController _itemController =
  TextEditingController();

  List<ShoppingItem> _items = [];

  bool _isLoading = true;
  bool _isAdding = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final List<ShoppingItem> items =
      await _shoppingItemService.getAllItems();

      if (!mounted) return;

      setState(() {
        _items = items;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Shopping list could not be loaded.';
      });
    }
  }

  Future<void> _addItem() async {
    final String itemName = _itemController.text.trim();

    if (itemName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter an item name.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      final ShoppingItem item = ShoppingItem(
        name: itemName,
      );

      await _shoppingItemService.addItem(item);

      _itemController.clear();

      await _loadItems();

      if (!mounted) return;

      setState(() {
        _isAdding = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isAdding = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Item could not be added.',
          ),
        ),
      );
    }
  }

  Future<void> _toggleItem(
      ShoppingItem item,
      bool? value,
      ) async {
    if (item.id == null || value == null) return;

    try {
      await _shoppingItemService.updateChecked(
        item.id!,
        value,
      );

      await _loadItems();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Item status could not be updated.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteItem(
      ShoppingItem item,
      ) async {
    if (item.id == null) return;

    try {
      await _shoppingItemService.deleteItem(
        item.id!,
      );

      await _loadItems();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Item could not be deleted.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteCheckedItems() async {
    final bool hasCheckedItems = _items.any(
          (item) => item.isChecked,
    );

    if (!hasCheckedItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'There are no completed items.',
          ),
        ),
      );

      return;
    }

    await _shoppingItemService.deleteCheckedItems();
    await _loadItems();
  }

  Future<void> _deleteAllItems() async {
    if (_items.isEmpty) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear Shopping List'),
          content: const Text(
            'Are you sure you want to delete all items?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _shoppingItemService.deleteAllItems();
    await _loadItems();
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int completedCount = _items.where((item) {
      return item.isChecked;
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_checked') {
                _deleteCheckedItems();
              } else if (value == 'delete_all') {
                _deleteAllItems();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'delete_checked',
                  child: Text(
                    'Delete completed items',
                  ),
                ),
                PopupMenuItem(
                  value: 'delete_all',
                  child: Text(
                    'Delete all items',
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      _addItem();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Add shopping item',
                      hintText: 'Example: Milk',
                      prefixIcon: Icon(
                        Icons.shopping_cart_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _isAdding
                      ? null
                      : _addItem,
                  icon: _isAdding
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.add),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Text(
                  '${_items.length} item(s)',
                ),
                const Spacer(),
                Text(
                  '$completedCount completed',
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadItems,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 70,
            ),
            SizedBox(height: 12),
            Text(
              'Your shopping list is empty.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadItems,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          bottom: 24,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final ShoppingItem item = _items[index];

          return Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(
                right: 24,
              ),
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) {
              _deleteItem(item);
            },
            child: CheckboxListTile(
              value: item.isChecked,
              onChanged: (value) {
                _toggleItem(item, value);
              },
              title: Text(
                item.name,
                style: TextStyle(
                  decoration: item.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              secondary: IconButton(
                onPressed: () {
                  _deleteItem(item);
                },
                icon: const Icon(
                  Icons.delete_outline,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}