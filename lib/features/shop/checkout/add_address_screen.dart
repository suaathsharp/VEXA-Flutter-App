import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  void _save() {
    if (_nameCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.pop(context, {
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'address': _addressCtrl.text,
      'city': _cityCtrl.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: GestureDetector(
          onTap: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
        ),
        title: const Text('Add New Address', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildField('Full Name', _nameCtrl, 'John Doe'),
            const SizedBox(height: 16),
            _buildField('Phone Number', _phoneCtrl, '+94 7X XXX XXXX', TextInputType.phone),
            const SizedBox(height: 16),
            _buildField('Street Address', _addressCtrl, 'No. 42, Galle Road'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildField('City', _cityCtrl, 'Colombo')),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Postal Code', _postalCtrl, '00300', TextInputType.number)),
              ],
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _save,
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Center(
                  child: Text('SAVE ADDRESS', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, [TextInputType type = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: type,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
