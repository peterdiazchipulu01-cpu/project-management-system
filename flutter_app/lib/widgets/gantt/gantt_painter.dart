import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../models/task.dart';
import '../../core/app_theme.dart';

class GanttPainter extends CustomPainter {
  final List<DateTime> days;
  final List<Task> tasks;
  final DateTime today;
  final bool isDark;

  static const dayWidth = 36.0;
  static const rowHeight = 40.0;
  static const headerHeight = 44.0;
  static const _barHeight = 22.0;
  static const _barRadius = 4.0;

  const GanttPainter({
    required this.days,
    required this.tasks,
    required this.today,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawWeekendHighlights(canvas, size);
    _drawGrid(canvas, size);
    _drawHeader(canvas, size);
    _drawTaskBars(canvas);
    _drawTodayMarker(canvas, size);
  }

  void _drawWeekendHighlights(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03);
    for (int i = 0; i < days.length; i++) {
      final wd = days[i].weekday;
      if (wd == DateTime.saturday || wd == DateTime.sunday) {
        canvas.drawRect(
            Rect.fromLTWH(i * dayWidth, 0, dayWidth, size.height), paint);
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (int i = 0; i <= days.length; i++) {
      final x = i * dayWidth;
      canvas.drawLine(
          Offset(x, headerHeight), Offset(x, size.height), paint);
    }
    for (int i = 0; i <= tasks.length; i++) {
      final y = headerHeight + i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawHeader(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color =
          isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF4F4F5);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, headerHeight), bgPaint);

    final todayIdx = days.indexWhere((d) =>
        d.year == today.year &&
        d.month == today.month &&
        d.day == today.day);

    if (todayIdx >= 0) {
      final todayBg = Paint()
        ..color = AppTheme.primary.withValues(alpha: 0.12);
      canvas.drawRect(
          Rect.fromLTWH(
              todayIdx * dayWidth, 0, dayWidth, headerHeight),
          todayBg);
    }

    final dayFmt = DateFormat('d');
    final weekdayFmt = DateFormat('EEE');
    for (int i = 0; i < days.length; i++) {
      final isToday = i == todayIdx;
      final textColor = isToday
          ? AppTheme.primary
          : (isDark ? Colors.white54 : Colors.black45);
      _drawCenteredText(canvas, weekdayFmt.format(days[i]),
          Offset(i * dayWidth + dayWidth / 2, 11),
          color: textColor, fontSize: 9);
      _drawCenteredText(canvas, dayFmt.format(days[i]),
          Offset(i * dayWidth + dayWidth / 2, 26),
          color: textColor, fontSize: 12, bold: isToday);
    }
  }

  void _drawTaskBars(Canvas canvas) {
    if (days.isEmpty) return;
    final rangeStart =
        DateTime(days.first.year, days.first.month, days.first.day);
    final totalW = days.length * dayWidth;

    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      if (task.startDate == null && task.dueDate == null) continue;

      final startDt = task.startDate ??
          DateTime(task.dueDate!.year, task.dueDate!.month,
              task.dueDate!.day);
      final endDt = task.dueDate != null
          ? DateTime(task.dueDate!.year, task.dueDate!.month,
              task.dueDate!.day)
          : task.startDate!;

      final left = _dayOffset(startDt, rangeStart);
      final right = _dayOffset(endDt, rangeStart) + dayWidth;
      if (right <= 0 || left >= totalW) continue;

      final clampedLeft = left.clamp(0.0, totalW);
      final clampedRight = right.clamp(0.0, totalW);
      final top =
          headerHeight + i * rowHeight + (rowHeight - _barHeight) / 2;

      final barPaint = Paint()
        ..color = AppTheme.primary.withValues(alpha: 0.22);
      canvas.drawRRect(
          RRect.fromLTRBR(clampedLeft, top, clampedRight, top + _barHeight,
              const Radius.circular(_barRadius)),
          barPaint);

      if (task.progress > 0) {
        final barW = right - left;
        final progressW = barW * task.progress / 100;
        final clampedPRight =
            (left + progressW).clamp(clampedLeft, clampedRight);
        final progressPaint = Paint()
          ..color = AppTheme.primary.withValues(alpha: 0.65);
        canvas.drawRRect(
            RRect.fromLTRBR(clampedLeft, top, clampedPRight,
                top + _barHeight, const Radius.circular(_barRadius)),
            progressPaint);
      }

      _drawBarLabel(canvas, task.title,
          Offset(clampedLeft + 6, top + _barHeight / 2),
          maxWidth: clampedRight - clampedLeft - 12);
    }
  }

  void _drawTodayMarker(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final rangeStart =
        DateTime(days.first.year, days.first.month, days.first.day);
    final x = _dayOffset(today, rangeStart) + dayWidth / 2;
    if (x < 0 || x > size.width) return;

    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 2;
    canvas.drawLine(
        Offset(x, headerHeight), Offset(x, size.height), paint);
    canvas.drawCircle(Offset(x, headerHeight), 4, paint);
  }

  double _dayOffset(DateTime date, DateTime rangeStart) {
    final d = DateTime(date.year, date.month, date.day);
    return d.difference(rangeStart).inDays * dayWidth;
  }

  void _drawCenteredText(Canvas canvas, String text, Offset center,
      {required Color color,
      required double fontSize,
      bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    tp.paint(
        canvas,
        Offset(center.dx - tp.width / 2,
            center.dy - tp.height / 2));
  }

  void _drawBarLabel(Canvas canvas, String text, Offset leftCenter,
      {required double maxWidth}) {
    if (maxWidth < 10) return;
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: const TextStyle(
              color: Colors.white, fontSize: 11)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas,
        Offset(leftCenter.dx, leftCenter.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(GanttPainter old) =>
      old.days != days ||
      old.tasks != tasks ||
      old.today != today ||
      old.isDark != isDark;
}
