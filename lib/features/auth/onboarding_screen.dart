import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

// ── Page data model ──────────────────────────────────────────────────────────
class _PageInfo {
  final Color bg1, bg2;
  final String title, subtitle;
  final bool isLast;
  const _PageInfo({
    required this.bg1,
    required this.bg2,
    required this.title,
    required this.subtitle,
    required this.isLast,
  });
}

// ── Main widget ───────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const List<_PageInfo> _pages = [
    _PageInfo(
      bg1: Color(0xFF0D1A3C),
      bg2: Color(0xFF040C1C),
      title: 'Discover Your Style',
      subtitle:
          'Explore the latest fashion for Men, Women,\nand Kids — all in one place.',
      isLast: false,
    ),
    _PageInfo(
      bg1: Color(0xFF580A3C),
      bg2: Color(0xFF28001C),
      title: 'Men, Women & Kids',
      subtitle:
          'Shop separate collections made just for each\nmember of your family.',
      isLast: false,
    ),
    _PageInfo(
      bg1: Color(0xFF4A1A08),
      bg2: Color(0xFF1A0800),
      title: 'Fast & Easy Checkout',
      subtitle:
          'Pay in Sri Lankan Rupees. Order delivered\nright to your door.',
      isLast: true,
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _toLogin();
    }
  }

  void _toLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safePad = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: _pages[_page].bg1,
      body: Stack(
        children: [
          // ── Full-screen page view ────────────────────────────────────────
          PageView(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              _buildPage1(context),
              _buildPage2(context),
              _buildPage3(context),
            ],
          ),

          // ── SKIP button (pages 0 & 1) ────────────────────────────────────
          if (_page < 2)
            Positioned(
              top: safePad.top + 16,
              right: 20,
              child: GestureDetector(
                onTap: _toLogin,
                child: _page == 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
              ),
            ),

          // ── VEXA branding on page 1 ───────────────────────────────────────
          if (_page == 0)
            Positioned(
              top: safePad.top + 20,
              left: 22,
              child: Text(
                'VEXA',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),

          // ── White bottom card ─────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomCard(safePad.bottom),
          ),
        ],
      ),
    );
  }

  // ── Page 1: Fashion woman on dark navy background ─────────────────────────
  Widget _buildPage1(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1A3C), Color(0xFF040C1C)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: sz.height * 0.60,
            child: Image.network(
              'https://images.unsplash.com/photo-1581044777550-4cfa60707c03?w=600&q=80',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF0D1A3C),
                child:
                    const Center(child: Icon(Icons.person, color: Colors.white54, size: 80)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Page 2: Three overlapping fashion cards ────────────────────────────────
  Widget _buildPage2(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF580A3C), Color(0xFF28001C)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // MEN card – left, rotated counter-clockwise
          Positioned(
            left: sz.width * 0.00,
            top: sz.height * 0.10,
            child: Transform.rotate(
              angle: -0.15,
              child: _photoCard(
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=260&q=80',
                'MEN',
                sz.width * 0.33,
                sz.height * 0.30,
              ),
            ),
          ),
          // WOMEN card – center, slight clockwise tilt
          Positioned(
            left: sz.width * 0.27,
            top: sz.height * 0.04,
            child: Transform.rotate(
              angle: 0.04,
              child: _photoCard(
                'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=260&q=80',
                'WOMEN',
                sz.width * 0.37,
                sz.height * 0.36,
              ),
            ),
          ),
          // KIDS card – right, more clockwise tilt
          Positioned(
            right: sz.width * 0.00,
            top: sz.height * 0.13,
            child: Transform.rotate(
              angle: 0.14,
              child: _photoCard(
                'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=400',
                'KIDS',
                sz.width * 0.31,
                sz.height * 0.27,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoCard(String url, String label, double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.network(
            url,
            width: w,
            height: h,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF333355),
              child: Center(
                  child: Icon(Icons.person, color: Colors.white54, size: 30)),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF111111),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Page 3: Shopping bag with LKR badge ───────────────────────────────────
  Widget _buildPage3(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5C2800), Color(0xFF1A0800)],
        ),
      ),
      child: Align(
        alignment: const Alignment(0.0, -0.45),
        child: SizedBox(
          height: sz.height * 0.45,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 176,
                  height: 176,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),
                ),
                // Frosted glass container
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                // LKR badge
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4E60A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'LKR',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1A1A00),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Green checkmark
                Positioned(
                  bottom: 16,
                  right: 20,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom white card (fixed, overlays the image area) ────────────────────
  Widget _buildBottomCard(double bottomSafePad) {
    final info = _pages[_page];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        28,
        20,
        28,
        bottomSafePad > 0 ? bottomSafePad + 12 : 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag-handle indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // AnimatedSwitcher so title/subtitle cross-fades on page change
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Column(
              key: ValueKey(_page),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD4004E),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  info.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF888888),
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Page-indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFD4004E)
                      : const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 22),

          // NEXT / GET STARTED button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4004E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    info.isLast ? 'GET STARTED' : 'NEXT',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),

          // "Already have account? Login" on last page
          if (info.isLast) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _toLogin,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: const Color(0xFF666666)),
                  children: [
                    const TextSpan(text: 'Already have account?  '),
                    TextSpan(
                      text: 'Login',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD4004E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
