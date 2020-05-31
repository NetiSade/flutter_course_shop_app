import 'dart:convert';
import 'package:flutter/widgets.dart';
import '../models/http_exception.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import '../constants.dart' as Constants;

class Products with ChangeNotifier {
  final String authToken;
  final String userId;
  String urlSuffix;

  Products(this.authToken, this.userId, this._items) {
    urlSuffix = '.json?auth=$authToken';
  }

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  Product findById(String productId) {
    return _items.firstWhere((prod) => prod.id == productId);
  }

  List<Product> get favoriteItems {
    return _items.where((i) => i.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filteredByUser = false]) async {
    try {
      final filterString =
          filteredByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
      final response =
          await http.get(Constants.ProductsUrl + '$urlSuffix$filterString');
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      if (extractedData == null) {
        return;
      }

      final favoriteResponce =
          await http.get(Constants.UserFavoritesUrl + '/$userId' + urlSuffix);

      final favoriteData = json.decode(favoriteResponce.body);

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
              id: prodId,
              title: prodData['title'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              description: prodData['description'],
              isFavorite:
                  favoriteData == null ? false : favoriteData[prodId] ?? false),
        );
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(Constants.ProductsUrl + urlSuffix,
          body: json.encode({
            'price': product.price,
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'creatorId': userId
          }));

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Constants.ProductsUrl + '/$id' + urlSuffix;
      await http.patch(url,
          body: json.encode({
            'price': product.price,
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl
          }));
      _items[prodIndex] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Constants.ProductsUrl + '/$id' + urlSuffix;
    final existingProductIndex = _items.indexWhere((item) => item.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    try {
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        throw HttpExeption('Could not delete product.');
      }
      existingProduct = null;
    } catch (error) {
      print(error);
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw (error);
    }
  }
}
