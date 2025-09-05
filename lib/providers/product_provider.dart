// lib/providers/product_provider.dart (updated for budget combinations)
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  Product? _currentProduct;
  List<Product> _recommendations = [];
  bool _isLoading = false;
  final List<Product> _sampleProducts = [
    Product(
      id: "1",
      name: "Blue Skirt",
      sizes: ["M", "L"],
      colors: ["Blue"],
      price: 400.0,
      stock: 50,
      availability: true,
      description: "Comfortable blue skirt",
      image: "https://example.com/blue-skirt.jpg",
      qrCode: "QR-BLUE-SKIRT-1693746000000",
      barcode: "1693746000000123",
    ),
    Product(
      id: "2",
      name: "Red Skirt",
      sizes: ["S", "M"],
      colors: ["Red"],
      price: 500.0,
      stock: 30,
      availability: true,
      description: "Vibrant red skirt",
      image: "https://example.com/red-skirt.jpg",
      qrCode: "QR-RED-SKIRT-1693746000001",
      barcode: "1693746000000456",
    ),
    Product(
      id: "3",
      name: "Green Blouse",
      sizes: ["L", "XL"],
      colors: ["Green"],
      price: 200.0,
      stock: 20,
      availability: true,
      description: "Elegant green blouse",
      image: "https://example.com/green-blouse.jpg",
      qrCode: "QR-GREEN-BLOUSE-1693746000002",
      barcode: "1693746000000789",
    ),
    Product(
      id: "4",
      name: "Yellow Blouse",
      sizes: ["M", "L"],
      colors: ["Yellow"],
      price: 800.0,
      stock: 15,
      availability: true,
      description: "Bright yellow blouse",
      image: "https://example.com/yellow-blouse.jpg",
      qrCode: "QR-YELLOW-BLOUSE-1693746000003",
      barcode: "1693746000000111",
    ),
  ];

  Product? get currentProduct => _currentProduct;
  List<Product> get recommendations => _recommendations;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  Future<void> fetchProduct(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentProduct = _sampleProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      print('Error fetching product: $e');
      _currentProduct = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecommendations(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final currentProduct = _sampleProducts.firstWhere((p) => p.id == id);
      _recommendations = _sampleProducts.where((p) {
        return p.id != id && // Exclude current product
               p.price >= currentProduct.price - 5 &&
               p.price <= currentProduct.price + 5 &&
               p.availability; // Only available products
      }).toList();
      print('Exchange Recommendations: ${_recommendations.map((p) => p.name).join(', ')}');
    } catch (e) {
      print('Error fetching exchange recommendations: $e');
      _recommendations = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBudgetRecommendations(double budget, String type) async {
    _isLoading = true;
    notifyListeners();
    try {
      final types = type.toLowerCase().split(' and '); // Split types if multiple (e.g., 'skirt and blouse')
      _recommendations = [];
      for (var t in types) {
        final matches = _sampleProducts.where((p) {
          return p.name.toLowerCase().contains(t.trim()) && p.price <= budget && p.availability;
        }).toList();
        _recommendations.addAll(matches);
      }
      print('Budget Recommendations: ${_recommendations.map((p) => p.name).join(', ')}');
    } catch (e) {
      print('Error fetching budget recommendations: $e');
      _recommendations = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}