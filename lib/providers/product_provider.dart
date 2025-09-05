import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../services/api_service.dart';

import '../utils/constants.dart';

class ProductProvider with ChangeNotifier {
  Product? _currentProduct;
  List<Product> _recommendations = [];
  List<Product> _products = []; // Cache all products
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Product? get currentProduct => _currentProduct;
  List<Product> get recommendations => _recommendations;
  bool get isLoading => _isLoading;

  Future<void> fetchAllProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _apiService.getProducts();
    } catch (e) {
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProduct(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentProduct = await _apiService.getProductById(id);
    } catch (e) {
      _currentProduct = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProductByCode(String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentProduct = await _apiService.getProductByCode(code);
    } catch (e) {
      _currentProduct = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecommendations(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _recommendations = await _apiService.getRecommendations(id);
      // Optional: Use Grok API for AI enhancement
      // await _fetchGrokRecommendations(id);
    } catch (e) {
      _recommendations = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBudgetRecommendations(double budget, String type) async {
    _isLoading = true;
    notifyListeners();
    try {
      _recommendations = await _apiService.getBudgetRecommendations(budget, type);
    } catch (e) {
      _recommendations = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // Optional: Integrate Grok API for AI recommendations (e.g., for advanced suggestions)
  Future<void> _fetchGrokRecommendations(String id) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.x.ai/v1/chat/completions'), // Grok API endpoint
        headers: {
          'Authorization': 'Bearer ${Constants.xAiApiKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'grok-4',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful product recommendation assistant.'},
            {'role': 'user', 'content': 'Recommend products similar to product ID $id from our inventory.'},
          ],
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestions = data['choices'][0]['message']['content'];
        // Parse suggestions to update _recommendations (e.g., match to _products)
        // Logic to map suggestions to products
      } else {
        throw Exception('Grok API error: ${response.statusCode}');
      }
    } catch (e) {
    }
  }
}