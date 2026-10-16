import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:san_va_cau_app/core/widgets/app_image.dart';

void main() {
  for (final base in [
    'http://10.0.2.2:3000/api',
    'http://192.168.1.25:3000/api/',
    'http://localhost:3000/api',
    'https://example.test/api',
  ]) {
    test('uploads resolve against backend origin: $base', () {
      for (final source in [
        '/uploads/images/products/test.webp',
        'uploads/images/products/test.webp',
      ]) {
        final resolved = Uri.parse(AppImage.resolveSource(source, apiBaseUrl: base)!);
        expect(resolved.origin, Uri.parse(base).origin);
        expect(resolved.path, '/uploads/images/products/test.webp');
        expect(resolved.path, isNot(contains('/api/')));
      }
    });
  }
  test('assets and absolute HTTP URLs remain compatible', () {
    expect(AppImage.resolveSource('assets/demo/product-shoes.jpg'),
        'assets/demo/product-shoes.jpg');
    expect(AppImage.resolveSource('https://example.test/photo.webp'),
        'https://example.test/photo.webp');
    expect(AppImage.resolveSource(''), isNull);
    expect(AppImage.resolveSource('  '), isNull);
    expect(AppImage.resolveSource('file:///local/photo.jpg'), isNull);
    expect(AppImage.resolveSource('//other.test/photo.jpg'), isNull);
  });
  testWidgets('empty source displays neutral fallback without a network image', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppImage(
      source: '', fallback: Icon(Icons.shopping_bag_outlined),
    )));
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
