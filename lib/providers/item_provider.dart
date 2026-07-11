import 'package:flutter/material.dart';
import '../data/models/item_model.dart';
import '../data/services/item_service.dart';

class ItemProvider extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  List<Item> _items = [];
  bool isLoading = false;
  String? errorMessage;

  List<Item> get items => _items;

  List<Item> get forSaleItems =>
      _items.where((item) => !item.isForDisassemble).toList();

  List<Item> get forDisassembleItems =>
      _items.where((item) => item.isForDisassemble).toList();

  Future<void> fetchItems() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _items = await _itemService.fetchItems();
    } catch (e) {
      errorMessage = e is ItemServiceException
          ? e.message
          : 'Terjadi kesalahan saat memuat data.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => fetchItems();

  Item? getById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addItem(Item item) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final created = await _itemService.createItem(item);
      _items.insert(0, created); // newest listing shows first
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e is ItemServiceException
          ? e.message
          : 'Gagal menambahkan barang.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItemDetails(Item updatedItem) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final saved = await _itemService.updateItem(updatedItem);
      final index = _items.indexWhere((i) => i.id == saved.id);
      if (index != -1) _items[index] = saved;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e is ItemServiceException
          ? e.message
          : 'Gagal menyimpan perubahan.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Removes an item from the catalog entirely — called when a purchase
  /// completes, since a bought item is no longer part of the public listing.
  /// Returns true on success (even if the local list didn't have it, since
  /// the API deletion is the source of truth).
  Future<bool> deleteItem(String id) async {
    try {
      await _itemService.deleteItem(id);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e is ItemServiceException
          ? e.message
          : 'Gagal menghapus barang dari katalog.';
      notifyListeners();
      return false;
    }
  }
}