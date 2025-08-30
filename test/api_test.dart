import 'package:flutter_test/flutter_test.dart';

import 'package:smartstyle_ai_app/services/api_service.dart';

void main() {
  test('Fetch mock product', () async {
    final service = ApiService();
    final product = await service.getProductById('test_id_123');
    expect(product.name, 'Test Shirt');
    expect(product.price, 19.99);
  });
}