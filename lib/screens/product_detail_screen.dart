
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'recommendations_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

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
            ElevatedButton(
              onPressed: () async {
                if (product.id != null) {
                  await context.read<ProductProvider>().fetchRecommendations(product.id!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecommendationsScreen()),
                  );
                }
              },
              child: const Text('Exchange/Alternatives'),
            ),
          ],
        ),
      ),
    );
  }
}