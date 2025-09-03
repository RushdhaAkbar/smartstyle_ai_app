// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _scanCode(BuildContext context, bool isQR) async {
    final String? code = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (code != null && code.isNotEmpty) {
      await context.read<ProductProvider>().fetchProduct(code);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartStyle AI Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _scanCode(context, true),
              child: const Text('Scan QR Code'),
            ),
            ElevatedButton(
              onPressed: () => _scanCode(context, false),
              child: const Text('Scan Barcode'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextField(
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
          ],
        ),
      ),
    );
  }
}