
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import 'budget_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _startScan(BuildContext context, {bool isExchange = false}) async {
    final code = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
    if (code != null && context.mounted) {
      await context.read<ProductProvider>().fetchProductByCode(code as String);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(isExchange: isExchange)),
        );
      }
    } else if (context.mounted) {
      // Fallback if scan fails (code == null)
      _fallbackProductIdEntry(context, isExchange: isExchange);
    }
  }

  Future<void> _fallbackProductIdEntry(BuildContext context, {bool isExchange = false}) async {
    final TextEditingController idController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Product ID (Fallback)', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: idController,
          decoration: InputDecoration(
            labelText: 'Product ID',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              final id = idController.text;
              if (id.isNotEmpty) {
                await context.read<ProductProvider>().fetchProduct(id);
                Navigator.pop(context);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(isExchange: isExchange)),
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

  Future<void> _startExchange(BuildContext context) async {
    _startScan(context, isExchange: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SmartStyle AI', style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan the product'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _startScan(context),
            ),
            const SizedBox(height: 8),
            Text('to get product details', style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey)),
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
            const SizedBox(height: 8),
            Text('to get alternative products', style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_money),
              label: const Text('Custom Budget'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
            ),
            const SizedBox(height: 8),
            Text('Get budget recommendations', style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}