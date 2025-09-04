// lib/screens/home_screen.dart (updated)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _scanOrEnterCode(BuildContext context, String? code) async {
    final String effectiveCode = code ?? await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (effectiveCode != null && effectiveCode.isNotEmpty) {
      await context.read<ProductProvider>().fetchProduct(effectiveCode);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
      );
    }
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
              onPressed: () => _scanOrEnterCode(context, null), // Trigger scanner
              child: const Text('Scan QR/Barcode'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Enter Product ID (e.g., 1, 2, 3)',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (id) async {
                  await _scanOrEnterCode(context, id);
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => _scanOrEnterCode(context, _idController.text),
              child: const Text('Use ID'),
            ),
          ],
        ),
      ),
    );
  }
}