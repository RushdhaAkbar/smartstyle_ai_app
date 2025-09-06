import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../services/api_service.dart';


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
      _recommendations = (response['dbRecommendations'] as List).map((json) => Product.fromJson(json)).toList();
      _aiSuggestions = response['aiSuggestions'] ?? 'No AI suggestions available';
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
      _recommendations = (response['dbRecommendations'] as List).map((json) => Product.fromJson(json)).toList();
      _aiSuggestions = response['aiSuggestions'] ?? 'No AI suggestions available';
    } catch (e) {
      print('Error fetching budget recommendations: $e');
      _recommendations = [];
      _aiSuggestions = '';
    }
    _isLoading = false;
    notifyListeners();
  }
}