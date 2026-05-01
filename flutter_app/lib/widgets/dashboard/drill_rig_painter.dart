import 'dart:math' as math;
import 'package:flutter/material.dart';

class DrillRigBackground extends StatelessWidget {
  const DrillRigBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DrillRigPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _DrillRigPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawGradientBackground(canvas, size);
    _drawGroundPlane(canvas, size);
    _drawReflection(canvas, size);
    _drawDrillRig(canvas, size);
    _drawAtmosphere(canvas, size);
  }

  void _drawGradientBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF060B18),
          Color(0xFF0A1628),
          Color(0xFF0D1F3C),
          Color(0xFF091420),
        ],
        stops: [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
  }

  void _drawGroundPlane(Canvas canvas, Size size) {
    final groundY = size.height * 0.68;

    // Ground surface
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1A2744).withOpacity(0.9),
          const Color(0xFF0A1020).withOpacity(0.95),
        ],
      ).createShader(Rect.fromLTWH(0, groundY, size.width, size.height - groundY));
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.width, size.height - groundY), groundPaint);

    // Ground horizon glow
    final horizonPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF1E40AF).withOpacity(0.15),
          const Color(0xFF3B82F6).withOpacity(0.25),
          const Color(0xFF1E40AF).withOpacity(0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, groundY - 1, size.width, 3));
    canvas.drawRect(Rect.fromLTWH(0, groundY - 1, size.width, 3), horizonPaint);

    // Ground grid lines (perspective)
    final gridPaint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final vp = Offset(size.width * 0.5, groundY);

    // Horizontal grid lines
    for (int i = 1; i <= 6; i++) {
      final y = groundY + (size.height - groundY) * (i / 6.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Converging vertical lines
    for (int i = -6; i <= 6; i++) {
      final endX = size.width * 0.5 + i * size.width * 0.16;
      canvas.drawLine(vp, Offset(endX, size.height), gridPaint..color = const Color(0xFF1E3A5F).withOpacity(0.2));
    }
  }

  void _drawDrillRig(Canvas canvas, Size size) {
    final groundY = size.height * 0.68;
    final rigCenterX = size.width * 0.62;

    // Scale rig to screen
    final scale = size.width / 800.0;

    canvas.save();
    canvas.translate(rigCenterX, groundY);
    canvas.scale(scale, scale);

    _drawTracks(canvas);
    _drawBody(canvas);
    _drawBoom(canvas);
    _drawDrillMast(canvas);
    _drawCabinDetails(canvas);
    _drawLights(canvas);

    canvas.restore();
  }

  void _drawTracks(Canvas canvas) {
    final trackPaint = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill;
    final trackHighlight = Paint()..color = const Color(0xFF334155)..style = PaintingStyle.fill;

    // Left track
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-160, -28, 120, 28), const Radius.circular(14)),
      trackPaint,
    );
    // Left track highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-158, -28, 116, 8), const Radius.circular(4)),
      trackHighlight,
    );

    // Right track
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(40, -28, 120, 28), const Radius.circular(14)),
      trackPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(42, -28, 116, 8), const Radius.circular(4)),
      trackHighlight,
    );

    // Track links
    final linkPaint = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 2..style = PaintingStyle.stroke;
    for (int i = 0; i < 8; i++) {
      final x = -156.0 + i * 15;
      canvas.drawLine(Offset(x, -26), Offset(x, -2), linkPaint);
      canvas.drawLine(Offset(44 + i * 15, -26), Offset(44 + i * 15, -2), linkPaint);
    }
  }

  void _drawBody(Canvas canvas) {
    // Main chassis
    final chassisPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(-145, -90, 290, 90));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-145, -90, 290, 70), const Radius.circular(6)),
      chassisPaint,
    );

    // Cabin
    final cabinPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF475569), Color(0xFF334155), Color(0xFF1E293B)],
      ).createShader(Rect.fromLTWH(-130, -160, 130, 75));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-130, -160, 130, 75), const Radius.circular(8)),
      cabinPaint,
    );

    // Cabin window
    final windowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF60A5FA).withOpacity(0.6),
          const Color(0xFF1E40AF).withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(-118, -148, 100, 50));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-118, -148, 100, 50), const Radius.circular(4)),
      windowPaint,
    );

    // Window reflection
    canvas.drawLine(
      const Offset(-100, -148),
      const Offset(-68, -98),
      Paint()..color = Colors.white.withOpacity(0.12)..strokeWidth = 8,
    );

    // Sandvik brand stripe (yellow-orange)
    canvas.drawRect(
      Rect.fromLTWH(-145, -95, 290, 6),
      Paint()..color = const Color(0xFFF59E0B).withOpacity(0.8),
    );
    canvas.drawRect(
      Rect.fromLTWH(-145, -89, 290, 3),
      Paint()..color = const Color(0xFFD97706).withOpacity(0.6),
    );

    // Equipment boxes on right side
    final boxPaint = Paint()..color = const Color(0xFF263452)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10, -140, 100, 55), const Radius.circular(4)), boxPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10, -78, 100, 18), const Radius.circular(3)), boxPaint);

    // Box vents
    final ventPaint = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 1..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(Offset(18 + i * 14.0, -135), Offset(18 + i * 14.0, -92), ventPaint);
    }
  }

  void _drawBoom(Canvas canvas) {
    // Boom arm pivot point
    const pivotX = -10.0;
    const pivotY = -155.0;

    // Boom angle (reaching up-right)
    const boomAngle = -0.72; // radians
    const boomLength = 320.0;

    final boomEndX = pivotX + math.cos(boomAngle) * boomLength;
    final boomEndY = pivotY + math.sin(boomAngle) * boomLength;

    // Boom shadow
    canvas.drawLine(
      Offset(pivotX + 3, pivotY + 3),
      Offset(boomEndX + 3, boomEndY + 3),
      Paint()..color = Colors.black.withOpacity(0.3)..strokeWidth = 22..strokeCap = StrokeCap.round,
    );

    // Main boom tube
    canvas.drawLine(
      Offset(pivotX, pivotY),
      Offset(boomEndX, boomEndY),
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFF475569), const Color(0xFF334155), const Color(0xFF1E3A5F)],
        ).createShader(Rect.fromPoints(Offset(pivotX, pivotY), Offset(boomEndX, boomEndY)))
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Boom highlight edge
    canvas.drawLine(
      Offset(pivotX, pivotY),
      Offset(boomEndX, boomEndY),
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Hydraulic cylinder
    final cylAngle = boomAngle + 0.35;
    final cylLen = 180.0;
    canvas.drawLine(
      Offset(pivotX - 20, pivotY + 30),
      Offset(pivotX - 20 + math.cos(cylAngle) * cylLen, pivotY + 30 + math.sin(cylAngle) * cylLen),
      Paint()..color = const Color(0xFF64748B)..strokeWidth = 8..strokeCap = StrokeCap.round,
    );

    // Drill mast at boom end
    canvas.save();
    canvas.translate(boomEndX, boomEndY);
    canvas.rotate(boomAngle + math.pi / 2 - 0.15);
    _drawMastAtEnd(canvas);
    canvas.restore();

    // Boom joint circle
    canvas.drawCircle(
      Offset(pivotX, pivotY),
      12,
      Paint()..color = const Color(0xFF64748B)..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(pivotX, pivotY),
      6,
      Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.fill,
    );
  }

  void _drawMastAtEnd(Canvas canvas) {
    // Drill mast (vertical guide)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-8, -120, 16, 240), const Radius.circular(3)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF1E293B)],
        ).createShader(Rect.fromLTWH(-8, -120, 16, 240)),
    );

    // Drill bit
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-5, 100, 10, 40), const Radius.circular(2)),
      Paint()..color = const Color(0xFF475569),
    );
    final bitPath = Path()
      ..moveTo(-7, 140)
      ..lineTo(0, 160)
      ..lineTo(7, 140)
      ..close();
    canvas.drawPath(bitPath, Paint()..color = const Color(0xFFF59E0B));

    // Feed rail guides
    final guidePaint = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-14, -110), const Offset(-14, 110), guidePaint);
    canvas.drawLine(const Offset(14, -110), const Offset(14, 110), guidePaint);

    // Dust collector hood
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-20, 85, 40, 20), const Radius.circular(4)),
      Paint()..color = const Color(0xFF263452),
    );
  }

  void _drawDrillMast(Canvas canvas) {
    // Additional front mast detail on the body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(110, -200, 12, 120), const Radius.circular(3)),
      Paint()..color = const Color(0xFF1E293B),
    );
  }

  void _drawCabinDetails(Canvas canvas) {
    // Steps
    final stepPaint = Paint()..color = const Color(0xFF334155)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(-145, -45, 20, 5), stepPaint);
    canvas.drawRect(Rect.fromLTWH(-155, -38, 20, 5), stepPaint);
    canvas.drawRect(Rect.fromLTWH(-165, -31, 20, 5), stepPaint);

    // Handrail
    canvas.drawLine(
      const Offset(-148, -45),
      const Offset(-148, -85),
      Paint()..color = const Color(0xFFF59E0B).withOpacity(0.7)..strokeWidth = 2,
    );

    // Warning lights on top
    canvas.drawCircle(
      const Offset(-90, -163),
      5,
      Paint()..color = const Color(0xFFF59E0B).withOpacity(0.9),
    );
    canvas.drawCircle(
      const Offset(-90, -163),
      8,
      Paint()..color = const Color(0xFFF59E0B).withOpacity(0.2),
    );
  }

  void _drawLights(Canvas canvas) {
    // Headlights
    final lightPaint = Paint()..color = const Color(0xFFDFE9FF).withOpacity(0.9)..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: const Offset(-135, -75), width: 14, height: 10), lightPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-135, -60), width: 14, height: 10), lightPaint);

    // Light beams
    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFFDFE9FF).withOpacity(0.08), Colors.transparent],
      ).createShader(Rect.fromLTWH(-135, -80, -120, 60));
    final beamPath = Path()
      ..moveTo(-128, -78)
      ..lineTo(-260, -40)
      ..lineTo(-260, -30)
      ..lineTo(-128, -58)
      ..close();
    canvas.drawPath(beamPath, beamPaint);
  }

  void _drawReflection(Canvas canvas, Size size) {
    final groundY = size.height * 0.68;

    // Mirror reflection below ground
    canvas.save();
    canvas.translate(0, groundY * 2);
    canvas.scale(1, -1);

    // Faded reflection layer
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.85)],
        ).createShader(Rect.fromLTWH(0, groundY, size.width, size.height - groundY)),
    );

    final rigCenterX = size.width * 0.62;
    final scale = size.width / 800.0;
    canvas.translate(rigCenterX, groundY);
    canvas.scale(scale, scale);
    _drawBody(canvas);
    _drawBoom(canvas);
    _drawTracks(canvas);
    canvas.restore();
    canvas.restore();
  }

  void _drawAtmosphere(Canvas canvas, Size size) {
    // Dust particles / atmosphere haze
    final hazePaint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final rng = math.Random(42);
    for (int i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.7;
      final r = rng.nextDouble() * 2 + 0.5;
      canvas.drawCircle(Offset(x, y), r, hazePaint..color = Colors.white.withOpacity(rng.nextDouble() * 0.06));
    }

    // Top vignette
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
