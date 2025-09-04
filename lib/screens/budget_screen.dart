// lib/screens/budget_screen.dart (updated for multi-type)
import 'package:flutter/material.dart';
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
  final TextEditingController _type = TextEditingController();
  String _errorMessage = '';

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
            TextField(
              controller: _type,
              decoration: const InputDecoration(labelText: 'Dress Type (e.g., skirt and blouse)'),
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
                if (_budget.text.isEmpty || _type.text.isEmpty || budget == null) {
                  setState(() => _errorMessage = 'Please fill all fields with a valid budget');
                  return;
                }
                await context.read<ProductProvider>().fetchBudgetRecommendations(budget, _type.text);
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