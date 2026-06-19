/// # Gädd-header
///
/// Header med gädd-motiv som matchar dumpen.se's varumärke.
/// Innehåller app-titel och sökknapp.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class PikeHeader extends StatelessWidget {
  final VoidCallback? onSearch;

  const PikeHeader({super.key, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1a2332),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Gädd-banner
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Bakgrund med gäddor
                  CustomPaint(
                    painter: _PikePainter(),
                    size: const Size(double.infinity, 120),
                  ),
                  // Innehåll ovanpå
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // D-dumpen monogram
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'D',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'DUMPEN',
                          style: GoogleFonts.jost(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          tooltip: 'Sök',
                          onPressed: onSearch,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Gul accent-linje
            Container(
              height: 3,
              width: double.infinity,
              color: AppColors.accentYellow,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter för gädd-mörk bakgrund med gäddor.
class _PikePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Mörk bakgrund
    final bgPaint = Paint()..color = const Color(0xFF1a2332);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Rita gäddor
    _drawPike(canvas, size, 80, 60, 1.0, -0.15);
    _drawPike(canvas, size, size.width - 100, 40, 0.7, 0.1);
    _drawPike(canvas, size, size.width / 2 + 50, 80, 0.5, -0.2);
  }

  void _drawPike(Canvas canvas, Size size, double cx, double cy, double scale, double rotation) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);
    canvas.scale(scale);

    // Body
    final bodyPaint = Paint()
      ..color = const Color(0xFF4a7c59);
    canvas.drawOval(
      const Rect.fromLTWH(-60, -14, 120, 28),
      bodyPaint,
    );

    // Belly
    final bellyPaint = Paint()
      ..color = const Color(0xFFe8d5a3);
    canvas.drawOval(
      const Rect.fromLTWH(-40, -7, 85, 14),
      bellyPaint,
    );

    // Dorsal fin
    final finPaint = Paint()
      ..color = const Color(0xFF4a7c59);
    final dorsalPath = Path()
      ..moveTo(-45, -14)
      ..lineTo(-25, -35)
      ..lineTo(-5, -30)
      ..lineTo(10, -14)
      ..close();
    canvas.drawPath(dorsalPath, finPaint);

    // Tail
    final tailPaint = Paint()
      ..color = const Color(0xFF3d6b4a).withValues(alpha: 0.7);
    final tailPath = Path()
      ..moveTo(55, -10)
      ..lineTo(85, -22)
      ..lineTo(78, 0)
      ..lineTo(85, 22)
      ..lineTo(55, 10)
      ..close();
    canvas.drawPath(tailPath, tailPaint);

    // Pectoral fin
    final pectoralPaint = Paint()
      ..color = const Color(0xFF5a8c69).withValues(alpha: 0.5);
    final pectoralPath = Path()
      ..moveTo(20, 10)
      ..lineTo(38, 28)
      ..lineTo(15, 22)
      ..lineTo(5, 12)
      ..close();
    canvas.drawPath(pectoralPath, pectoralPaint);

    // Eye
    final eyePaint = Paint()..color = const Color(0xFF1a1a1a);
    canvas.drawCircle(const Offset(-40, -3), 5, eyePaint);
    final eyeHighlight = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(const Offset(-41.5, -4.5), 2, eyeHighlight);

    // Spots
    final spotPaint = Paint()
      ..color = const Color(0xFF8ab89a).withValues(alpha: 0.4);
    canvas.drawCircle(const Offset(-15, -8), 2.5, spotPaint);
    canvas.drawCircle(const Offset(5, -10), 2, spotPaint);
    canvas.drawCircle(const Offset(25, -7), 2.5, spotPaint);
    canvas.drawCircle(const Offset(-25, 3), 2, spotPaint);
    canvas.drawCircle(const Offset(10, 4), 2, spotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
