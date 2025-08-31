// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _scanCode(BuildContext context, bool isQR) async {
    String code = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Line color
      'Cancel', // Cancel button text
      true, // Show flash icon
      isQR ? ScanMode.QR : ScanMode.BARCODE,
    );
    if (code != '-1') { // -1 means scan cancelled
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