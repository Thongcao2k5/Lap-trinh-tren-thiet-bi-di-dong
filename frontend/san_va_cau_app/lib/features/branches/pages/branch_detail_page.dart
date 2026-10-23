import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../../booking/data/booking_api.dart';
import '../../booking/models/court.dart';
import '../models/branch.dart';
import '../../../core/utils/url_util.dart';
import '../../booking/pages/booking_page.dart';
import '../data/branch_api.dart';

class BranchDetailPage extends StatefulWidget {
  const BranchDetailPage({
    super.key,
    required this.branch,
    this.onBookPressed,
    this.branchApi,
    this.bookingApi,
  });

  final Branch branch;
  final VoidCallback? onBookPressed;
  final BranchApi? branchApi;
  final BookingApi? bookingApi;

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage> {
  late final Future<List<Court>> _courtsFuture;

  @override
  void initState() {
    super.initState();
    final api = widget.bookingApi ?? BookingApi();
    _courtsFuture = api.getCourts(branchId: widget.branch.id);
  }

  void _openBookingSchedule({Court? court}) {
    if (widget.onBookPressed != null) {
      widget.onBookPressed!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingPage(
          initialBranch: widget.branch,
          initialCourtId: court?.id,
          isStandalone: true,
          branchApi: widget.branchApi,
          bookingApi: widget.bookingApi,
        ),
      ),
    );
  }

  String _shortTime(String value) {
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;
    final description = branch.description?.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết chi nhánh'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderMuted),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.borderMuted, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () => _openBookingSchedule(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(Icons.calendar_month_rounded, size: 22),
              label: const Text('Đặt sân ngay'),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Hero banner with 16:9 ratio and cover fit
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRect(
              child: AppImage(
                source: branch.imageUrl ?? '',
                fit: BoxFit.cover,
                fallback: Container(
                  color: AppColors.primarySoft,
                  child: const Center(
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with branch name and active status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        branch.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Đang hoạt động',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Description if available
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // Information surface with icon containers
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderMuted),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _DetailInfoItem(
                        icon: Icons.location_on_rounded,
                        label: 'Địa chỉ',
                        value: branch.address,
                        iconSize: 26,
                        onTap: () => openMapSafely(context, branch.resolvedMapUrl),
                      ),
                      const SizedBox(height: 16),
                      _DetailInfoItem(
                        icon: Icons.schedule_rounded,
                        label: 'Giờ hoạt động',
                        value:
                            '${_shortTime(branch.openingTime)} - ${_shortTime(branch.closingTime)}',
                      ),
                      if (branch.phone?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        _DetailInfoItem(
                          icon: Icons.call_rounded,
                          label: 'Điện thoại',
                          value: branch.phone!,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section title
                Text(
                  'Sân tại chi nhánh',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Court list
                FutureBuilder<List<Court>>(
                  future: _courtsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderMuted),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Không thể tải danh sách sân',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final courts = snapshot.data ?? const <Court>[];
                    if (courts.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderMuted),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.sports_tennis_rounded,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Chi nhánh chưa có sân đang hoạt động',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (final court in courts) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderMuted),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x04000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                hoverColor: AppColors.primarySoft.withValues(alpha: 0.5),
                                splashColor: AppColors.primarySoft,
                                onTap: () => _openBookingSchedule(court: court),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySoft,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.sports_tennis_rounded,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              court.name,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (court.description?.isNotEmpty ==
                                                true) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                court.description!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class _DetailInfoItem extends StatelessWidget {
  const _DetailInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.iconSize = 20,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final double iconSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: iconSize),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppColors.primarySoft.withValues(alpha: 0.5),
          splashColor: AppColors.primarySoft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: rowContent,
          ),
        ),
      );
    }

    return rowContent;
  }
}
