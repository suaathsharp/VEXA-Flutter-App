import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/layout/main_shell.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/datastore/app_data_store.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 200), () => _ctrl.forward());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppDataStore>(context, listen: false).clearCart();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<AppDataStore>(context);
    final userName = store.user.name;
    final userEmail = store.user.email;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text('VEXA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 3)),
        centerTitle: true,
        actions: [const Icon(Icons.shopping_bag_outlined, color: Colors.white), const SizedBox(width: 16)],
        leading: const Icon(Icons.person_outline_rounded, color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20)],
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Order Placed! 🎉',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 6),
                  Text('Thank you, $userName!',
                    style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 24),
                  Builder(
                    builder: (context) {
                      final latestOrder = store.orders.isNotEmpty ? store.orders.first : null;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            _row('ORDER ID', latestOrder?.id ?? 'VX-2025-00847', bold: true),
                            const Divider(height: 16),
                            _row('DATE', latestOrder?.date ?? 'Jan 24, 2025'),
                            const Divider(height: 16),
                            _row('EST. DELIVERY', latestOrder?.deliveryInfo ?? '28 Jan - 30 Jan'),
                            const Divider(height: 16),
                            _row('PAYMENT METHOD', 'Card / COD'),
                            const Divider(height: 16),
                            _row('Total Paid', latestOrder?.total ?? 'LKR 8,050', highlight: true),
                          ],
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF27AE60)),
                        SizedBox(width: 6),
                        Text('Your order is being prepared!',
                          style: TextStyle(fontSize: 13, color: Color(0xFF27AE60), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); },
                    child: Container(
                      width: double.infinity, height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('TRACK MY ORDER',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainShell()),
                        (_) => false,
                      );
                    },
                    child: Container(
                      width: double.infinity, height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: const Center(
                        child: Text('CONTINUE SHOPPING',
                          style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('A confirmation email was sent to',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            Text(userEmail,
              style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: bold ? 12 : 12,
          color: bold ? AppColors.textSecondary : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        )),
        Text(value, style: TextStyle(
          fontSize: highlight ? 16 : 13,
          fontWeight: highlight ? FontWeight.w800 : (bold ? FontWeight.w700 : FontWeight.w600),
          color: highlight ? AppColors.primary : AppColors.textPrimary,
        )),
      ],
    );
  }
}
