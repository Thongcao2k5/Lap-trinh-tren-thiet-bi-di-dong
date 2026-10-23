import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:san_va_cau_app/features/booking/data/booking_api.dart';
import 'package:san_va_cau_app/features/booking/models/court.dart';
import 'package:san_va_cau_app/features/branches/data/branch_api.dart';
import 'package:san_va_cau_app/features/branches/models/branch.dart';
import 'package:san_va_cau_app/features/branches/pages/branch_detail_page.dart';
import 'package:san_va_cau_app/features/branches/pages/branch_list_page.dart';

const _branchQ1 = Branch(
  id: '197',
  name: 'SanVaCau Quận 1',
  address: '55B Nguyễn Thị Minh Khai, Phường Bến Thành, Quận 1, TP.HCM',
  openingTime: '06:00:00',
  closingTime: '22:00:00',
  phone: '0901000001',
  status: 'ACTIVE',
);

const _branchThuDuc = Branch(
  id: '198',
  name: 'SanVaCau Thủ Đức',
  address: '56/1 Đường số 2, Phường Trường Thọ, TP. Thủ Đức, TP.HCM',
  openingTime: '06:00:00',
  closingTime: '22:00:00',
  phone: '0901000002',
  status: 'ACTIVE',
);

const _branchBinhThanh = Branch(
  id: '199',
  name: 'SanVaCau Bình Thạnh',
  address: '129/15 Bình Quới, Phường 27, Bình Thạnh, TP.HCM',
  openingTime: '06:00:00',
  closingTime: '22:00:00',
  phone: '0901000003',
  status: 'ACTIVE',
);

class _TestBranchApi extends BranchApi {
  @override
  Future<List<Branch>> getBranches() async => const [
    _branchQ1,
    _branchThuDuc,
    _branchBinhThanh,
  ];
}

class _TestBookingApi extends BookingApi {
  @override
  Future<List<Court>> getCourts({String? branchId}) async => const [
    Court(
      id: 'court-1',
      branchId: '197',
      name: 'Sân 1',
      description: 'Sân tiêu chuẩn',
      status: 'ACTIVE',
    ),
  ];
}

void main() {
  group('Branch Google Maps URL Resolution', () {
    test('resolves Quận 1 branch to Cung Văn hóa Lao động', () {
      expect(_branchQ1.resolvedMapUrl, contains('Cung+V%C4%83n+h%C3%B3a+Lao'));
      expect(_branchQ1.resolvedMapUrl, contains('55B+Nguy%E1%BB%85n+Th%E1%BB%8B+Minh+Khai'));
    });

    test('resolves Thủ Đức branch to Sân cầu lông Tường Anh', () {
      expect(
        _branchThuDuc.resolvedMapUrl,
        anyOf(
          contains('maps.app.goo.gl'),
          contains('T%C6%B0%E1%BB%9Dng+Anh'),
        ),
      );
    });

    test('resolves Bình Thạnh branch to Sân cầu lông Tada Thanh Đa', () {
      expect(
        _branchBinhThanh.resolvedMapUrl,
        anyOf(
          contains('maps.app.goo.gl'),
          contains('TADA+Thanh+%C4%90a'),
        ),
      );
    });

    test('generic branch falls back to encoded address and name', () {
      const genericBranch = Branch(
        id: '200',
        name: 'SanVaCau Tân Bình',
        address: '100 Cộng Hòa, Tân Bình, TP.HCM',
        openingTime: '06:00',
        closingTime: '22:00',
        status: 'ACTIVE',
      );
      expect(genericBranch.resolvedMapUrl, startsWith('https://www.google.com/maps/search/?api=1&query='));
      expect(genericBranch.resolvedMapUrl, contains('T%C3%A2n%20B%C3%ACnh'));
    });
  });

  group('BranchListPage & BranchDetailPage Map UI Integration', () {
    testWidgets('BranchListPage displays location pin icon with size 26 and interactive address row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BranchListPage(branchApi: _TestBranchApi()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify location pin icon exists with size 26
      final iconFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            widget.icon == Icons.location_on_rounded &&
            widget.size == 26,
      );
      expect(iconFinder, findsWidgets);

      // Verify the address row is wrapped in an InkWell inside the card's InkWell (total 2 InkWells ancestor)
      final inkWellAncestors = find.ancestor(
        of: find.text('55B Nguyễn Thị Minh Khai, Phường Bến Thành, Quận 1, TP.HCM'),
        matching: find.byType(InkWell),
      );
      expect(inkWellAncestors, findsNWidgets(2));
    });

    testWidgets('BranchDetailPage displays location pin icon with size 26 and interactive address row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BranchDetailPage(
            branch: _branchQ1,
            bookingApi: _TestBookingApi(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify location pin icon exists with size 26 in detail page
      final iconFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            widget.icon == Icons.location_on_rounded &&
            widget.size == 26,
      );
      expect(iconFinder, findsOneWidget);

      // Verify the detail address row is wrapped in an InkWell for tapping
      final inkWellFinder = find.ancestor(
        of: find.text('55B Nguyễn Thị Minh Khai, Phường Bến Thành, Quận 1, TP.HCM'),
        matching: find.byType(InkWell),
      );
      expect(inkWellFinder, findsOneWidget);
    });
  });
}
