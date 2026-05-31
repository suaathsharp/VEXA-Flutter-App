import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/features/shop/checkout/payment_screen.dart';
import 'package:flutter_application_1/features/shop/checkout/add_address_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/datastore/app_data_store.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _deliveryIndex = 0; // 0=Express, 1=Standard, 2=Pickup
  final _instructionCtrl = TextEditingController();
  String _addressName = 'Customer | +94 77 123 4567';
  String _addressDetails = 'No. 42, Galle Road, Colombo 03';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = Provider.of<AppDataStore>(context, listen: false);
      if (store.user.name != 'Guest') {
        setState(() {
          final phoneStr = store.user.phone.isNotEmpty ? store.user.phone : "+94 77 123 4567";
          _addressName = '${store.user.name} | $phoneStr';
        });
      }
    });
  }

  static const _deliveryOptions = [
    {'label': 'Express', 'sub': 'Arrival in 1–2 hours', 'fee': 650, 'icon': Icons.rocket_launch_outlined},
    {'label': 'Standard', 'sub': 'Arrival in 1–2 days', 'fee': 350, 'icon': Icons.local_shipping_outlined},
    {'label': 'Store Pickup', 'sub': 'Collect from Colombo 07', 'fee': 0, 'icon': Icons.storefront_outlined},
  ];

  int get _deliveryFee => _deliveryOptions[_deliveryIndex]['fee'] as int;

  @override
  void dispose() { _instructionCtrl.dispose(); super.dispose(); }

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
        title: const Text('Checkout', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary))],
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddressSection(),
                  const SizedBox(height: 20),
                  _buildDeliverySection(),
                  const SizedBox(height: 20),
                  _buildOrderItemsSection(),
                  const SizedBox(height: 20),
                  _buildInstructionsSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          _step('1', 'ADDRESS', true),
          _line(),
          _step('2', 'PAYMENT', false),
          _line(),
          _step('3', 'CONFIRM', false),
        ],
      ),
    );
  }

  Widget _step(String num, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : const Color(0xFFEEEEEE),
          ),
          child: Center(
            child: Text(num, style: TextStyle(
              color: active ? Colors.white : AppColors.textHint,
              fontSize: 13, fontWeight: FontWeight.w700,
            )),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          fontSize: 9, letterSpacing: 0.5,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          color: active ? AppColors.primary : AppColors.textHint,
        )),
      ],
    );
  }

  Widget _line() => Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 16), color: const Color(0xFFEEEEEE)));

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text('Delivery Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ]),
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
                if (result != null && result is Map) {
                  setState(() {
                    _addressName = '${result['name']} | ${result['phone']}';
                    _addressDetails = '${result['address']}, ${result['city']}';
                  });
                }
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Text('+ ADD NEW', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Center(child: Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                )),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_addressName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(_addressDetails,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DELIVERY TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        ...List.generate(_deliveryOptions.length, (i) {
          final opt = _deliveryOptions[i];
          final sel = _deliveryIndex == i;
          return GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _deliveryIndex = i); },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? AppColors.primary : const Color(0xFFEEEEEE), width: sel ? 1.5 : 1),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Icon(opt['icon'] as IconData, color: sel ? AppColors.primary : AppColors.textSecondary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt['label'] as String, style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: sel ? AppColors.primary : AppColors.textPrimary,
                        )),
                        Text(opt['sub'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text(
                    (opt['fee'] as int) == 0 ? 'LKR 0' : 'LKR ${(opt['fee'] as int).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                      color: sel ? AppColors.primary : AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOrderItemsSection() {
    return AnimatedBuilder(
      animation: cartModel,
      builder: (context, _) {
        final items = cartModel.items;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ORDER ITEMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            Row(
              children: [
                ...items.take(3).map((item) => Container(
                  width: 56, height: 56,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: item.product.placeholderColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(item.product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                  ),
                )),
                if (items.length > 3)
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(child: Text('+${items.length - 3}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SPECIAL INSTRUCTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: TextField(
            controller: _instructionCtrl,
            maxLines: 4,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Any special delivery instructions?',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL PAYABLE', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
              AnimatedBuilder(
                animation: cartModel,
                builder: (_, __) {
                  final total = cartModel.subtotal + _deliveryFee;
                  return Text('LKR ${total.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary));
                },
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    deliveryFee: _deliveryFee,
                    subtotal: cartModel.subtotal,
                  ),
                ));
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('CONTINUE TO PAYMENT', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
