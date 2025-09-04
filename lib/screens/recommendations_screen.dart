// lib/screens/recommendations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    final recommendations = provider.recommendations;

    if (recommendations.isEmpty) {
      return const Scaffold(body: Center(child: Text('No Recommendations Available')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Exchange/Alternatives')),
      body: ListView.builder(
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final product = recommendations[index];
          return ListTile(
            leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(product.name),
            subtitle: Text('\$${product.price.toStringAsFixed(2)} - Stock: ${product.stock}'),
            trailing: Text(product.availability ? 'Available' : 'Out of Stock'),
            onTap: () {
              context.read<ProductProvider>().fetchProduct(product.id);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
              );
            },
          );
        },
      ),
    );
  }
}