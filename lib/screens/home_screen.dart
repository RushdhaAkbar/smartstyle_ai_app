// lib/screens/home_screen.dart (updated with Exchange button)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import 'budget_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _startExchange(BuildContext context) async {
    final TextEditingController _idController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Product ID for Exchange'),
        content: TextField(
          controller: _idController,
          decoration: const InputDecoration(labelText: 'Product ID'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final id = _idController.text;
              if (id.isNotEmpty) {
                await context.read<ProductProvider>().fetchProduct(id);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductDetailScreen(isExchange: true)),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _idController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('SmartStyle AI Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
              child: const Text('Custom Budget'),
            ),
            ElevatedButton(
              onPressed: () => _startExchange(context),
              child: const Text('Exchange'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Enter Product ID (Fallback)',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (id) async {
                  if (id.isNotEmpty) {
                    await context.read<ProductProvider>().fetchProduct(id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final id = _idController.text;
                if (id.isNotEmpty) {
                  await context.read<ProductProvider>().fetchProduct(id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
                  );
                }
              },
              child: const Text('Get Product Details'),
            ),
          ],
        ),
      ),
    );
  }
}