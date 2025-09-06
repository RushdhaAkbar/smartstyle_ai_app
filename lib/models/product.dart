// lib/models/product.dart
class Variant {
  final String color;
  final String image;

  Variant({required this.color, required this.image});

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      color: json['color'] ?? '',
      image: json['image'] ?? 'https://example.com/placeholder.jpg',
    );
  }
}

class Product {
  final String id;
  final String name;
  final List<String> sizes;
  final List<Variant> variants; // Updated to use variants array
  final double price;
  final int stock;
  final bool availability;
  final String description;
  final String qrCode;
  final String barcode;
  final String categoryId; // Added to store backend categoryId
  final String subcategory;

  Product({
    required this.id,
    required this.name,
    required this.sizes,
    required this.variants,
    required this.price,
    required this.stock,
    required this.availability,
    required this.description,
    required this.qrCode,
    required this.barcode,
    required this.categoryId,
    required this.subcategory,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? 'sample_id_1',
      name: json['name'] ?? 'Sample Product',
      sizes: List<String>.from(json['sizes'] ?? ['M', 'L']),
      variants: (json['variants'] as List<dynamic>?)?.map((v) => Variant.fromJson(v)).toList() ?? [],
      price: (json['price'] is String ? double.parse(json['price']) : json['price'] ?? 29.99).toDouble(),
      stock: json['stock'] ?? 50,
      availability: json['availability'] ?? true,
      description: json['description'] ?? 'Sample product description',
      qrCode: json['qrCode'] ?? 'QR-SAMPLE-123',
      barcode: json['barcode'] ?? 'BAR-456789',
      categoryId: json['categoryId'] is Map ? json['categoryId']['_id'] ?? json['categoryId'].toString() : json['categoryId']?.toString() ?? 'unknown',
      subcategory: json['subcategory'] ?? '',
    );
  }
}