import 'package:flutter/material.dart';

/// Custom painter for the ZussGo logo.
/// Two person silhouettes connected by a mint arc,
/// travel route below, small plane at top.
class ZussGoLogoPainter extends CustomPainter {
  final Color mintColor;

  ZussGoLogoPainter({required this.mintColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // ── Travel route ──
    final routePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path();
    routePath.moveTo(center.dx - 18, center.dy + 8);
    routePath.quadraticBezierTo(center.dx, center.dy - 8, center.dx + 18, center.dy + 8);
    canvas.drawPath(routePath, routePaint);

    // ── Map pin dots ──
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 18, center.dy + 8), 2.5, dotPaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 8), 2.5, dotPaint);

    // ── Person 1 (left) ──
    final p1 = Paint()..color = Colors.white.withValues(alpha: 0.9)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 14, center.dy - 14), 6.5, p1);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx - 14, center.dy + 0), width: 13, height: 10),
      const Radius.circular(4),
    ), p1);

    // ── Person 2 (right) ──
    final p2 = Paint()..color = Colors.white.withValues(alpha: 0.7)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx + 14, center.dy - 14), 6.5, p2);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx + 14, center.dy + 0), width: 13, height: 10),
      const Radius.circular(4),
    ), p2);

    // ── Mint connection arc ──
    final arcPaint = Paint()
      ..color = mintColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final arcPath = Path();
    arcPath.moveTo(center.dx - 6, center.dy - 10);
    arcPath.quadraticBezierTo(center.dx, center.dy - 20, center.dx + 6, center.dy - 10);
    canvas.drawPath(arcPath, arcPaint);

    // ── Small plane ──
    final planePaint = Paint()..color = Colors.white.withValues(alpha: 0.8)..style = PaintingStyle.fill;
    final planePath = Path();
    planePath.moveTo(center.dx - 4, center.dy - 21);
    planePath.lineTo(center.dx + 4, center.dy - 19);
    planePath.lineTo(center.dx - 2, center.dy - 17);
    planePath.close();
    canvas.drawPath(planePath, planePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
