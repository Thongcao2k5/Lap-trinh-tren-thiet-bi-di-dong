import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/court.dart';

class CourtSchedule {
  const CourtSchedule({
    required this.court,
    required this.slots,
    this.hasError = false,
  });
  final Court court;
  final List<BookingSlot> slots;
  final bool hasError;
}

class BookingTimeline extends StatelessWidget {
  const BookingTimeline({
    super.key,
    required this.schedules,
    required this.date,
    required this.selectedCourtIds,
    required this.selectedSlotKeys,
    this.zoom = 1,
    this.onSlotTap,
    this.onCourtInfo,
    this.onRetry,
    this.focusedCourtId,
  });

  final List<CourtSchedule> schedules;
  final DateTime date;
  final Set<String> selectedCourtIds;
  final Set<String> selectedSlotKeys;
  final double zoom;
  final void Function(Court court, BookingSlot slot)? onSlotTap;
  final ValueChanged<Court>? onCourtInfo;
  final VoidCallback? onRetry;
  final String? focusedCourtId;
  static const _rowHeight = 64.0;
  static const _labelWidth = 88.0;
  static const _headerHeight = 40.0;

  int _minutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _time(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  bool _past(BookingSlot slot) => DateTime(
    date.year,
    date.month,
    date.day,
    _minutes(slot.startTime) ~/ 60,
    _minutes(slot.startTime) % 60,
  ).isBefore(DateTime.now());

  Widget _buildCourtLabel(CourtSchedule schedule) {
    final isFocused = schedule.court.id == focusedCourtId;
    final isSelected = selectedCourtIds.contains(schedule.court.id);
    return Container(
      height: _rowHeight,
      decoration: BoxDecoration(
        color: isFocused
            ? AppColors.primarySoft
            : isSelected
                ? AppColors.primarySoft
                : AppColors.surface,
        border: Border(
          left: isFocused
              ? const BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          bottom: const BorderSide(color: AppColors.borderMuted),
          right: const BorderSide(color: AppColors.borderMuted),
        ),
      ),
      child: InkWell(
        onTap: onCourtInfo == null ? null : () => onCourtInfo!(schedule.court),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                schedule.court.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isFocused ? FontWeight.w800 : FontWeight.w600,
                  color: isFocused ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              if (isFocused)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Đang xem',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.primaryDark,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boundaries = <int>{};
    for (final schedule in schedules) {
      for (final slot in schedule.slots) {
        boundaries.add(_minutes(slot.startTime));
        boundaries.add(_minutes(slot.endTime));
      }
    }
    if (boundaries.isEmpty) {
      final failed = schedules.any((schedule) => schedule.hasError);
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              failed
                  ? 'Không thể tải khung giờ.'
                  : 'Các sân chưa có bảng giá khung giờ.',
            ),
            if (failed)
              TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    final sorted = boundaries.toList()..sort();
    final start = sorted.first;
    final end = sorted.last;
    final pixelsPerMinute = 1.7 * zoom;
    final width = (end - start) * pixelsPerMinute;
    final ticks = <int>[start];
    for (int tick = ((start ~/ 30) + 1) * 30; tick < end; tick += 30) {
      ticks.add(tick);
    }
    ticks.add(end);
    final height = _headerHeight + schedules.length * _rowHeight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _labelWidth,
          child: Column(
            children: [
              Container(
                height: _headerHeight,
                alignment: Alignment.center,
                color: AppColors.primarySoft,
                child: const Text(
                  'Sân / Giờ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              for (final schedule in schedules) _buildCourtLabel(schedule),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width + 36,
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: _headerHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(color: AppColors.primarySoft),
                        ),
                        for (final tick in ticks)
                          Positioned(
                            left: (tick - start) * pixelsPerMinute,
                            top: 10,
                            child: Text(
                              _time(tick),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  for (final schedule in schedules)
                    SizedBox(
                      width: width,
                      height: _rowHeight,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: schedule.court.id == focusedCourtId
                                    ? AppColors.primarySoft.withValues(alpha: 0.25)
                                    : const Color(0xFF9CA3AF),
                                border: Border(
                                  top: schedule.court.id == focusedCourtId
                                      ? const BorderSide(color: AppColors.primary, width: 1.5)
                                      : BorderSide.none,
                                  bottom: schedule.court.id == focusedCourtId
                                      ? const BorderSide(color: AppColors.primary, width: 1.5)
                                      : const BorderSide(color: AppColors.borderMuted),
                                ),
                              ),
                            ),
                          ),
                          if (schedule.hasError)
                            Positioned.fill(
                              child: Center(
                                child: TextButton(
                                  onPressed: onRetry,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Lỗi tải lịch • Thử lại'),
                                ),
                              ),
                            )
                          else ...[
                            for (final slot in schedule.slots)
                              _cell(
                                schedule.court,
                                slot,
                                start,
                                pixelsPerMinute,
                              ),
                            for (final tick in ticks)
                              Positioned(
                                left: (tick - start) * pixelsPerMinute,
                                top: 0,
                                bottom: 0,
                                child: IgnorePointer(
                                  child: Container(
                                    width: 1,
                                    color: Colors.white.withValues(alpha: .25),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(
    Court court,
    BookingSlot slot,
    int start,
    double pixelsPerMinute,
  ) {
    final past = _past(slot);
    final disabled = past || slot.isBooked;
    final selected = selectedSlotKeys.contains('${court.id}:${slot.timeSlotId}');
    final color = past
        ? const Color(0xFFE2E8F0)
        : slot.isBooked
        ? AppColors.info
        : selected
        ? AppColors.primary
        : Colors.white;
    final state = past
        ? 'Đã qua'
        : slot.isBooked
        ? 'Đã đặt'
        : disabled
        ? 'Khóa'
        : selected
        ? 'Đang chọn'
        : 'Trống';
    final label =
        '${court.name}, ${_time(_minutes(slot.startTime))} – ${_time(_minutes(slot.endTime))}, $state';
    return Positioned(
      left: (_minutes(slot.startTime) - start) * pixelsPerMinute,
      top: 0,
      bottom: 0,
      width:
          (_minutes(slot.endTime) - _minutes(slot.startTime)) * pixelsPerMinute,
      child: Semantics(
        label: label,
        button: true,
        selected: selected,
        enabled: !disabled && onSlotTap != null,
        child: Tooltip(
          message: '$label • ${slot.price.toStringAsFixed(0)} đ',
          child: Material(
            color: color,
            child: InkWell(
              key: ValueKey('slot-${court.id}-${slot.timeSlotId}'),
              onTap: disabled || onSlotTap == null
                  ? null
                  : () => onSlotTap!(court, slot),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryDark
                        : const Color(0xFFCBD5E1),
                    width: selected ? 2 : .5,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                    : slot.isBooked
                    ? const Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimelineLegend extends StatelessWidget {
  const TimelineLegend({super.key, required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    ],
  );
}
