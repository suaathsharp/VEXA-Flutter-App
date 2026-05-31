import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────────────────────────────────────────────────────
//  VEXA LOGO
//  Matches the Figma design:
//  • Golden amber "V" chevron drawn with CustomPaint (not text)
//  • Horizontal rule: red accent left + dark right
//  • "VEXA" bold white + "Fashion for Every Story" subtitle
// ──────────────────────────────────────────────────────────────────────────

class VexaLogo extends StatelessWidget {
  /// When [markOnly] is true, renders just the V-mark + rule (no text).
  /// When false (default), renders the full logo (mark + text).
  final bool markOnly;

  /// Scale multiplier — 1.0 = default splash size.
  final double size;

  const VexaLogo({
    super.key,
    this.markOnly = false,
    this.size = 1.0,
    // Legacy params kept for API compatibility — unused internally
    bool isIsolatedV = false,
    bool showText = true,
    Color? color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── V Chevron ───────────────────────────────────────────────────────
        SizedBox(
          width: 56 * size,
          height: 38 * size,
          child: CustomPaint(painter: _VChevronPainter(size: size)),
        ),

        SizedBox(height: 6 * size),

        // ── Horizontal rule  (red left | dark right) ────────────────────────
        SizedBox(
          width: 120 * size,
          height: 2.5 * size,
          child: CustomPaint(painter: _RulePainter()),
        ),

        if (!markOnly) ...[
          SizedBox(height: 22 * size),

          // ── "VEXA" ─────────────────────────────────────────────────────────
          Text(
            'VEXA',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 34 * size,
              fontWeight: FontWeight.w800,
              letterSpacing: 8 * size,
              height: 1.0,
            ),
          ),

          SizedBox(height: 8 * size),

          // ── Tagline ────────────────────────────────────────────────────────
          Text(
            'Fashion for Every Story',
            style: GoogleFonts.poppins(
              color: const Color(0xFFAAAAAA),
              fontSize: 13 * size,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
//  V CHEVRON PAINTER  —  golden amber tick/V shape
// ──────────────────────────────────────────────────────────────────────────
class _VChevronPainter extends CustomPainter {
  final double size;
  const _VChevronPainter({required this.size});

  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..color = const Color(0xFFF5A623) // golden amber
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.miter;

    // Thick V chevron — two filled triangular arms
    // Left arm  (top-left → bottom-center)
    // Right arm (bottom-center → top-right)
    final double cx = s.width / 2;
    final double cy = s.height;
    final double thick = 9.0 * size;

    final path = Path();
    // Left arm
    path.moveTo(0, 0);
    path.lineTo(thick, 0);
    path.lineTo(cx, cy - thick * 0.4);
    path.lineTo(cx, cy);
    path.lineTo(0, 0);

    // Right arm
    path.moveTo(s.width, 0);
    path.lineTo(s.width - thick, 0);
    path.lineTo(cx, cy - thick * 0.4);
    path.lineTo(cx, cy);
    path.lineTo(s.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ──────────────────────────────────────────────────────────────────────────
//  RULE PAINTER  —  red left segment + dark right segment
// ──────────────────────────────────────────────────────────────────────────
class _RulePainter extends CustomPainter {
  const _RulePainter();

  @override
  void paint(Canvas canvas, Size s) {
    final redPaint = Paint()
      ..color = const Color(0xFFE8365D)
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color = const Color(0xFF3A3A4A)
      ..style = PaintingStyle.fill;

    // Left red accent — ~30% of width
    final double split = s.width * 0.30;
    canvas.drawRect(Rect.fromLTWH(0, 0, split, s.height), redPaint);
    // Right dark segment — remaining 70%
    canvas.drawRect(Rect.fromLTWH(split, 0, s.width - split, s.height), darkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
