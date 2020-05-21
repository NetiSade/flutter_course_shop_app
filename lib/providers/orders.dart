import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cours_4/models/http_exception.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as Constants;
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var dateTime = DateTime.now();

    try {
      final res = await http.post(Constants.OrdersUrl + '.json',
          body: json.encode({
            'amount': total,
            'dateTime': dateTime.toIso8601String(),
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'price': cp.price,
                      'quantity': cp.quantity
                    })
                .toList()
          }));
      _orders.insert(
          0,
          OrderItem(
              id: json.decode(res.body)['name'],
              products: cartProducts,
              dateTime: DateTime.now(),
              amount: total));

      notifyListeners();
    } catch (e) {
      print('addOrder failed!');
      throw HttpExeption('http.post failed!');
    }
  }

  Future<void> fetchAndSetOrders() async {
    final List<OrderItem> loadedItems = [];
    try {
      final res = await http.get(Constants.OrdersUrl + '.json');
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((orderId, orderData) {
        loadedItems.add(
          OrderItem(
              id: orderId,
              amount: orderData['amount'],
              dateTime: DateTime.parse(orderData['dateTime']),
              products: (orderData['products'] as List<dynamic>)
                  .map((p) => CartItem(
                      id: p['id'],
                      title: p['title'],
                      price: p['price'],
                      quantity: p['quantity']))
                  .toList()),
        );
      });
    } catch (e) {}
    _orders = loadedItems.reversed;
    notifyListeners();
  }
}
