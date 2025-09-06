import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';

import '../utils/constants.dart';

class ApiService {
  final String baseUrl = Constants.baseUrl;

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<Product> getProductById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  Future<Product> getProductByCode(String code) async {
    final encodedCode = Uri.encodeComponent(code);
    final response = await http.get(Uri.parse('$baseUrl/products?code=$encodedCode')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return Product.fromJson(data[0]);
      }
      throw Exception('Product not found');
    } else {
      throw Exception('Failed to load product by code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getRecommendations(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id/recommendations'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recommendations: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getBudgetRecommendations(double budget, String types) async {
    final response = await http.get(Uri.parse('$baseUrl/products/budget?budget=$budget&types=$types'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load budget recommendations: ${response.statusCode}');
    }
  }

  Future<bool> testImageUrl(String imageUrl) async {
    try {
      final response = await http.head(Uri.parse(imageUrl));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}