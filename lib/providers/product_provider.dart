// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'dart:io'; // For File
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductProvider with ChangeNotifier {
  Product? _currentProduct;
  List<Product> _recommendations = [];
  String _aiSuggestions = ''; // Store AI text suggestions
  List<Product> _products = []; // Cache all products
  bool _isLoading = false;
  final ApiService _apiService = ApiService();



  Product? get currentProduct => _currentProduct;
  List<Product> get recommendations => _recommendations;
  String get aiSuggestions => _aiSuggestions;
  bool get isLoading => _isLoading;

  Future<void> fetchAllProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _apiService.getProducts();
    } catch (e) {
      print('Error fetching all products: $e');
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
      print('Error fetching product: $e');
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
      print('Error fetching product by code: $e');
      _currentProduct = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecommendations(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getRecommendations(id);
      _recommendations = (response['dbRecommendations'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
      _aiSuggestions =
          response['aiSuggestions'] ?? 'No AI suggestions available';
    } catch (e) {
      print('Error fetching recommendations: $e');
      _recommendations = [];
      _aiSuggestions = '';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBudgetRecommendations(double budget, String type) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getBudgetRecommendations(budget, type);
      print('API response for $type: $response');
      _recommendations = (response['dbRecommendations'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
      _aiSuggestions =
          response['aiSuggestions'] ?? 'No AI suggestions available';
    } catch (e) {
      print('Error fetching budget recommendations: $e');
      _recommendations = [];
      _aiSuggestions = '';
    }
    _isLoading = false;
    notifyListeners();
  }

  // New: Fetch recommendations from image using backend API
  Future<void> fetchFromImage(File image) async {
    _isLoading = true;
    notifyListeners();
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${Constants.baseUrl}/products/recognize-image'));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String detectedCategory = data['detectedCategory'];
        _recommendations = (data['recommendations'] as List).map((json) => Product.fromJson(json)).toList();
        print('Detected category: $detectedCategory');
      } else {
        print('Backend error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in image recognition: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
