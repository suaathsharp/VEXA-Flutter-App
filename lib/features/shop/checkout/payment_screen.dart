import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/features/shop/checkout/order_success_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/datastore/app_data_store.dart';
import 'package:flutter_application_1/data/models/order_model.dart';

class PaymentScreen extends StatefulWidget {
  final int deliveryFee;
  final int subtotal;
  const PaymentScreen({super.key, required this.deliveryFee, required this.subtotal});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // 0=card, 1=ezCash, 2=sampath, 3=cod
  final _cardNumCtrl = TextEditingController(text: '4532 8900 1221 4456');
  final _nameCtrl = TextEditingController(text: 'Customer');
  final _mmyyCtrl = TextEditingController(text: '12/28');
  final _cvvCtrl = TextEditingController(text: '***');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = Provider.of<AppDataStore>(context, listen: false);
      if (store.user.name != 'Guest') {
        _nameCtrl.text = store.user.name;
      }
    });
  }

  @override
  void dispose() {
    _cardNumCtrl.dispose(); _nameCtrl.dispose();
    _mmyyCtrl.dispose(); _cvvCtrl.dispose();
    super.dispose();
  }

  int get _total {
    final cod = _selectedMethod == 3 ? 50 : 0;
    return widget.subtotal + widget.deliveryFee + cod;
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
        title: const Text('Payment', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Row(children: [
              Icon(Icons.lock_outlined, color: Color(0xFF27AE60), size: 16),
              SizedBox(width: 4),
              Text('SECURE', style: TextStyle(color: Color(0xFF27AE60), fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMethodTile(0, 'Credit / Debit Card',
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 28, height: 18,
                        decoration: BoxDecoration(color: const Color(0xFFEB001B), borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 4),
                      Container(width: 28, height: 18,
                        decoration: BoxDecoration(color: const Color(0xFF003087), borderRadius: BorderRadius.circular(3))),
                    ]),
                    expanded: _selectedMethod == 0 ? _buildCardForm() : null,
                  ),
                  const SizedBox(height: 10),
                  _buildMethodTile(1, 'Dialog eZ Cash / Genie'),
                  const SizedBox(height: 10),
                  _buildMethodTile(2, 'Sampath Vishwa / Online Banking'),
                  const SizedBox(height: 10),
                  _buildMethodTile(3, 'Cash on Delivery',
                    subtitle: 'Extra LKR 50 COD charge'),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: 6),
                            Text('256-BIT SSL SECURED PAYMENT',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.5, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Order Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                            Text('LKR ${_formatNum(_total)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildPayButton(context),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _step('SHIPPING', true, true),
          _stepLine(true),
          _step('PAYMENT', true, false),
          _stepLine(false),
          _step('SUMMARY', false, false),
        ],
      ),
    );
  }

  Widget _step(String label, bool active, bool done) {
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : const Color(0xFFEEEEEE),
            border: Border.all(
              color: active ? AppColors.primary : const Color(0xFFDDDDDD),
              width: 2,
            ),
          ),
          child: done
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Center(child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? Colors.white : Colors.transparent,
                  ))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          fontSize: 9,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          color: active ? AppColors.primary : AppColors.textHint,
          letterSpacing: 0.5,
        )),
      ],
    );
  }

  Widget _stepLine(bool active) => Expanded(
    child: Container(height: 2, color: active ? AppColors.primary : const Color(0xFFEEEEEE)),
  );

  Widget _buildMethodTile(int idx, String title, {String? subtitle, Widget? trailing, Widget? expanded}) {
    final sel = _selectedMethod == idx;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedMethod = idx); },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? AppColors.primary : const Color(0xFFEEEEEE), width: sel ? 1.5 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: sel ? AppColors.primary : const Color(0xFFCCCCCC), width: 2),
                    ),
                    child: sel ? Center(child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                    )) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing
                  else const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint),
                ],
              ),
            ),
            if (expanded != null) expanded,
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          _label('CARD NUMBER'),
          _field(_cardNumCtrl, Icons.credit_card_rounded),
          const SizedBox(height: 12),
          _label('CARDHOLDER NAME'),
          _field(_nameCtrl, null),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('MM/YY'),
                _field(_mmyyCtrl, null),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('CVV'),
                _field(_cvvCtrl, Icons.help_outline_rounded),
              ])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
  );

  Widget _field(TextEditingController ctrl, IconData? icon) => Container(
    height: 48,
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textHint) : null,
      ),
    ),
  );

  Widget _buildPayButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              final store = Provider.of<AppDataStore>(context, listen: false);
              final navigator = Navigator.of(context);
              
              final orderId = 'VX-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
              const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              final dateStr = '${DateTime.now().day} ${months[DateTime.now().month - 1]} ${DateTime.now().year}';
              
              final order = OrderModel(
                id: orderId,
                date: dateStr,
                status: OrderStatus.processing,
                itemCount: store.cart.items.fold(0, (s, i) => s + i.qty),
                total: 'LKR ${_formatNum(_total)}',
                productImageUrls: store.cart.items.map((i) => i.product.imageUrl).toList(),
                deliveryInfo: 'Arriving in 2-3 Days',
              );
              
              final methodLabel = const [
                'Credit / Debit Card',
                'Dialog eZ Cash / Genie',
                'Sampath Vishwa / Online Banking',
                'Cash on Delivery',
              ][_selectedMethod];
              
              try {
                final placedOrder = await store.placeOrder(order);
                await store.recordPayment(
                  orderId: placedOrder.id,
                  paymentMethod: methodLabel,
                  amount: _total.toDouble(),
                );
              } catch (e) {
                debugPrint('Error placing order and payment: $e');
              }
              
              navigator.push(MaterialPageRoute(builder: (_) => const OrderSuccessScreen()));
            },
            child: Container(
              width: double.infinity, height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), AppColors.primary]),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text('PAY LKR ${_formatNum(_total)}',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: 'By clicking "PAY", you agree to VEXA\'s ',
              style: const TextStyle(fontSize: 10, color: AppColors.textHint),
              children: [
                TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.primary, decoration: TextDecoration.underline)),
                const TextSpan(text: ' and '),
                TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary, decoration: TextDecoration.underline)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatNum(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
