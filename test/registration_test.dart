// test/screens/registration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartstyle_ai_app/screens/registration_screen.dart';


void main() {
  testWidgets('RegistrationScreen displays form and submits mock data', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
    expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'test@email.com');
    await tester.enterText(find.byType(TextField).at(1), 'Test User');
    await tester.enterText(find.byType(TextField).at(2), '1234567890');
    await tester.enterText(find.byType(TextField).at(3), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
  });
}