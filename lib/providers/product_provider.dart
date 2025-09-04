// lib/providers/product_provider.dart (updated)
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
      name: "Blue T-Shirt",
      sizes: ["M", "L"],
      colors: ["Blue"],
      price: 19.99,
      stock: 50,
      availability: true,
      description: "Comfortable blue cotton t-shirt",
      image: "https://example.com/blue-tshirt.jpg",
      qrCode: "QR-BLUE-TSHIRT-1693746000000",
      barcode: "1693746000000123",
    ),
    Product(
      id: "2",
      name: "Red T-Shirt",
      sizes: ["S", "M"],
      colors: ["Red"],
      price: 18.99,
      stock: 30,
      availability: true,
      description: "Vibrant red cotton t-shirt",
      image: "https://example.com/red-tshirt.jpg",
      qrCode: "QR-RED-TSHIRT-1693746000001",
      barcode: "1693746000000456",
    ),
    Product(
      id: "3",
      name: "Green Hoodie",
      sizes: ["L", "XL"],
      colors: ["Green"],
      price: 29.99,
      stock: 20,
      availability: false,
      description: "Warm green hoodie",
      image: "https://example.com/green-hoodie.jpg",
      qrCode: "QR-GREEN-HOODIE-1693746000002",
      barcode: "1693746000000789",
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
      _currentProduct = _sampleProducts.firstWhere((p) => p.id == id, orElse: () => Product(
        id: '',
        name: '',
        sizes: [],
        colors: [],
        price: 0.0,
        stock: 0,
        availability: false,
        description: '',
        image: '',
        qrCode: '',
        barcode: '',
      ));
      if (_currentProduct!.id == '') {
        _currentProduct = null;
      }
    } catch (e) {
      print('Error fetching product: \$e');
      _currentProduct = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecommendations(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Mock AI recommendation based on current product ID
      final currentProduct = _sampleProducts.firstWhere((p) => p.id == id, orElse: () => Product(
        id: '',
        name: '',
        sizes: [],
        colors: [],
        price: 0.0,
        stock: 0,
        availability: false,
        description: '',
        image: '',
        qrCode: '',
        barcode: '',
      ));
      if (currentProduct.id == '') {
        _recommendations = [];
        return;
      }
      _recommendations = _sampleProducts.where((p) {
        return p.id != id && // Exclude current product
               p.price >= currentProduct.price - 5 && p.price <= currentProduct.price + 5 && // Similar price range
               p.availability; // Only available products
      }).toList();
    } catch (e) {
      print('Error fetching recommendations: \$e');
      _recommendations = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}