import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/datastore/app_data_store.dart';
import 'package:flutter_application_1/core/layout/main_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  // State
  String _gender = 'Male';
  bool _agreed = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  DateTime? _dob;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime(2010),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFD4004E)),
          buttonTheme:
              const ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  // ── Create account ────────────────────────────────────────────────────────
  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please agree to Terms & Privacy Policy', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFD4004E),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    
    try {
      final store = Provider.of<AppDataStore>(context, listen: false);
      final success = await store.signUp(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
        phone: _phoneCtrl.text.trim(),
      );
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully. Please login to continue.', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        // Pop route to cleanly return to Login Screen
        Navigator.pop(context);
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

  Future<void> _googleSignUp() async {
    setState(() => _loading = true);
    try {
      final store = Provider.of<AppDataStore>(context, listen: false);
      final success = await store.signInWithGoogle();
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully signed up with Google!', style: GoogleFonts.poppins()),
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
                top: 24,
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

  // ── Crimson header ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final padTop = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: padTop + 22, bottom: 26, left: 24, right: 24),
      color: const Color(0xFFC2003C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Create Account',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Join VEXA today',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.80),
              fontSize: 14,
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
          'Fill in your details',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),

        // Full Name
        _buildField(
          controller: _nameCtrl,
          hint: 'Full Name',
          icon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
        ),

        // Username
        _buildField(
          controller: _usernameCtrl,
          hint: 'Username',
          icon: Icons.alternate_email_rounded,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Username is required' : null,
        ),

        // Email
        _buildField(
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

        // Phone with +94 prefix
        _buildPhoneField(),

        // Password
        _buildField(
          controller: _passCtrl,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: _obscurePass,
          suffix: GestureDetector(
            onTap: () => setState(() => _obscurePass = !_obscurePass),
            child: Icon(
              _obscurePass
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

        // Confirm Password
        _buildField(
          controller: _confirmCtrl,
          hint: 'Confirm Password',
          icon: Icons.lock_outline_rounded,
          obscure: _obscureConfirm,
          suffix: GestureDetector(
            onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
            child: Icon(
              _obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF888888),
              size: 20,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please confirm password';
            if (v != _passCtrl.text) return 'Passwords do not match';
            return null;
          },
        ),

        // Date of Birth
        _buildDobField(),

        const SizedBox(height: 18),

        // SELECT GENDER label
        Text(
          'SELECT GENDER',
          style: GoogleFonts.poppins(
            color: const Color(0xFF888888),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        _buildGenderSelector(),
        const SizedBox(height: 20),

        // Agreement checkbox
        _buildAgreementCheckbox(),
        const SizedBox(height: 24),

        // CREATE ACCOUNT button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : _createAccount,
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
                    'CREATE ACCOUNT',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // OR divider
        Center(
          child: Text(
            'OR',
            style: GoogleFonts.poppins(
              color: const Color(0xFFAAAAAA),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Sign up with Google
        Center(
          child: GestureDetector(
            onTap: _loading ? null : _googleSignUp,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
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
                ),
                const SizedBox(width: 10),
                Text(
                  'Sign up with Google',
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
        const SizedBox(height: 24),

        // Login navigation link
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
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
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Generic input field ───────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
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
          prefixIcon:
              Icon(icon, color: const Color(0xFF888888), size: 20),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: suffix,
                )
              : null,
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
      ),
    );
  }

  // ── Phone field with +94 prefix ───────────────────────────────────────────
  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        style: GoogleFonts.poppins(
            fontSize: 14, color: const Color(0xFF333333)),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Phone number is required';
          if (v.trim().length < 7) return 'Enter a valid phone number';
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Phone Number',
          hintStyle: GoogleFonts.poppins(
              color: const Color(0xFFAAAAAA), fontSize: 14),
          prefixIcon: Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 4, top: 14, bottom: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇱🇰', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '+94',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF555555),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Container(width: 1, height: 18, color: const Color(0xFFCCCCCC)),
                const SizedBox(width: 4),
              ],
            ),
          ),
          suffixIcon: const Icon(Icons.phone_outlined,
              color: Color(0xFF888888), size: 20),
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
      ),
    );
  }

  // ── Date of Birth field ────────────────────────────────────────────────────
  Widget _buildDobField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: _pickDate,
        child: AbsorbPointer(
          child: TextFormField(
            controller: _dobCtrl,
            readOnly: true,
            style: GoogleFonts.poppins(
                fontSize: 14, color: const Color(0xFF333333)),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Date of birth is required' : null,
            decoration: InputDecoration(
              hintText: 'Date of Birth',
              hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFFAAAAAA), fontSize: 14),
              prefixIcon: const Icon(Icons.calendar_month_outlined,
                  color: Color(0xFF888888), size: 20),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  // ── Gender selector pills ─────────────────────────────────────────────────
  Widget _buildGenderSelector() {
    final options = ['Male', 'Female', 'Prefer not to say'];
    return Row(
      children: options.map((opt) {
        final selected = _gender == opt;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _gender = opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: opt != options.last ? 8 : 0,
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFD4004E)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFFD4004E)
                      : const Color(0xFFCCCCCC),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: Text(
                opt,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: selected ? Colors.white : const Color(0xFF666666),
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Agreement checkbox ────────────────────────────────────────────────────
  Widget _buildAgreementCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreed = !_agreed),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _agreed ? const Color(0xFFD4004E) : Colors.transparent,
              border: Border.all(
                color: _agreed
                    ? const Color(0xFFD4004E)
                    : const Color(0xFFCCCCCC),
                width: 1.8,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: _agreed
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF555555)),
                children: [
                  const TextSpan(text: 'I agree to '),
                  TextSpan(
                    text: 'Terms & Privacy Policy',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD4004E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
