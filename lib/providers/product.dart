import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as Constants;

class Product with ChangeNotifier {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isFavorite;

  Product(
      {this.id,
      this.title,
      this.description,
      this.price,
      this.imageUrl,
      this.isFavorite = false});

  void _setFavVal(bool val) {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  void toggleFavoriteState(String token, String userId) async {
    final url = Constants.UserFavoritesUrl + '/$userId/$id.json?auth=$token';
    _setFavVal(!isFavorite);

    try {
      var res = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (res.statusCode >= 400) {
        throw HttpExeption('Failed http patch error code: ${res.statusCode}');
      }
    } catch (e) {
      print(e);
      _setFavVal(!isFavorite);
    }
  }
}
