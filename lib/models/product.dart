class Product {
  final String id;
  final String name;
  final List<String> sizes;
  final List<String> colors;
  final double price;
  final int stock;
  final bool availability;
  final String description;
  final String image;
  final String qrCode;
  final String barcode;

  Product({
    required this.id,
    required this.name,
    required this.sizes,
    required this.colors,
    required this.price,
    required this.stock,
    required this.availability,
    required this.description,
    required this.image,
    required this.qrCode,
    required this.barcode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? 'sample_id_1',
      name: json['name'] ?? 'Sample T-Shirt',
      sizes: List<String>.from(json['sizes'] ?? ['M', 'L']),
      colors: List<String>.from(json['colors'] ?? ['Blue', 'Red']),
      price: (json['price'] ?? 29.99).toDouble(),
      stock: json['stock'] ?? 50,
      availability: json['availability'] ?? true,
      description: json['description'] ?? 'Comfortable cotton t-shirt',
      image: json['image'] ?? 'https://example.com/sample.jpg',
      qrCode: json['qrCode'] ?? 'QR-SAMPLE-123',
      barcode: json['barcode'] ?? 'BAR-456789',
    );
  }
}