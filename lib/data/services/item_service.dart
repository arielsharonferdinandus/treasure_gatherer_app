import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';

class ItemService {
  static const String _baseUrl =
      'https://6a4f83c1f45d5352b6118a00.mockapi.io/api/items';

  /// Fetches items from API.
  Future<List<Item>> fetchItems() async {
    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Item.fromJson(json)).toList();
      } else {
        throw ItemServiceException(
          'Gagal memuat data barang (status ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is ItemServiceException) rethrow;
      throw ItemServiceException('Tidak dapat terhubung ke server: $e');
    }
  }

  Future<Item> createItem(Item item) async {
    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Item.fromJson(jsonDecode(response.body));
      } else {
        throw ItemServiceException(
          'Gagal mendaftarkan barang (status ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is ItemServiceException) rethrow;
      throw ItemServiceException('Tidak dapat terhubung ke server: $e');
    }
  }

  Future<Item> updateItem(Item item) async {
    final uri = Uri.parse('$_baseUrl/${item.id}');

    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200) {
        return Item.fromJson(jsonDecode(response.body));
      } else {
        throw ItemServiceException(
          'Gagal memperbarui barang (status ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is ItemServiceException) rethrow;
      throw ItemServiceException('Tidak dapat terhubung ke server: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    final uri = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.delete(uri);
      if (response.statusCode != 200) {
        throw ItemServiceException(
          'Gagal menghapus barang (status ${response.statusCode})',
        );
      }
    } catch (e) {
      if (e is ItemServiceException) rethrow;
      throw ItemServiceException('Tidak dapat terhubung ke server: $e');
    }
  }
}

class ItemServiceException implements Exception {
  final String message;
  ItemServiceException(this.message);

  @override
  String toString() => message;
}