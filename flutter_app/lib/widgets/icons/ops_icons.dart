import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Base ──────────────────────────────────────────────────────────────────

class _IconBase extends StatelessWidget {
  final double size;
  final Color color;
  final CustomPainter painter;

  const _IconBase({required this.size, required this.color, required this.painter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: painter),
    );
  }
}

// ─── 1. Welding Mask ────────────────────────────────────────────────────────

class WeldingMaskIcon extends StatelessWidget {
  final double size;
  final Color color;
  const WeldingMaskIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _WeldingMaskPainter(color));
}

class _WeldingMaskPainter extends CustomPainter {
  final Color color;
  _WeldingMaskPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final cx = s.width / 2;
    final cy = s.height / 2;

    // Helmet dome
    final dome = Path()
      ..moveTo(cx - s.width * 0.38, cy - s.height * 0.05)
      ..quadraticBezierTo(cx - s.width * 0.40, cy - s.height * 0.45, cx, cy - s.height * 0.48)
      ..quadraticBezierTo(cx + s.width * 0.40, cy - s.height * 0.45, cx + s.width * 0.38, cy - s.height * 0.05);
    canvas.drawPath(dome, p);

    // Visor rectangle
    final visor = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + s.height * 0.08), width: s.width * 0.6, height: s.height * 0.28),
      const Radius.circular(3),
    );
    canvas.drawRRect(visor, p);

    // Brim
    canvas.drawLine(
      Offset(cx - s.width * 0.42, cy - s.height * 0.05),
      Offset(cx + s.width * 0.42, cy - s.height * 0.05),
      p,
    );

    // Visor inner line (darkened lens)
    canvas.drawLine(
      Offset(cx - s.width * 0.22, cy + s.height * 0.08),
      Offset(cx + s.width * 0.22, cy + s.height * 0.08),
      p..color = color.withOpacity(0.4),
    );

    // Spark dots
    final spark = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + s.width * 0.38, cy - s.height * 0.15), 1.2, spark);
    canvas.drawCircle(Offset(cx + s.width * 0.44, cy - s.height * 0.08), 1.0, spark);
    canvas.drawCircle(Offset(cx + s.width * 0.42, cy - s.height * 0.22), 0.8, spark);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 2. Wrench / Spanner ───────────────────────────────────────────────────

class WrenchIcon extends StatelessWidget {
  final double size;
  final Color color;
  const WrenchIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _WrenchPainter(color));
}

class _WrenchPainter extends CustomPainter {
  final Color color;
  _WrenchPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final cx = s.width / 2;
    final cy = s.height / 2;

    // Handle
    canvas.drawLine(
      Offset(cx + s.width * 0.18, cy + s.height * 0.18),
      Offset(cx - s.width * 0.30, cy - s.height * 0.30),
      p..strokeWidth = 2.5,
    );

    // Wrench jaw (open circle)
    final jawPath = Path()
      ..addArc(
        Rect.fromCenter(center: Offset(cx + s.width * 0.22, cy + s.height * 0.22), width: s.width * 0.36, height: s.height * 0.36),
        0.3,
        math.pi * 1.4,
      );
    canvas.drawPath(jawPath, p..strokeWidth = 1.3);

    // Small circle at other end
    canvas.drawCircle(Offset(cx - s.width * 0.30, cy - s.height * 0.30), s.width * 0.09, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 3. Hard Hat ───────────────────────────────────────────────────────────

class HardHatIcon extends StatelessWidget {
  final double size;
  final Color color;
  const HardHatIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _HardHatPainter(color));
}

class _HardHatPainter extends CustomPainter {
  final Color color;
  _HardHatPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final cx = s.width / 2;

    // Dome
    final dome = Path()
      ..moveTo(cx - s.width * 0.36, s.height * 0.52)
      ..quadraticBezierTo(cx - s.width * 0.38, s.height * 0.18, cx, s.height * 0.14)
      ..quadraticBezierTo(cx + s.width * 0.38, s.height * 0.18, cx + s.width * 0.36, s.height * 0.52);
    canvas.drawPath(dome, p);

    // Brim
    canvas.drawLine(Offset(cx - s.width * 0.46, s.height * 0.52), Offset(cx + s.width * 0.46, s.height * 0.52), p..strokeWidth = 1.5);

    // Inner band
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, s.height * 0.52), width: s.width * 0.7, height: s.height * 0.2),
      math.pi, math.pi,
      false, p..strokeWidth = 1.0,
    );

    // Chin strap dot
    canvas.drawCircle(Offset(cx - s.width * 0.36, s.height * 0.58), 1.5, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx + s.width * 0.36, s.height * 0.58), 1.5, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 4. Machine / Lathe ────────────────────────────────────────────────────

class MachineIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MachineIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _MachinePainter(color));
}

class _MachinePainter extends CustomPainter {
  final Color color;
  _MachinePainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    // Machine body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.08, s.height * 0.30, s.width * 0.84, s.height * 0.44), const Radius.circular(2)),
      p,
    );

    // Spindle (left circle)
    canvas.drawCircle(Offset(s.width * 0.22, s.height * 0.52), s.width * 0.10, p);

    // Chuck lines
    canvas.drawLine(Offset(s.width * 0.22, s.height * 0.42), Offset(s.width * 0.22, s.height * 0.62), p..strokeWidth = 0.8);
    canvas.drawLine(Offset(s.width * 0.12, s.height * 0.52), Offset(s.width * 0.32, s.height * 0.52), p);

    // Workpiece bar
    canvas.drawLine(Offset(s.width * 0.32, s.height * 0.52), Offset(s.width * 0.74, s.height * 0.52), p..strokeWidth = 2.0..color = color.withOpacity(0.7));

    // Cutting tool triangle
    final tool = Path()
      ..moveTo(s.width * 0.78, s.height * 0.42)
      ..lineTo(s.width * 0.90, s.height * 0.52)
      ..lineTo(s.width * 0.78, s.height * 0.62)
      ..close();
    canvas.drawPath(tool, p..strokeWidth = 1.0..color = color);

    // Base legs
    canvas.drawLine(Offset(s.width * 0.18, s.height * 0.74), Offset(s.width * 0.18, s.height * 0.86), p..strokeWidth = 1.2);
    canvas.drawLine(Offset(s.width * 0.82, s.height * 0.74), Offset(s.width * 0.82, s.height * 0.86), p);
    canvas.drawLine(Offset(s.width * 0.10, s.height * 0.86), Offset(s.width * 0.90, s.height * 0.86), p);

    // Control panel top
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.30, s.height * 0.12, s.width * 0.40, s.height * 0.18), const Radius.circular(2)),
      p..strokeWidth = 1.0,
    );
    canvas.drawCircle(Offset(s.width * 0.44, s.height * 0.21), 2.0, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(s.width * 0.56, s.height * 0.21), 2.0, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 5. Analytics Chart ────────────────────────────────────────────────────

class AnalyticsChartIcon extends StatelessWidget {
  final double size;
  final Color color;
  const AnalyticsChartIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _AnalyticsPainter(color));
}

class _AnalyticsPainter extends CustomPainter {
  final Color color;
  _AnalyticsPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

    // Axes
    canvas.drawLine(Offset(s.width * 0.12, s.height * 0.12), Offset(s.width * 0.12, s.height * 0.82), p);
    canvas.drawLine(Offset(s.width * 0.12, s.height * 0.82), Offset(s.width * 0.90, s.height * 0.82), p);

    // Line chart
    final pts = [
      Offset(s.width * 0.20, s.height * 0.65),
      Offset(s.width * 0.34, s.height * 0.50),
      Offset(s.width * 0.50, s.height * 0.58),
      Offset(s.width * 0.64, s.height * 0.32),
      Offset(s.width * 0.80, s.height * 0.22),
    ];
    final linePath = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final pt in pts.skip(1)) linePath.lineTo(pt.dx, pt.dy);
    canvas.drawPath(linePath, p..strokeWidth = 1.4);

    // Area fill
    final fill = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final pt in pts.skip(1)) fill.lineTo(pt.dx, pt.dy);
    fill.lineTo(pts.last.dx, s.height * 0.82);
    fill.lineTo(pts.first.dx, s.height * 0.82);
    fill.close();
    canvas.drawPath(fill, Paint()..color = color.withOpacity(0.08)..style = PaintingStyle.fill);

    // Dots on line
    for (final pt in pts) {
      canvas.drawCircle(pt, 1.8, Paint()..color = color..style = PaintingStyle.fill);
    }

    // Axis ticks
    for (int i = 0; i < 4; i++) {
      final y = s.height * 0.22 + i * s.height * 0.15;
      canvas.drawLine(Offset(s.width * 0.10, y), Offset(s.width * 0.14, y), p..strokeWidth = 0.8);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 6. Contract Dashboard ─────────────────────────────────────────────────

class ContractDashboardIcon extends StatelessWidget {
  final double size;
  final Color color;
  const ContractDashboardIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _ContractPainter(color));
}

class _ContractPainter extends CustomPainter {
  final Color color;
  _ContractPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    // Document
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.14, s.height * 0.10, s.width * 0.72, s.height * 0.80), const Radius.circular(2)),
      p,
    );

    // Folded corner
    final fold = Path()
      ..moveTo(s.width * 0.68, s.height * 0.10)
      ..lineTo(s.width * 0.86, s.height * 0.28)
      ..lineTo(s.width * 0.68, s.height * 0.28)
      ..close();
    canvas.drawPath(fold, p..color = color.withOpacity(0.5));

    // Text lines
    final lp = Paint()..color = color..strokeWidth = 1.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      final y = s.height * (0.36 + i * 0.11);
      final w = i == 4 ? 0.32 : 0.44;
      canvas.drawLine(Offset(s.width * 0.24, y), Offset(s.width * (0.24 + w), y), lp);
    }

    // Status dot
    canvas.drawCircle(
      Offset(s.width * 0.76, s.height * 0.78),
      3.5,
      Paint()..color = color..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 7. Time Clock ─────────────────────────────────────────────────────────

class TimeClockIcon extends StatelessWidget {
  final double size;
  final Color color;
  const TimeClockIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _TimeClockPainter(color));
}

class _TimeClockPainter extends CustomPainter {
  final Color color;
  _TimeClockPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final cx = s.width / 2;
    final cy = s.height / 2;
    final r = s.width * 0.38;

    // Clock circle
    canvas.drawCircle(Offset(cx, cy), r, p);

    // Hour markers
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6 - math.pi / 2;
      final len = i % 3 == 0 ? 0.12 : 0.07;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * (r - s.width * 0.12), cy + math.sin(angle) * (r - s.width * 0.12)),
        Offset(cx + math.cos(angle) * (r - s.width * len), cy + math.sin(angle) * (r - s.width * len)),
        p..strokeWidth = i % 3 == 0 ? 1.4 : 0.8,
      );
    }

    // Hour hand (10 o'clock)
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + math.cos(-2.09) * r * 0.55, cy + math.sin(-2.09) * r * 0.55),
      p..strokeWidth = 1.8,
    );
    // Minute hand (2 o'clock)
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + math.cos(-0.63) * r * 0.72, cy + math.sin(-0.63) * r * 0.72),
      p..strokeWidth = 1.2,
    );

    // Center dot
    canvas.drawCircle(Offset(cx, cy), 2, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 8. Alert / Warning ───────────────────────────────────────────────────

class AlertWarningIcon extends StatelessWidget {
  final double size;
  final Color color;
  const AlertWarningIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _AlertPainter(color));
}

class _AlertPainter extends CustomPainter {
  final Color color;
  _AlertPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.3..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round;
    final cx = s.width / 2;

    // Triangle
    final tri = Path()
      ..moveTo(cx, s.height * 0.10)
      ..lineTo(s.width * 0.90, s.height * 0.84)
      ..lineTo(s.width * 0.10, s.height * 0.84)
      ..close();
    canvas.drawPath(tri, p);

    // Exclamation stem
    canvas.drawLine(Offset(cx, s.height * 0.36), Offset(cx, s.height * 0.60), p..strokeWidth = 2.0);

    // Exclamation dot
    canvas.drawCircle(Offset(cx, s.height * 0.72), 1.8, Paint()..color = color..style = PaintingStyle.fill);

    // Radiation lines around triangle
    for (int i = 0; i < 3; i++) {
      final angle = math.pi / 6 + i * (2 * math.pi / 3);
      final ox = cx + math.cos(angle) * s.width * 0.44;
      final oy = s.height * 0.50 + math.sin(angle) * s.height * 0.44;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * s.width * 0.36, s.height * 0.50 + math.sin(angle) * s.height * 0.36),
        Offset(ox, oy),
        p..strokeWidth = 0.8..color = color.withOpacity(0.35),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 9. User / Foreman ────────────────────────────────────────────────────

class ForemanIcon extends StatelessWidget {
  final double size;
  final Color color;
  const ForemanIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _ForemanPainter(color));
}

class _ForemanPainter extends CustomPainter {
  final Color color;
  _ForemanPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final cx = s.width / 2;

    // Head
    canvas.drawCircle(Offset(cx, s.height * 0.28), s.width * 0.16, p);

    // Hard hat on head
    final hat = Path()
      ..moveTo(cx - s.width * 0.22, s.height * 0.20)
      ..quadraticBezierTo(cx, s.height * 0.06, cx + s.width * 0.22, s.height * 0.20);
    canvas.drawPath(hat, p);
    canvas.drawLine(Offset(cx - s.width * 0.26, s.height * 0.20), Offset(cx + s.width * 0.26, s.height * 0.20), p);

    // Body / shoulders
    final body = Path()
      ..moveTo(s.width * 0.12, s.height * 0.90)
      ..quadraticBezierTo(s.width * 0.12, s.height * 0.56, cx, s.height * 0.50)
      ..quadraticBezierTo(s.width * 0.88, s.height * 0.56, s.width * 0.88, s.height * 0.90);
    canvas.drawPath(body, p);

    // Vest collar line
    canvas.drawLine(Offset(cx, s.height * 0.50), Offset(cx, s.height * 0.76), p..strokeWidth = 0.8);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 10. Chat / Messaging ─────────────────────────────────────────────────

class ChatIcon extends StatelessWidget {
  final double size;
  final Color color;
  const ChatIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _ChatPainter(color));
}

class _ChatPainter extends CustomPainter {
  final Color color;
  _ChatPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

    // Main bubble
    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.08, s.height * 0.10, s.width * 0.76, s.height * 0.58),
      const Radius.circular(5),
    );
    canvas.drawRRect(bubble, p);

    // Tail
    final tail = Path()
      ..moveTo(s.width * 0.22, s.height * 0.68)
      ..lineTo(s.width * 0.14, s.height * 0.84)
      ..lineTo(s.width * 0.36, s.height * 0.68);
    canvas.drawPath(tail, p);

    // Message dots
    canvas.drawCircle(Offset(s.width * 0.30, s.height * 0.40), 2, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(s.width * 0.46, s.height * 0.40), 2, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(s.width * 0.62, s.height * 0.40), 2, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 11. QR / ID Scanner ─────────────────────────────────────────────────

class QrScannerIcon extends StatelessWidget {
  final double size;
  final Color color;
  const QrScannerIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _QrPainter(color));
}

class _QrPainter extends CustomPainter {
  final Color color;
  _QrPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final fp = Paint()..color = color..style = PaintingStyle.fill;

    // Corner brackets
    void corner(double x, double y, bool flipX, bool flipY) {
      final sx = flipX ? -1.0 : 1.0;
      final sy = flipY ? -1.0 : 1.0;
      canvas.drawLine(Offset(x, y), Offset(x + sx * s.width * 0.18, y), p);
      canvas.drawLine(Offset(x, y), Offset(x, y + sy * s.height * 0.18), p);
    }
    corner(s.width * 0.10, s.height * 0.10, false, false);
    corner(s.width * 0.90, s.height * 0.10, true, false);
    corner(s.width * 0.10, s.height * 0.90, false, true);
    corner(s.width * 0.90, s.height * 0.90, true, true);

    // QR modules (simplified)
    final cells = [
      [0.22, 0.22], [0.34, 0.22], [0.46, 0.22],
      [0.22, 0.34],               [0.46, 0.34],
      [0.22, 0.46], [0.34, 0.46], [0.46, 0.46],
      [0.60, 0.22], [0.72, 0.34],
      [0.60, 0.60], [0.72, 0.60], [0.60, 0.72],
    ];
    for (final c in cells) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(s.width * c[0], s.height * c[1]), width: s.width * 0.08, height: s.height * 0.08),
        fp,
      );
    }

    // Scan line
    canvas.drawLine(
      Offset(s.width * 0.10, s.height * 0.50),
      Offset(s.width * 0.90, s.height * 0.50),
      p..color = color.withOpacity(0.4)..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 12. Checklist ────────────────────────────────────────────────────────

class ChecklistIcon extends StatelessWidget {
  final double size;
  final Color color;
  const ChecklistIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _ChecklistPainter(color));
}

class _ChecklistPainter extends CustomPainter {
  final Color color;
  _ChecklistPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    // Clipboard
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.14, s.height * 0.16, s.width * 0.72, s.height * 0.76), const Radius.circular(2)),
      p,
    );

    // Clip
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.36, s.height * 0.10, s.width * 0.28, s.height * 0.14), const Radius.circular(4)),
      p,
    );

    // Check rows
    final rows = [0.34, 0.50, 0.66, 0.80];
    for (int i = 0; i < rows.length; i++) {
      final y = s.height * rows[i];
      // Checkbox
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s.width * 0.27, y), width: s.width * 0.12, height: s.height * 0.10), const Radius.circular(1)),
        p,
      );
      // Check mark for first two
      if (i < 2) {
        final check = Path()
          ..moveTo(s.width * 0.23, y)
          ..lineTo(s.width * 0.26, y + s.height * 0.04)
          ..lineTo(s.width * 0.31, y - s.height * 0.04);
        canvas.drawPath(check, p..strokeWidth = 1.0);
      }
      // Line
      canvas.drawLine(Offset(s.width * 0.36, y), Offset(s.width * 0.78, y), p..strokeWidth = 0.9..color = color.withOpacity(0.6));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 13. Settings / Gear ──────────────────────────────────────────────────

class SettingsGearIcon extends StatelessWidget {
  final double size;
  final Color color;
  const SettingsGearIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _GearPainter(color));
}

class _GearPainter extends CustomPainter {
  final Color color;
  _GearPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke;
    final cx = s.width / 2;
    final cy = s.height / 2;
    const teeth = 8;
    const innerR = 0.22;
    const outerR = 0.38;
    const toothW = 0.08;

    final path = Path();
    for (int i = 0; i < teeth; i++) {
      final angle = i * 2 * math.pi / teeth;
      final a1 = angle - toothW;
      final a2 = angle + toothW;
      path.lineTo(cx + math.cos(a1) * s.width * innerR, cy + math.sin(a1) * s.height * innerR);
      path.lineTo(cx + math.cos(a1) * s.width * outerR, cy + math.sin(a1) * s.height * outerR);
      path.lineTo(cx + math.cos(a2) * s.width * outerR, cy + math.sin(a2) * s.height * outerR);
      path.lineTo(cx + math.cos(a2) * s.width * innerR, cy + math.sin(a2) * s.height * innerR);
    }
    path.close();
    canvas.drawPath(path, p);

    // Center hole
    canvas.drawCircle(Offset(cx, cy), s.width * 0.12, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 14. Bluetooth ────────────────────────────────────────────────────────

class BluetoothIcon extends StatelessWidget {
  final double size;
  final Color color;
  const BluetoothIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _BluetoothPainter(color));
}

class _BluetoothPainter extends CustomPainter {
  final Color color;
  _BluetoothPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final cx = s.width / 2;

    // Bluetooth symbol
    final bt = Path()
      ..moveTo(cx - s.width * 0.22, s.height * 0.28)
      ..lineTo(cx + s.width * 0.18, s.height * 0.62)
      ..lineTo(cx - s.width * 0.18, s.height * 0.62)
      ..lineTo(cx + s.width * 0.18, s.height * 0.28)
      ..lineTo(cx, s.height * 0.10)
      ..lineTo(cx, s.height * 0.90);
    canvas.drawPath(bt, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 15. Cloud Sync ───────────────────────────────────────────────────────

class CloudSyncIcon extends StatelessWidget {
  final double size;
  final Color color;
  const CloudSyncIcon({super.key, this.size = 24, this.color = Colors.white});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _CloudPainter(color));
}

class _CloudPainter extends CustomPainter {
  final Color color;
  _CloudPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    // Cloud shape
    final cloud = Path()
      ..moveTo(s.width * 0.18, s.height * 0.58)
      ..lineTo(s.width * 0.12, s.height * 0.58)
      ..arcToPoint(Offset(s.width * 0.28, s.height * 0.38), radius: const Radius.circular(20), clockwise: false)
      ..arcToPoint(Offset(s.width * 0.46, s.height * 0.28), radius: const Radius.circular(20), clockwise: false)
      ..arcToPoint(Offset(s.width * 0.70, s.height * 0.34), radius: const Radius.circular(20), clockwise: false)
      ..arcToPoint(Offset(s.width * 0.86, s.height * 0.58), radius: const Radius.circular(20), clockwise: false)
      ..lineTo(s.width * 0.80, s.height * 0.58);
    canvas.drawPath(cloud, p);

    // Sync arrows (circular)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(s.width * 0.50, s.height * 0.74), width: s.width * 0.32, height: s.height * 0.28),
      -math.pi * 0.8, math.pi * 1.4, false, p,
    );
    // Arrow head
    final ah = Path()
      ..moveTo(s.width * 0.60, s.height * 0.66)
      ..lineTo(s.width * 0.66, s.height * 0.73)
      ..lineTo(s.width * 0.58, s.height * 0.78);
    canvas.drawPath(ah, p..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── 16. Battery Indicator ────────────────────────────────────────────────

class BatteryIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double level; // 0.0 to 1.0
  const BatteryIcon({super.key, this.size = 24, this.color = Colors.white, this.level = 0.75});

  @override
  Widget build(BuildContext context) =>
      _IconBase(size: size, color: color, painter: _BatteryPainter(color, level));
}

class _BatteryPainter extends CustomPainter {
  final Color color;
  final double level;
  _BatteryPainter(this.color, this.level);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    // Battery body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.08, s.height * 0.28, s.width * 0.76, s.height * 0.44), const Radius.circular(3)),
      p,
    );

    // Battery tip
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.84, s.height * 0.38, s.width * 0.08, s.height * 0.24), const Radius.circular(2)),
      p,
    );

    // Fill level
    final fillW = s.width * 0.68 * level;
    final fillColor = level > 0.5 ? const Color(0xFF22C55E) : level > 0.2 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.12, s.height * 0.32, fillW, s.height * 0.36), const Radius.circular(2)),
      Paint()..color = fillColor..style = PaintingStyle.fill,
    );

    // Lightning bolt for charging
    if (level > 0.9) {
      final bolt = Path()
        ..moveTo(s.width * 0.50, s.height * 0.34)
        ..lineTo(s.width * 0.42, s.height * 0.50)
        ..lineTo(s.width * 0.50, s.height * 0.50)
        ..lineTo(s.width * 0.42, s.height * 0.66)
        ..lineTo(s.width * 0.58, s.height * 0.48)
        ..lineTo(s.width * 0.50, s.height * 0.48)
        ..close();
      canvas.drawPath(bolt, Paint()..color = Colors.white.withOpacity(0.7)..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
