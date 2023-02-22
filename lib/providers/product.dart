import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false
  });

  void _setFavoriteValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future toggleFavoriteState(String token) async {
    final oldStatus = isFavorite;
    _setFavoriteValue(!isFavorite);
    try {
      final url = Uri.parse('https://flutter-udemy-df306-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
      final res = await http.patch(url, body: json.encode({
        'isFavorite': isFavorite
      }));
      if (res.statusCode >= 400) {
        _setFavoriteValue(oldStatus);
      }
    } catch (error) {
      _setFavoriteValue(oldStatus);
      throw error;
    }

  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'price': price,
    'isFavorite': isFavorite,
  };
}