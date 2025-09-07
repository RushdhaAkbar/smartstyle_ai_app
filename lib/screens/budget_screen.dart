
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'recommendations_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _budget = TextEditingController();
  final List<String> selectedTypes = [];
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> allTypes = [
    'T-Shirt', 'Skirt', 'Blouse', 'Hoodie', 'Dress', 'Jeans', 'Jacket', 'Shirt', 'Pants',
    'Shorts', 'Sweater', 'Coat', 'Vest', 'Tunic', 'Leggings'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Recommendations', style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2C3E50), // Professional dark blue-grey
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: SpinKitWave(color: Color(0xFF4CAF50), size: 50.0))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Products Within Your Budget',
                        style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _budget,
                        decoration: InputDecoration(
                          labelText: 'Budget (\$)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 16),
                      TypeAheadField(
                        builder: (context, controller, focusNode) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Search Dress Types',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.search),
                            ),
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          return allTypes.where((type) => type.toLowerCase().contains(pattern.toLowerCase())).toList();
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(title: Text(suggestion, style: GoogleFonts.roboto()));
                        },
                        onSelected: (suggestion) {
                          setState(() {
                            if (!selectedTypes.contains(suggestion)) {
                              selectedTypes.add(suggestion);
                            }
                            _searchController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: selectedTypes.map((type) {
                          return Chip(
                            label: Text(type, style: GoogleFonts.roboto(fontSize: 14)),
                            deleteIcon: const Icon(Icons.cancel, size: 18),
                            onDeleted: () {
                              setState(() {
                                selectedTypes.remove(type);
                              });
                            },
                            backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          );
                        }).toList(),
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(_errorMessage, style: GoogleFonts.roboto(color: Colors.red, fontSize: 14)),
                        ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: Text('Get Suggestions', style: GoogleFonts.roboto(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: const Color(0xFF4CAF50), // Green color instead of dark blue
                          ),
                          onPressed: () async {
                            setState(() => _errorMessage = '');
                            final budget = double.tryParse(_budget.text);
                            if (_budget.text.isEmpty || selectedTypes.isEmpty || budget == null) {
                              setState(() => _errorMessage = 'Please enter a valid budget and select at least one type');
                              return;
                            }
                            await context.read<ProductProvider>().fetchBudgetRecommendations(budget, selectedTypes.join(' and '));
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RecommendationsScreen(isFromBudget: true)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}