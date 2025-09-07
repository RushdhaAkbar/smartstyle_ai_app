import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/product_provider.dart';
import 'recommendations_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProductDetailScreen extends StatelessWidget {
  final bool isExchange;

  const ProductDetailScreen({super.key, this.isExchange = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final product = provider.currentProduct;

    print(
      'Building ProductDetailScreen, isLoading: ${provider.isLoading}, product: ${product?.name ?? 'null'}',
    );

    if (provider.isLoading) {
      print('Showing loading spinner');
      return const Scaffold(
        body: Center(child: SpinKitWave(color: Colors.blueAccent, size: 50.0)),
      );
    }

    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Product Not Found',
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Text(
            'No product found.',
            style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.name,
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50), // Professional dark blue-grey
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Images Carousel
              CarouselSlider(
                options: CarouselOptions(
                  height: 350.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.85,
                ),
                items: product.variants.isNotEmpty
                    ? product.variants.map((variant) {
                        return Builder(
                          builder: (BuildContext context) {
                            Widget imageWidget;
                            try {
                              if (variant.image.startsWith('data:image')) {
                                final base64String = variant.image
                                    .split(',')
                                    .last;
                                final bytes = base64Decode(base64String);
                                imageWidget = Image.memory(
                                  bytes,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.error, size: 50),
                                );
                              } else if (variant.image.contains(
                                RegExp(r'^[A-Za-z0-9+/=]+$'),
                              )) {
                                final bytes = base64Decode(variant.image);
                                imageWidget = Image.memory(
                                  bytes,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.error, size: 50),
                                );
                              } else {
                                imageWidget = Image.network(
                                  variant.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.error, size: 50),
                                );
                              }
                            } catch (e) {
                              imageWidget = const Icon(Icons.error, size: 50);
                            }
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: imageWidget,
                              ),
                            );
                          },
                        );
                      }).toList()
                    : [
                        Builder(
                          builder: (BuildContext context) {
                            final placeholderUrl =
                                'https://example.com/placeholder.jpg';
                            Widget imageWidget;
                            try {
                              if (placeholderUrl.startsWith('data:image')) {
                                final base64String = placeholderUrl
                                    .split(',')
                                    .last;
                                final bytes = base64Decode(base64String);
                                imageWidget = Image.memory(
                                  bytes,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.error, size: 50),
                                );
                              } else if (placeholderUrl.contains(
                                RegExp(r'^[A-Za-z0-9+/=]+$'),
                              )) {
                                final bytes = base64Decode(placeholderUrl);
                                imageWidget = Image.memory(
                                  bytes,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.error, size: 50),
                                );
                              } else {
                                imageWidget = Image.network(
                                  placeholderUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.error, size: 50),
                                );
                              }
                            } catch (e) {
                              imageWidget = const Icon(Icons.error, size: 50);
                            }
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: imageWidget,
                              ),
                            );
                          },
                        ),
                      ],
              ),
              const SizedBox(height: 24),

              // Product Details Card
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Color(0xFFF8F9FA)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C3E50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                color: Color(0xFF2C3E50),
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.roboto(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Details in rows
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(
                                Icons.straighten,
                                'Sizes',
                                product.sizes.join(', '),
                              ),
                            ),
                            Expanded(
                              child: _buildDetailRow(
                                Icons.palette,
                                'Colors',
                                product.variants.map((v) => v.color).join(', '),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailRow(
                                Icons.inventory,
                                'Stock',
                                product.stock.toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildDetailRow(
                                product.availability
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                'Availability',
                                product.availability
                                    ? 'In Stock'
                                    : 'Out of Stock',
                                color: product.availability
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.category,
                          'Category',
                          product.subcategory.isEmpty
                              ? 'N/A'
                              : product.subcategory,
                        ),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'Description',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Action Button
                        if (isExchange)
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.swap_horiz,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Exchange/Alternatives',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: const Color(0xFF2C3E50),
                                  elevation: 4,
                                  shadowColor: const Color(
                                    0xFF2C3E50,
                                  ).withOpacity(0.3),
                                ),
                                onPressed: () async {
                                  await context
                                      .read<ProductProvider>()
                                      .fetchRecommendations(product.id);
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RecommendationsScreen(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? const Color(0xFF2C3E50)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
