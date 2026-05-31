import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/features/shop/checkout/checkout_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _promoCtrl = TextEditingController();
  bool _promoError = false;

  @override
  void dispose() { _promoCtrl.dispose(); super.dispose(); }

  void _applyPromo() {
    HapticFeedback.selectionClick();
    final applied = cartModel.applyPromo(_promoCtrl.text);
    setState(() => _promoError = !applied);
    if (applied) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: AnimatedBuilder(
          animation: cartModel,
          builder: (_, __) => Text(
            'Shopping Cart  •  ${cartModel.count} item${cartModel.count == 1 ? '' : 's'}',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: cartModel,
            builder: (_, __) {
              if (cartModel.items.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 22),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  for (final item in List.from(cartModel.items)) {
                    cartModel.remove(item.product.id);
                  }
                  cartModel.removePromo();
                },
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: cartModel,
        builder: (context, _) {
          if (cartModel.items.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                const SizedBox(height: 8),
                Text('Add items to get started', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
              ]),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(14),
                  children: [
                    ...cartModel.items.map((item) => _buildCartItem(context, item)),
                    const SizedBox(height: 8),
                    _buildPromoSection(),
                    const SizedBox(height: 12),
                    _buildOrderSummary(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              _buildCheckoutBar(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    final p = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 76, height: 88,
            decoration: BoxDecoration(color: p.placeholderColor, borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.brand, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(child: Text(p.price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary))),
                  ],
                ),
                const SizedBox(height: 2),
                Text(p.name, maxLines: 2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3)),
                const SizedBox(height: 4),
                Text('Color: ${item.selectedSize == 'M' ? 'Rose Red' : 'Rose'} | Size: ${item.selectedSize}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      _qtyBtn(Icons.remove_rounded, () {
                        HapticFeedback.selectionClick();
                        cartModel.updateQty(p.id, item.qty - 1);
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text('${item.qty}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                      _qtyBtn(Icons.add_rounded, () {
                        HapticFeedback.selectionClick();
                        cartModel.updateQty(p.id, item.qty + 1);
                      }),
                    ]),
                    Text(
                      'SUBTOTAL: LKR ${_fmt((double.tryParse(p.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0 * item.qty).toInt())}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); cartModel.remove(p.id); },
            child: Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 48),
              child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.sell_outlined, size: 18, color: AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedBuilder(
              animation: cartModel,
              builder: (_, __) {
                if (cartModel.appliedPromo != null) {
                  return Text(cartModel.appliedPromo!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary));
                }
                return TextField(
                  controller: _promoCtrl,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'ENTER PROMO CODE',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    errorText: _promoError ? 'Invalid code' : null,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => _applyPromo(),
                );
              },
            ),
          ),
          AnimatedBuilder(
            animation: cartModel,
            builder: (_, __) {
              if (cartModel.appliedPromo != null) {
                return GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); cartModel.removePromo(); _promoCtrl.clear(); setState(() => _promoError = false); },
                  child: const Text('REMOVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red)),
                );
              }
              return GestureDetector(
                onTap: _applyPromo,
                child: const Text('APPLY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              );
            },
          ),
        ],
      ),
    ),
  );

  Widget _buildOrderSummary() {
    return AnimatedBuilder(
      animation: cartModel,
      builder: (_, __) {
        const shipping = 350;
        final sub = cartModel.subtotal;
        final promo = cartModel.promoDiscount;
        final total = sub + shipping - promo;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ORDER SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 14),
              _summaryRow('Subtotal (${cartModel.count} items)', 'LKR ${_fmt(sub)}'),
              const SizedBox(height: 8),
              _summaryRow('Shipping', 'LKR ${_fmt(shipping)}'),
              if (promo > 0) ...[
                const SizedBox(height: 8),
                _summaryRow('Promo Discount', '-LKR ${_fmt(promo)}', valueColor: const Color(0xFF27AE60)),
              ],
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  Text('LKR ${_fmt(total)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
    ],
  );

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFDDDDDD))),
      child: Icon(icon, size: 14, color: AppColors.textPrimary),
    ),
  );

  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: AnimatedBuilder(
        animation: cartModel,
        builder: (_, __) {
          const shipping = 350;
          final total = cartModel.subtotal + shipping - cartModel.promoDiscount;
          return Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('GRAND TOTAL', style: TextStyle(fontSize: 9, color: AppColors.textSecondary, letterSpacing: 0.5, fontWeight: FontWeight.w500)),
                  Text('LKR ${_fmt(total)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
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
                        Text('PROCEED TO CHECKOUT', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
