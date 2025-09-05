// lib/screens/budget_screen.dart (updated with searchable tags)
import 'package:flutter/material.dart';
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
  final List<String> selectedTypes = []; // Track selected dress types
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  // Comprehensive list of dress types (expandable)
  final List<String> allTypes = [
    'T-Shirt', 'Skirt', 'Blouse', 'Hoodie', 'Dress', 'Jeans', 'Jacket', 'Shirt', 'Pants',
    'Shorts', 'Sweater', 'Coat', 'Vest', 'Tunic', 'Leggings'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Recommendations')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _budget,
              decoration: const InputDecoration(labelText: 'Budget (\$)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search and Select Dress Types',
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return allTypes.where((type) => type.toLowerCase().contains(pattern.toLowerCase())).toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  if (!selectedTypes.contains(suggestion)) {
                    selectedTypes.add(suggestion);
                  }
                  _searchController.clear(); // Clear search after selection
                });
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: selectedTypes.map((type) {
                return Chip(
                  label: Text(type),
                  onDeleted: () {
                    setState(() {
                      selectedTypes.remove(type);
                    });
                  },
                );
              }).toList(),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
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
              child: const Text('Get Suggestions'),
            ),
          ],
        ),
      ),
    );
  }
}