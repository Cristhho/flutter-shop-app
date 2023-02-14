import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

class Order {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  Order({
    required this.id,
    required this.amount,
    required this.products,
    required this.date,
});
}

class Orders with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  Future fetchOrders() async {
    final url = Uri.parse('https://flutter-udemy-df306-default-rtdb.firebaseio.com/orders.json');
    final res = await http.get(url);
    final data = json.decode(res.body) as Map?;
    if (data == null) return;
    final List<Order> loadedOrders = [];
    data.forEach((key, item) {
      loadedOrders.add(Order(
        id: key,
        amount: item['amount'],
        date: DateTime.parse(item['date']),
        products:  (item['products'] as List<dynamic>).map((e) =>
            CartItem(id: e['id'], price: e['price'], quantity: e['quantity'], title: e['title'])).toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future addOrder(List<CartItem> products, double total) async {
    final url = Uri.parse('https://flutter-udemy-df306-default-rtdb.firebaseio.com/orders.json');
    final date = DateTime.now();
    try {
      final res = await http.post(url, body: json.encode({
        'amount': total,
        'date': date.toIso8601String(),
        'products': products.map((e) => {
          'id': e.id,
          'title': e.title,
          'quantity': e.quantity,
          'price': e.price
        }).toList()
      }));
      _orders.insert(0, Order(id: json.decode(res.body)['name'], amount: total, products: products, date: date));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}