// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../providers/product_provider.dart';
import 'recommendations_screen.dart';

class Base64Image extends StatelessWidget {
  final String base64String;
  final BoxFit fit;
  final double? width;
  final double? height;

  const Base64Image({
    super.key,
    required this.base64String,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    try {
      // Extract the base64 data from the data URL
      final String base64Data = base64String.split(',').last;
      if (base64Data.length > 50000) { // If base64 is too long, show placeholder to avoid memory issues
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 50, color: Colors.grey),
                SizedBox(height: 8),
                Text('Image too large', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }
      final Uint8List bytes = base64Decode(base64Data);

      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stack) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Image not available', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 50, color: Colors.grey),
              SizedBox(height: 8),
              Text('Image not available', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
  }
}

class ProductDetailScreen extends StatelessWidget {
  final bool isExchange;

  const ProductDetailScreen({super.key, this.isExchange = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final product = provider.currentProduct;

    if (provider.isLoading) {
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
                              if (variant.image.startsWith('data:image')) {
                                imageWidget = Base64Image(base64String: variant.image);
                              } else {
                                imageWidget = Image.network(
                                  variant.image,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stack) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                            SizedBox(height: 8),
                                            Text('Image not available', style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageWidget,
                              );
                            },
                          );
                        }).toList()
                      : [
                          Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('No images available', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RecommendationsScreen()),
                        );
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