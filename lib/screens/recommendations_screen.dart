
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import '../models/product.dart';
class RecommendationsScreen extends StatefulWidget {
  final bool isFromBudget; // Flag to indicate if from BudgetScreen

  const RecommendationsScreen({super.key, this.isFromBudget = false});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<Product> selectedProducts = []; // To track selected products
  double totalPrice = 0.0; // To calculate total

  void _updateTotal() {
    totalPrice = selectedProducts.fold(0.0, (sum, p) => sum + p.price);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    final recommendations = provider.recommendations;

    if (recommendations.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No Recommendations Available')),
      );
    }

    if (widget.isFromBudget) {
      // Group by type for budget mode
      Map<String, List<Product>> grouped = {};
      for (var p in recommendations) {
        grouped[p.name.split(' ')[1]] ??= []; // Group by type (e.g., 'Skirt', 'Blouse')
        grouped[p.name.split(' ')[1]]!.add(p);
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Budget Recommendations'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Total: \$${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            final type = grouped.keys.elementAt(index);
            final products = grouped[type]!;
            return ExpansionTile(
              title: Text('$type Options'),
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
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)} - Stock: ${product.stock}'),
                  secondary: GestureDetector(
                    onTap: () {
                      context.read<ProductProvider>().fetchProduct(product.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductDetailScreen(isExchange: false)),
                      );
                    },
                    child: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stack) => const Icon(Icons.error)),
                  ),
                );
              }).toList(),
            );
          },
        ),
      );
    } else {
      // Standard list for exchange
      return Scaffold(
        appBar: AppBar(title: const Text('Exchange/Alternatives')),
        body: ListView.builder(
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final product = recommendations[index];
            return ListTile(
              leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stack) => const Icon(Icons.error)),
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)} - Stock: ${product.stock}'),
              trailing: Text(product.availability ? 'Available' : 'Out of Stock'),
              onTap: () {
                context.read<ProductProvider>().fetchProduct(product.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductDetailScreen(isExchange: true)),
                );
              },
            );
          },
        ),
      );
    }
  }
}