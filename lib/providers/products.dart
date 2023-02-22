import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';
import '../model/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String authToken;

  Products(this.authToken, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future fetchProducts() async {
    final url = Uri.parse('https://flutter-udemy-df306-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map;
      final List<Product> loadedProducts = [];
      data.forEach((key, item) {
        loadedProducts.add(Product(
          id: key,
          title: item['title'],
          description: item['description'],
          imageUrl: item['imageUrl'],
          isFavorite: item['isFavorite'],
          price: item['price'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future addProduct(Product product) async {
    final url = Uri.parse('https://flutter-udemy-df306-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(url, body: json.encode(product));
      final newProduct = Product(id: json.decode(response.body)['name'],
          title: product.title, description: product.description,
          price: product.price, imageUrl: product.imageUrl);

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future updateProduct(String id, Product product) async {
    final index = _items.indexWhere((prod) => prod.id == id);
    if (index >= 0) {
      final url = Uri.parse('https://flutter-udemy-df306-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      product.isFavorite = false;
      try {
        await http.patch(url, body: json.encode(product));
        _items[index] = product;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future deleteProduct(String id) async {
    final url = Uri.parse('https://flutter-udemy-df306-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final index = _items.indexWhere((prod) => prod.id == id);
    Product? _product = _items[index];
    _items.removeAt(index);
    notifyListeners();
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.insert(index, _product);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    _product = null;
  }
}