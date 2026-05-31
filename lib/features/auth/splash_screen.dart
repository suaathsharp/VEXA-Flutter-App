import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/datastore/app_data_store.dart';
import 'package:flutter_application_1/core/layout/main_shell.dart';
import 'package:flutter_application_1/core/widgets/vexa_logo.dart';
import 'package:flutter_application_1/features/auth/onboarding_screen.dart';

// ──────────────────────────────────────────────────────────────────────────
//  SPLASH SCREEN  —  Matches Figma exactly:
//
//  Phase 1 (0→500ms)  : V-mark + rule fade + scale in
//  Phase 2 (400→900ms): "VEXA" text slides up + fades in
//  Phase 3 (700→1100ms): Tagline slides up + fades in
//  Hold 800ms → fade-out → navigate to Onboarding
// ──────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Mark (V + rule) ───────────────────────────────────────────────────────
  late final AnimationController _markCtrl;
  late final Animation<double> _markFade;
  late final Animation<double> _markScale;

  // ── "VEXA" text ───────────────────────────────────────────────────────────
  late final AnimationController _textCtrl;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  // ── Tagline ───────────────────────────────────────────────────────────────
  late final AnimationController _tagCtrl;
  late final Animation<double> _tagFade;
  late final Animation<Offset> _tagSlide;

  // ── Exit fade ─────────────────────────────────────────────────────────────
  late final AnimationController _exitCtrl;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    // ── 1. Mark ──────────────────────────────────────────────────────────────
    _markCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _markFade = CurvedAnimation(parent: _markCtrl, curve: Curves.easeOut);
    _markScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _markCtrl, curve: Curves.easeOutBack),
    );

    // ── 2. Text ───────────────────────────────────────────────────────────────
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    // ── 3. Tagline ────────────────────────────────────────────────────────────
    _tagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _tagFade = CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut);
    _tagSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOutCubic));

    // ── 4. Exit ───────────────────────────────────────────────────────────────
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // Phase 1 — mark animates in
    _markCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    // Phase 2 — "VEXA" slides up
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    // Phase 3 — tagline slides up
    _tagCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // Phase 4 — exit fade
    await _exitCtrl.forward();
    if (!mounted) return;

    final store = Provider.of<AppDataStore>(context, listen: false);
    final nextScreen = (store.user.id != 'guest')
        ? const MainShell()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => nextScreen,
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _markCtrl.dispose();
    _textCtrl.dispose();
    _tagCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: AnimatedBuilder(
        animation: _exitFade,
        builder: (_, child) => Opacity(opacity: _exitFade.value, child: child),
        child: Stack(
          children: [
            // ── Subtle bottom-left triangle decoration (from design) ──────────
            Positioned(
              bottom: 0,
              left: 0,
              child: CustomPaint(
                size: const Size(110, 70),
                painter: _TrianglePainter(),
              ),
            ),

            // ── Center content ────────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // V-mark + rule (scale + fade in)
                  ScaleTransition(
                    scale: _markScale,
                    child: FadeTransition(
                      opacity: _markFade,
                      child: const VexaLogo(markOnly: true, size: 1.0),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // "VEXA" slides up
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: _vexaText(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline slides up
                  SlideTransition(
                    position: _tagSlide,
                    child: FadeTransition(
                      opacity: _tagFade,
                      child: _tagline(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vexaText() => const Text(
        'VEXA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: 8,
          height: 1.0,
        ),
      );

  Widget _tagline() => const Text(
        'Fashion for Every Story',
        style: TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
        ),
      );
}

// ──────────────────────────────────────────────────────────────────────────
//  Subtle bottom-left corner triangle (from Figma design)
// ──────────────────────────────────────────────────────────────────────────
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
