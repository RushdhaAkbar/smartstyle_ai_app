import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:smartstyle_ai_app/models/product.dart';
import 'package:smartstyle_ai_app/providers/product_provider.dart';
import 'package:smartstyle_ai_app/screens/budget_screen.dart';

class MockProductProvider extends Mock implements ProductProvider {}

void main() {
  testWidgets('BudgetScreen handles multi-type combinations', (
    WidgetTester tester,
  ) async {
    final mockProvider = MockProductProvider();
    when(
      mockProvider.fetchBudgetRecommendations(1000.0, 'skirt and blouse'),
    ).thenReturn(Future.value());
    when(mockProvider.recommendations).thenReturn([
      Product(
        id: '1',
        name: 'Blue Skirt',
        price: 400.0,
        stock: 50,
        availability: true,
        description: 'Mock',
        qrCode: '',
        barcode: '',
        sizes: [],
        variants: [],
        categoryId: 'skirt',
        subcategory: 'skirt',
      ),
      Product(
        id: '2',
        name: 'Red Skirt',
        price: 500.0,
        stock: 30,
        availability: true,
        description: 'Mock',
        qrCode: '',
        barcode: '',
        sizes: [],
        variants: [],
        categoryId: 'skirt',
        subcategory: 'skirt',
      ),
      Product(
        id: '3',
        name: 'Green Blouse',
        price: 200.0,
        stock: 20,
        availability: true,
        description: 'Mock',
        qrCode: '',
        barcode: '',
        sizes: [],
        variants: [],
        categoryId: 'blouse',
        subcategory: 'blouse',
      ),
      Product(
        id: '4',
        name: 'Yellow Blouse',
        price: 800.0,
        stock: 15,
        availability: true,
        description: 'Mock',
        qrCode: '',
        barcode: '',
        sizes: [],
        variants: [],
        categoryId: 'blouse',
        subcategory: 'blouse',
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ProductProvider>.value(
          value: mockProvider,
          child: const BudgetScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), '1000');
    await tester.enterText(find.byType(TextField).at(1), 'skirt and blouse');
    await tester.tap(find.text('Get Suggestions'));
    await tester.pumpAndSettle();

    verify(
      mockProvider.fetchBudgetRecommendations(1000.0, 'skirt and blouse'),
    ).called(1);
    expect(find.text('Skirt Options'), findsOneWidget);
    expect(find.text('Blue Skirt'), findsOneWidget);
    expect(find.text('Red Skirt'), findsOneWidget);
    expect(find.text('Blouse Options'), findsOneWidget);
    expect(find.text('Green Blouse'), findsOneWidget);
    expect(find.text('Yellow Blouse'), findsOneWidget);
  });
}
