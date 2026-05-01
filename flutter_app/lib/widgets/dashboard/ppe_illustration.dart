import 'dart:math' as math;
import 'package:flutter/material.dart';

class PpeIllustration extends StatelessWidget {
  final double width;
  final double height;

  const PpeIllustration({super.key, this.width = 280, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _PpePainter()),
    );
  }
}

class _PpePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height * 0.88;

    // Ground line
    final groundPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, groundY), Offset(size.width, groundY), groundPaint);

    // Ground glow
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, Colors.white.withOpacity(0.06), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, groundY, size.width, 8));
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.width, 8), glowPaint);

    _drawHardhat(canvas, Offset(size.width * 0.18, groundY));
    _drawGoggles(canvas, Offset(size.width * 0.50, groundY));
    _drawGloves(canvas, Offset(size.width * 0.82, groundY));

    // Labels
    _drawLabel(canvas, 'Hard Hat', Offset(size.width * 0.18, groundY + 10));
    _drawLabel(canvas, 'Goggles', Offset(size.width * 0.50, groundY + 10));
    _drawLabel(canvas, 'Gloves', Offset(size.width * 0.82, groundY + 10));
  }

  void _drawHardhat(Canvas canvas, Offset base) {
    const color = Color(0xFFF59E0B);
    const brimColor = Color(0xFFB45309);

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy - 1), width: 52, height: 8),
      Paint()..color = Colors.black.withOpacity(0.25)..style = PaintingStyle.fill,
    );

    // Dome
    final domePaint = Paint()..style = PaintingStyle.fill
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.5),
        colors: [Color(0xFFFCD34D), color],
      ).createShader(Rect.fromCenter(center: Offset(base.dx, base.dy - 30), width: 56, height: 48));

    final domePath = Path();
    domePath.moveTo(base.dx - 26, base.dy - 12);
    domePath.quadraticBezierTo(base.dx - 28, base.dy - 48, base.dx, base.dy - 52);
    domePath.quadraticBezierTo(base.dx + 28, base.dy - 48, base.dx + 26, base.dy - 12);
    domePath.close();
    canvas.drawPath(domePath, domePaint);

    // Rib stripe
    final ribPaint = Paint()..color = Colors.white.withOpacity(0.15)..strokeWidth = 2..style = PaintingStyle.stroke;
    final ribPath = Path();
    ribPath.moveTo(base.dx - 10, base.dy - 50);
    ribPath.quadraticBezierTo(base.dx - 5, base.dy - 20, base.dx - 8, base.dy - 12);
    canvas.drawPath(ribPath, ribPaint);

    // Brim
    final brimPaint = Paint()..color = brimColor..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 11), width: 64, height: 7),
        const Radius.circular(3),
      ),
      brimPaint,
    );

    // Brim highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 13), width: 64, height: 2),
        const Radius.circular(1),
      ),
      Paint()..color = Colors.white.withOpacity(0.2),
    );
  }

  void _drawGoggles(Canvas canvas, Offset base) {
    const lensColor = Color(0xFF60A5FA);
    const frameColor = Color(0xFF1E3A5F);

    final leftC = Offset(base.dx - 17, base.dy - 28);
    final rightC = Offset(base.dx + 17, base.dy - 28);

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy - 1), width: 56, height: 7),
      Paint()..color = Colors.black.withOpacity(0.2),
    );

    // Strap
    final strapPaint = Paint()..color = const Color(0xFF374151)..strokeWidth = 4..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(leftC.dx - 14, leftC.dy), Offset(leftC.dx - 14, base.dy - 10), strapPaint);
    canvas.drawLine(Offset(rightC.dx + 14, rightC.dy), Offset(rightC.dx + 14, base.dy - 10), strapPaint);

    // Lens frames
    final framePaint = Paint()..color = frameColor..style = PaintingStyle.fill;
    canvas.drawCircle(leftC, 14, framePaint);
    canvas.drawCircle(rightC, 14, framePaint);

    // Lenses
    final lensPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: [lensColor.withOpacity(0.9), lensColor.withOpacity(0.4)],
      ).createShader(Rect.fromCircle(center: leftC, radius: 12));
    canvas.drawCircle(leftC, 12, lensPaint);
    canvas.drawCircle(
      rightC,
      12,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: [lensColor.withOpacity(0.9), lensColor.withOpacity(0.4)],
        ).createShader(Rect.fromCircle(center: rightC, radius: 12)),
    );

    // Lens glare
    canvas.drawCircle(Offset(leftC.dx - 4, leftC.dy - 4), 3, Paint()..color = Colors.white.withOpacity(0.4));
    canvas.drawCircle(Offset(rightC.dx - 4, rightC.dy - 4), 3, Paint()..color = Colors.white.withOpacity(0.4));

    // Bridge
    final bridgePaint = Paint()..color = frameColor..strokeWidth = 5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(base.dx - 3, base.dy - 28), Offset(base.dx + 3, base.dy - 28), bridgePaint);
  }

  void _drawGloves(Canvas canvas, Offset base) {
    const color = Color(0xFF22C55E);
    const darkColor = Color(0xFF15803D);

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy - 1), width: 52, height: 7),
      Paint()..color = Colors.black.withOpacity(0.2),
    );

    _drawSingleGlove(canvas, Offset(base.dx - 14, base.dy), color, darkColor, true);
    _drawSingleGlove(canvas, Offset(base.dx + 14, base.dy), color, darkColor, false);
  }

  void _drawSingleGlove(Canvas canvas, Offset base, Color color, Color dark, bool isLeft) {
    final flip = isLeft ? -1.0 : 1.0;

    // Cuff
    final cuffPaint = Paint()..color = dark..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 8), width: 20, height: 12),
        const Radius.circular(3),
      ),
      cuffPaint,
    );

    // Cuff stripe
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, base.dy - 9), width: 20, height: 2),
      Paint()..color = Colors.white.withOpacity(0.2),
    );

    // Palm
    final palmPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, dark],
      ).createShader(Rect.fromCenter(center: Offset(base.dx, base.dy - 28), width: 20, height: 32));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(base.dx, base.dy - 28), width: 18, height: 26),
        const Radius.circular(5),
      ),
      palmPaint,
    );

    // Fingers (3 knuckle lines)
    final knucklePaint = Paint()..color = dark.withOpacity(0.5)..strokeWidth = 1..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      final y = base.dy - 22 - (i * 6.0);
      canvas.drawLine(Offset(base.dx - 6, y), Offset(base.dx + 6, y), knucklePaint);
    }

    // Thumb
    final thumbPath = Path();
    thumbPath.addOval(Rect.fromCenter(
      center: Offset(base.dx + flip * 12, base.dy - 32),
      width: 10,
      height: 16,
    ));
    canvas.drawPath(thumbPath, Paint()..color = color);

    // Thumb highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx + flip * 10, base.dy - 35), width: 4, height: 6),
      Paint()..color = Colors.white.withOpacity(0.2),
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset position) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.35),
          fontSize: 9,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(position.dx - tp.width / 2, position.dy));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
