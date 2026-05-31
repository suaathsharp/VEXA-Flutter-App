import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/datastore/app_data_store.dart';
import 'signup_screen.dart';
import 'package:flutter_application_1/core/layout/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    
    try {
      final store = Provider.of<AppDataStore>(context, listen: false);
      final success = await store.signIn(_emailCtrl.text.trim(), _passCtrl.text);
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully logged in!', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 400),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFD4004E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final store = Provider.of<AppDataStore>(context, listen: false);
      final success = await store.signInWithGoogle();
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully logged in with Google!', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 400),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFD4004E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _phoneSignInSheet() {
    final phoneCtrl = TextEditingController(text: '+94');
    final codeCtrl = TextEditingController();
    String? verificationId;
    bool smsSent = false;
    bool sheetLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 28,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 32,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 46, height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  smsSent ? 'Verification Code' : 'Phone Authentication',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  smsSent
                      ? 'Enter the 6-digit code sent to your mobile.'
                      : 'Enter your phone number with country code.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 24),
                if (!smsSent) ...[
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF333333)),
                    decoration: InputDecoration(
                      hintText: '+94 77 123 4567',
                      hintStyle: GoogleFonts.poppins(color: const Color(0xFFAAAAAA), fontSize: 14),
                      prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFF888888), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4004E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: sheetLoading
                          ? null
                          : () async {
                              setSheetState(() => sheetLoading = true);
                              try {
                                final store = Provider.of<AppDataStore>(context, listen: false);
                                await store.verifyPhoneNumber(
                                  phoneCtrl.text.trim(),
                                  onCodeSent: (vId) {
                                    setSheetState(() {
                                      verificationId = vId;
                                      smsSent = true;
                                      sheetLoading = false;
                                    });
                                  },
                                  onError: (err) {
                                    setSheetState(() => sheetLoading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(err, style: GoogleFonts.poppins()),
                                        backgroundColor: const Color(0xFFD4004E),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  },
                                );
                              } catch (e) {
                                setSheetState(() => sheetLoading = false);
                              }
                            },
                      child: sheetLoading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              'SEND CODE',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1),
                            ),
                    ),
                  ),
                ] else ...[
                  TextFormField(
                    controller: codeCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF333333)),
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit OTP',
                      hintStyle: GoogleFonts.poppins(color: const Color(0xFFAAAAAA), fontSize: 14),
                      prefixIcon: const Icon(Icons.security_rounded, color: Color(0xFF888888), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4004E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: sheetLoading
                          ? null
                          : () async {
                              setSheetState(() => sheetLoading = true);
                              try {
                                final store = Provider.of<AppDataStore>(context, listen: false);
                                final success = await store.signInWithPhoneNumber(
                                  verificationId!,
                                  codeCtrl.text.trim(),
                                );
                                if (success) {
                                  Navigator.pop(ctx); // Close sheet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Successfully logged in!', style: GoogleFonts.poppins()),
                                      backgroundColor: const Color(0xFF22C55E),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MainShell()),
                                    (route) => false,
                                  );
                                } else {
                                  setSheetState(() => sheetLoading = false);
                                }
                              } catch (e) {
                                setSheetState(() => sheetLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString(), style: GoogleFonts.poppins()),
                                    backgroundColor: const Color(0xFFD4004E),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                      child: sheetLoading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              'VERIFY & LOGIN',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _forgotPassword() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Reset Password',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter your email address',
            hintStyle:
                GoogleFonts.poppins(color: const Color(0xFFAAAAAA), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: const Color(0xFF888888))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4004E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password reset link sent!',
                      style: GoogleFonts.poppins()),
                  backgroundColor: const Color(0xFFD4004E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text('SEND',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 28,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Form(
                key: _formKey,
                child: _buildFormContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dark gradient header ──────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final padTop = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: padTop + 28, bottom: 36, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF180826), Color(0xFF2D1042)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Golden V circle
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFC8A94E),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC8A94E).withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'V',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'VEXA',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Welcome Back 👋',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Login to continue shopping',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.70),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Form content ──────────────────────────────────────────────────────────
  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login to Your Account',
          style: GoogleFonts.poppins(
            color: const Color(0xFFD4004E),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),

        // Email field
        _buildInputField(
          controller: _emailCtrl,
          hint: 'Email Address',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!v.contains('@') || !v.contains('.')) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),

        // Password field
        _buildInputField(
          controller: _passCtrl,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: _obscure,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF888888),
              size: 20,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 6) return 'Minimum 6 characters';
            return null;
          },
        ),

        // Forgot Password link
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _forgotPassword,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD4004E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),

        // LOGIN button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4004E),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFFD4004E).withOpacity(0.6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    'LOGIN',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // OR CONTINUE WITH divider
        Row(
          children: [
            const Expanded(
                child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR CONTINUE WITH',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFAAAAAA),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Expanded(
                child: Divider(color: Color(0xFFE0E0E0), thickness: 1)),
          ],
        ),
        const SizedBox(height: 18),

        // Continue with Google button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: _loading ? null : _googleSignIn,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              backgroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGoogleIcon(),
                const SizedBox(width: 10),
                Text(
                  'Continue with Google',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF333333),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Continue with Phone button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: _loading ? null : _phoneSignInSheet,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              backgroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_iphone_rounded, color: Color(0xFF333333), size: 20),
                const SizedBox(width: 10),
                Text(
                  'Continue with Phone',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF333333),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Sign Up navigation link
        Center(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const SignupScreen(),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF666666)),
                children: [
                  const TextSpan(text: "Don't have an account?  "),
                  TextSpan(
                    text: 'Sign Up',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD4004E),
                      fontWeight: FontWeight.w600,
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

  // ── Input field helper ────────────────────────────────────────────────────
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(
          fontSize: 14, color: const Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
            color: const Color(0xFFAAAAAA), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF888888), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFD4004E), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // ── Google icon ───────────────────────────────────────────────────────────
  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 22,
      height: 22,
      child: Image.network(
        'https://img.icons8.com/color/48/google-logo.png',
        width: 22,
        height: 22,
        errorBuilder: (_, __, ___) => const Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
