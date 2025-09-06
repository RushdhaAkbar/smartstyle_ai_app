
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  final bool isFromBudget;

  const RecommendationsScreen({super.key, this.isFromBudget = false});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<Product> selectedProducts = [];
  double totalPrice = 0.0;

  void _updateTotal() {
    totalPrice = selectedProducts.fold(0.0, (sum, p) => sum + p.price);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: SpinKitWave(color: Colors.blueAccent, size: 50.0)),
      );
    }
    final recommendations = provider.recommendations;
    final aiSuggestions = provider.aiSuggestions;

    if (recommendations.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('No Recommendations', style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Text('No recommendations available.', style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey)),
        ),
      );
    }

    Widget aiSection = Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.blueAccent.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Suggestions', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(aiSuggestions, style: GoogleFonts.roboto(fontSize: 14)),
        ],
      ),
    );

    if (widget.isFromBudget) {
      Map<String, List<Product>> grouped = {};
      for (var p in recommendations) {
        final type = p.subcategory.isNotEmpty ? p.subcategory : p.name.split(' ').last;
        grouped[type] ??= [];
        grouped[type]!.add(p);
      }

      return Scaffold(
        appBar: AppBar(
          title: Text('Budget Recommendations', style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueAccent,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.roboto(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              aiSection,
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: grouped.keys.length,
                itemBuilder: (context, index) {
                  final type = grouped.keys.elementAt(index);
                  final products = grouped[type]!;
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                      title: Text('$type Options', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600)),
                      children: products.map((product) {
                        return CheckboxListTile(
                          value: selectedProducts.contains(product),
                          onChanged: (checked) {
                            setState(() {
                              if (checked!) {
                                selectedProducts.add(product);
                              } else {
                                selectedProducts.remove(product);
                              }
                              _updateTotal();
                            });
                          },
                          title: Text(product.name, style: GoogleFonts.roboto(fontSize: 16)),
                          subtitle: Text(
                            '\$${product.price.toStringAsFixed(2)} - Stock: ${product.stock}',
                            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
                          ),
                          secondary: GestureDetector(
                            onTap: () {
                              context.read<ProductProvider>().fetchProduct(product.id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProductDetailScreen(isExchange: false)),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Builder(
                                builder: (context) {
                                  final imageUrl = product.variants.isNotEmpty ? product.variants[0].image : 'https://example.com/placeholder.jpg';
                                  Widget imageWidget;
                                  try {
                                    if (imageUrl.startsWith('data:image')) {
                                      final base64String = imageUrl.split(',').last;
                                      final bytes = base64Decode(base64String);
                                      imageWidget = Image.memory(
                                        bytes,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                      );
                                    } else if (imageUrl.contains(RegExp(r'^[A-Za-z0-9+/=]+$'))) {
                                      final bytes = base64Decode(imageUrl);
                                      imageWidget = Image.memory(
                                        bytes,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                      );
                                    } else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
                                      imageWidget = Image.network(
                                        imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                      );
                                    } else {
                                      // Invalid image URL format fallback
                                      imageWidget = const Icon(Icons.error, size: 50);
                                    }
                                  } catch (e) {
                                    imageWidget = const Icon(Icons.error, size: 50);
                                  }
                                  return imageWidget;
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Exchange/Alternatives', style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueAccent,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              aiSection,
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final product = recommendations[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        context.read<ProductProvider>().fetchProduct(product.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductDetailScreen(isExchange: true)),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Builder(
                              builder: (context) {
                                final imageUrl = product.variants.isNotEmpty ? product.variants[0].image : 'https://example.com/placeholder.jpg';
                                Widget imageWidget;
                                try {
                                  if (imageUrl.startsWith('data:image')) {
                                    final base64String = imageUrl.split(',').last;
                                    final bytes = base64Decode(base64String);
                                    imageWidget = Image.memory(
                                      bytes,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                    );
                                  } else if (imageUrl.contains(RegExp(r'^[A-Za-z0-9+/=]+$'))) {
                                    final bytes = base64Decode(imageUrl);
                                    imageWidget = Image.memory(
                                      bytes,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                    );
                                  } else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
                                    imageWidget = Image.network(
                                      imageUrl,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                                    );
                                  } else {
                                    // Invalid image URL format fallback
                                    imageWidget = const Icon(Icons.error, size: 50);
                                  }
                                } catch (e) {
                                  imageWidget = const Icon(Icons.error, size: 50);
                                }
                                return imageWidget;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
                                ),
                                Text(
                                  product.availability ? 'In Stock' : 'Out of Stock',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: product.availability ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}