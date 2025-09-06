
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

    print('Building ProductDetailScreen, isLoading: ${provider.isLoading}, product: ${product?.name ?? 'null'}');

    if (provider.isLoading) {
      print('Showing loading spinner');
      return const Scaffold(
        body: Center(child: SpinKitWave(color: Colors.blueAccent, size: 50.0)),
      );
    }

    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Not Found', style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Text('No product found.', style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                  ),
                  items: product.variants.isNotEmpty
                      ? product.variants.map((variant) {
                          return Builder(
                            builder: (BuildContext context) {
                              Widget imageWidget;
                              try {
                                if (variant.image.startsWith('data:image')) {
                                  final base64String = variant.image.split(',').last;
                                  final bytes = base64Decode(base64String);
                                  imageWidget = Image.memory(
                                    bytes,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                  );
                                } else if (variant.image.contains(RegExp(r'^[A-Za-z0-9+/=]+$'))) {
                                  final bytes = base64Decode(variant.image);
                                  imageWidget = Image.memory(
                                    bytes,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                  );
                                } else {
                                  imageWidget = Image.network(
                                    variant.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                  );
                                }
                              } catch (e) {
                                imageWidget = const Icon(Icons.error, size: 50);
                              }
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageWidget,
                              );
                            },
                          );
                        }).toList()
                      : [
                          Builder(
                            builder: (BuildContext context) {
                              final placeholderUrl = 'https://example.com/placeholder.jpg';
                              Widget imageWidget;
                              try {
                                if (placeholderUrl.startsWith('data:image')) {
                                  final base64String = placeholderUrl.split(',').last;
                                  final bytes = base64Decode(base64String);
                                  imageWidget = Image.memory(
                                    bytes,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                  );
                                } else if (placeholderUrl.contains(RegExp(r'^[A-Za-z0-9+/=]+$'))) {
                                  final bytes = base64Decode(placeholderUrl);
                                  imageWidget = Image.memory(
                                    bytes,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                  );
                                } else {
                                  imageWidget = Image.network(
                                    placeholderUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                  );
                                }
                              } catch (e) {
                                imageWidget = const Icon(Icons.error, size: 50);
                              }
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageWidget,
                              );
                            },
                          ),
                        ],
                ),
                const SizedBox(height: 16),
                Text('Price: \$${product.price.toStringAsFixed(2)}', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Sizes: ${product.sizes.join(', ')}', style: GoogleFonts.roboto(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Colors: ${product.variants.map((v) => v.color).join(', ')}', style: GoogleFonts.roboto(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Stock: ${product.stock}', style: GoogleFonts.roboto(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Availability: ${product.availability ? 'In Stock' : 'Out of Stock'}', style: GoogleFonts.roboto(fontSize: 16, color: product.availability ? Colors.green : Colors.red)),
                const SizedBox(height: 8),
                Text('Category: ${product.subcategory.isEmpty ? 'N/A' : product.subcategory}', style: GoogleFonts.roboto(fontSize: 16)),
                const SizedBox(height: 16),
                Text(product.description, style: GoogleFonts.roboto(fontSize: 16)),
                const SizedBox(height: 16),
                if (isExchange)
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.swap_horiz),
                      label: Text('Exchange/Alternatives', style: GoogleFonts.roboto(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: () async {
                        await context.read<ProductProvider>().fetchRecommendations(product.id);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RecommendationsScreen()),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}