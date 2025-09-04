// lib/screens/product_detail_screen.dart (updated)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'recommendations_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final bool isExchange; // New parameter to control exchange button visibility

  const ProductDetailScreen({super.key, this.isExchange = false});

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>().currentProduct;
    if (product == null) return const Scaffold(body: Center(child: Text('No Product')));

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(product.image),
            Text('Price: \$${product.price}'),
            Text('Sizes: ${product.sizes.join(', ')}'),
            Text('Colors: ${product.colors.join(', ')}'),
            Text('Stock: ${product.stock}'),
            Text('Availability: ${product.availability ? 'In Stock' : 'Out of Stock'}'),
            Text(product.description),
            if (isExchange) // Show exchange button only if in exchange mode
              ElevatedButton(
                onPressed: () async {
                  await context.read<ProductProvider>().fetchRecommendations(product.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecommendationsScreen()),
                  );
                },
                child: const Text('Exchange/Alternatives'),
              ),
          ],
        ),
      ),
    );
  }
}