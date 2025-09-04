import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smartstyle_ai_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Budget to Recommendations flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    // Enter login credentials
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    // Now on HomeScreen
    await tester.tap(find.text('Go to Budget Recommendations'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '50.0');
    await tester.enterText(find.byType(TextField).at(1), 'shirt');
    await tester.tap(find.text('Get Suggestions'));
    await tester.pumpAndSettle();
    expect(find.text('Blue T-Shirt'), findsOneWidget);
  });
}
