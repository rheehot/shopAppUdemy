import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phicos_mart/models/http_exception.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class ProductsListProvider with ChangeNotifier {
  List<Product> _items = [
//    Product(
//      id: 'p1',
//      title: 'Red Shirt',
//      description: 'A red shirt - it is pretty red!',
//      price: 29.99,
//      imageUrl:
//          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
//    ),
//    Product(
//      id: 'p2',
//      title: 'Trousers',
//      description: 'A nice pair of trousers.',
//      price: 59.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
//    ),
//    Product(
//      id: 'p3',
//      title: 'Yellow Scarf',
//      description: 'Warm and cozy - exactly what you need for the winter.',
//      price: 19.99,
//      imageUrl:
//          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
//    ),
//    Product(
//      id: 'p4',
//      title: 'A Pan',
//      description: 'Prepare any meal you want.',
//      price: 49.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
//    ),
  ];

  Product findById(String id) {
    return _items.firstWhere(
      (prod) => prod.id == id,
    );
  }

//  var _showFavoritesOnly = false;
  List<Product> get items {
//    if (_showFavoritesOnly) {
//      return _items.where((prodItem) => prodItem.isFavorite).toList();
//    }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

//  void showFavoritesOnly() {
//    _showFavoritesOnly = true;
//    notifyListeners();
//  }

//  void showAll() {
//    _showFavoritesOnly = false;
//    notifyListeners();
//  }
  Future<void> fetchAndSetProducts() async {
    const url = 'https://scannen-apps.firebaseio.com/phicosmart/products.json';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProduct = [];
      print(response.body);
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            isFavorite: prodData['isFavorite']));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) {
    // todo: ini di errorkan
    const url = 'https://scannen-apps.firebaseio.com/phicosmart/products.json';
    return http
        .post(url,
            body: jsonEncode({
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price,
              'isFavorite': product.isFavorite,
            }))
        .then((response) {
      print(jsonDecode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        id: jsonDecode(response.body)['nama'],
      );
//    _items.add(value);
//    _items.add(newProduc);
      _items.insert(0, newProduct);
      notifyListeners();
    }).catchError((error) {
      print(error);
      throw error;
    });
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://scannen-apps.firebaseio.com/phicosmart/products/$id.json';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));

      //
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) {
    final url = 'https://scannen-apps.firebaseio.com/phicosmart/products/$id';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Tidak dapat menhhapus product');
      }
      existingProduct = null;
    }).catchError((_) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
    });
  }
}
