// lib/screens/recommendations_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
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
        body: ListView.builder(
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
                        child: Image.network(
                          product.variants.isNotEmpty ? product.variants[0].image : 'https://example.com/placeholder.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Exchange/Alternatives', style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueAccent,
        ),
        body: GridView.builder(
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
                      child: Image.network(
                        product.variants.isNotEmpty ? product.variants[0].image : 'https://example.com/placeholder.jpg',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
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
      );
    }
  }
}