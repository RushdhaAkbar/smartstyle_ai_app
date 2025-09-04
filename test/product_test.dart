import 'package:flutter_test/flutter_test.dart';

import 'package:smartstyle_ai_app/providers/product_provider.dart';

void main() {
  test('fetchRecommendations returns alternatives', () async {
    final provider = ProductProvider();
    await provider.fetchProduct('1');
    await provider.fetchRecommendations('1');
    expect(provider.recommendations.length, 1);
    expect(provider.recommendations[0].name, 'Red T-Shirt');
  });
}
