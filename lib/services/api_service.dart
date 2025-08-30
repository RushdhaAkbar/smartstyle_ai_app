import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/constants.dart';

abstract class ApiRepository {
  Future<Product> getProductById(String id);
  Future<List<Product>> getRecommendations(String query);
}

class ApiService implements ApiRepository {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final bool _useMock = true; // Set to false later for real backend

  @override
  Future<Product> getProductById(String id) async {
    if (_useMock) {
      // Sample mock data
      return Product.fromJson({
        '_id': id,
        'name': 'Test Shirt',
        'sizes': ['S', 'M'],
        'colors': ['Green', 'Yellow'],
        'price': 19.99,
        'stock': 100,
        'availability': true,
        'description': 'Test description',
        'image': 'https://test.com/image.png',
        'qrCode': 'QR-TEST-789',
        'barcode': 'BAR-012345',
      });
    } else {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/products/$id'));
      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load product');
      }
    }
  }

  @override
  Future<List<Product>> getRecommendations(String query) async {
    if (_useMock) {
      // Sample mock list
      return [
        Product.fromJson({'name': 'Recommended Item 1', 'price': 15.0 /* ... other fields */}),
        Product.fromJson({'name': 'Recommended Item 2', 'price': 25.0 /* ... */}),
      ];
    } else {
      // Real AI call with sample prompt "recommend similar to t-shirt under $30"
      throw UnimplementedError('Real AI call not implemented yet');
    }
  }
}