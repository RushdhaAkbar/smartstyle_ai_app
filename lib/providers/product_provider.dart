import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier { 
  Product? _currentProduct;
  List<Product> _recommendations = [];
  bool _isLoading = false;

  Product? get currentProduct => _currentProduct;
  List<Product> get recommendations => _recommendations;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService(); 

  Future<void> fetchProduct(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentProduct = await _apiService.getProductById(id);
    } catch (e) {
      // Handle error
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecommendations(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      _recommendations = await _apiService.getRecommendations(query);
    } catch (e) {
      // Handle error
    }
    _isLoading = false;
    notifyListeners();
  }
}