import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:san_va_cau_app/features/products/models/product.dart';
import 'package:san_va_cau_app/features/products/models/product_variant.dart';
import 'package:san_va_cau_app/features/products/widgets/product_card.dart';

void main() {
  for (final imageUrl in <String?>[null, '']) {
    testWidgets('ProductCard uses neutral placeholder for imageUrl=$imageUrl', (
      tester,
    ) async {
      final product = Product.fromJson({
        'id': '1',
        'name': 'Yonex Arcsaber 7 Play',
        'imageUrl': imageUrl,
        'category': {'id': '1', 'name': 'Vợt cầu lông'},
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 240,
              height: 360,
              child: ProductCard(product: product, onTap: () {}),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  test('ProductVariant accepts null imageUrl and retains price and stock', () {
    final variant = ProductVariant.fromJson({
      'id': '1',
      'productId': '1',
      'sku': 'SVC-ARC7PL-4UG5',
      'variantName': '4U / G5',
      'price': '1050000',
      'imageUrl': null,
      'isActive': true,
      'stockQuantity': 8,
    });
    expect(variant.imageUrl, isNull);
    expect(variant.price, '1050000');
    expect(variant.stockQuantity, 8);
  });

  for (final entry in <String?, String>{
    '1050000.00': 'Từ 1.050.000 đ',
    '45000': 'Từ 45.000 đ',
    null: 'Liên hệ',
  }.entries) {
    testWidgets('ProductCard formats minPrice=${entry.key} on a narrow card', (
      tester,
    ) async {
      final product = Product.fromJson({
        'id': '1',
        'name': 'Yonex Arcsaber 7 Play phiên bản cầu lông',
        'minPrice': entry.key,
        'imageUrl': null,
        'brand': {'id': '1', 'name': 'Yonex'},
        'category': {'id': '1', 'name': 'Vợt cầu lông'},
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 160,
              height: 230,
              child: ProductCard(product: product, onTap: () {}),
            ),
          ),
        ),
      );
      expect(find.text(entry.value), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
