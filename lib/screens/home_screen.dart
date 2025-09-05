// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import 'budget_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _startExchange(BuildContext context) async {
    final TextEditingController _idController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Product ID for Exchange', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _idController,
          decoration: InputDecoration(
            labelText: 'Product ID',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              final id = _idController.text;
              if (id.isNotEmpty) {
                await context.read<ProductProvider>().fetchProduct(id);
                Navigator.pop(context);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductDetailScreen(isExchange: true)),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanCode(BuildContext context) async {
    final code = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
    if (code != null && context.mounted) {
      String productCode = code as String;
      // If the QR code is a URL, extract the product code from the end
      if (productCode.startsWith('http')) {
        final uri = Uri.parse(productCode);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          productCode = pathSegments.last;
        }
      }
      await context.read<ProductProvider>().fetchProductByCode(productCode);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _idController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text('SmartStyle AI', style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_money),
              label: const Text('Custom Budget'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Exchange'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _startExchange(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _scanCode(context),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Enter Product ID (Fallback)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (id) async {
                  if (id.isNotEmpty) {
                    await context.read<ProductProvider>().fetchProduct(id);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
                      );
                    }
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final id = _idController.text;
                if (id.isNotEmpty) {
                  await context.read<ProductProvider>().fetchProduct(id);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
                    );
                  }
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