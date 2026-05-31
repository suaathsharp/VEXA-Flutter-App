import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

// ── Wishlist Mock Items ────────────────────────────────────────────────────
class WishlistItem {
  final String id, brand, name, size, color, price, category;
  final Color placeholder;
  const WishlistItem({
    required this.id, required this.brand, required this.name,
    required this.size, required this.color, required this.price,
    required this.category, required this.placeholder,
  });
}

const _wishlistItems = [
  WishlistItem(id: 'wl1', brand: 'AVANT-GARDE', name: 'Oversized Puffer Jkt', size: 'M', color: 'Cyber Yellow', price: 'LKR 2,089', category: 'men', placeholder: Color(0xFFFFD700)),
  WishlistItem(id: 'wl2', brand: 'ESSENTIALS', name: 'Silk Slip Dress', size: 'S', color: 'Onyx Black', price: 'LKR 1,450', category: 'women', placeholder: Color(0xFF212121)),
  WishlistItem(id: 'wl3', brand: 'FOOTWEAR', name: 'Neo-Structure Sneakers', size: '42', color: 'Neon Red', price: 'LKR 2,100', category: 'men', placeholder: Color(0xFFFF2255)),
  WishlistItem(id: 'wl4', brand: 'KNITWEAR', name: 'Premium Wool Cardigan', size: 'L', color: 'Oat Beige', price: 'LKR 1,950', category: 'women', placeholder: Color(0xFFD7CCC8)),
  WishlistItem(id: 'wl5', brand: 'URBAN EDGE', name: 'Cargo Wide Trousers', size: 'M', color: 'Slate Grey', price: 'LKR 2,350', category: 'men', placeholder: Color(0xFF607D8B)),
  WishlistItem(id: 'wl6', brand: 'BLOOM', name: 'Floral Wrap Blouse', size: 'S', color: 'Rose Red', price: 'LKR 1,750', category: 'women', placeholder: Color(0xFFE91E63)),
  WishlistItem(id: 'wl7', brand: 'HERITAGE', name: 'Classic Oxford Shirt', size: 'L', color: 'White', price: 'LKR 2,499', category: 'men', placeholder: Color(0xFFECEFF1)),
  WishlistItem(id: 'wl8', brand: 'MINI MODE', name: 'Dino Print Hoodie', size: '5Y', color: 'Sky Blue', price: 'LKR 980', category: 'kids', placeholder: Color(0xFF81D4FA)),
  WishlistItem(id: 'wl9', brand: 'LUCCI', name: 'Slim Fit Blazer', size: 'M', color: 'Navy Blue', price: 'LKR 4,200', category: 'men', placeholder: Color(0xFF1A237E)),
  WishlistItem(id: 'wl10', brand: 'AMAYA', name: 'Silk Wrap Maxi Dress', size: 'M', color: 'Emerald', price: 'LKR 3,800', category: 'women', placeholder: Color(0xFF2E7D32)),
  WishlistItem(id: 'wl11', brand: 'AGE 3-5', name: 'Explorer Cargo Shorts', size: '4Y', color: 'Khaki', price: 'LKR 850', category: 'kids', placeholder: Color(0xFF8D6E63)),
  WishlistItem(id: 'wl12', brand: 'ROUGH DENIM', name: 'Straight Cut Indigo', size: 'L', color: 'Indigo', price: 'LKR 3,200', category: 'men', placeholder: Color(0xFF1A3A5C)),
];

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _tabs = ['All', 'Men', 'Women', 'Kids'];
  final Set<String> _removed = {};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  List<WishlistItem> get _filtered {
    final all = _wishlistItems.where((i) => !_removed.contains(i.id)).toList();
    switch (_tab.index) {
      case 1: return all.where((i) => i.category == 'men').toList();
      case 2: return all.where((i) => i.category == 'women').toList();
      case 3: return all.where((i) => i.category == 'kids').toList();
      default: return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
        ),
        title: Row(children: [
          const Text('My Wishlist', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text('(${items.length} items)', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w400)),
        ]),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.favorite_border_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('No items in this category', style: TextStyle(fontSize: 15, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  ]))
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.68,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _buildCard(items[i]),
                  ),
          ),
          _buildShareBar(),
        ],
      ),
    );
  }

  Widget _buildCard(WishlistItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: item.placeholder,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _removed.add(item.id));
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.brand, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3)),
                const SizedBox(height: 2),
                Text('Size: ${item.size} | ${item.color}',
                  style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                const SizedBox(height: 4),
                Text(item.price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${item.name} added to cart'),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('ADD TO CART', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareBar() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
    child: GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); },
      child: Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textHint.withValues(alpha: 0.4)),
          color: const Color(0xFFFAFAFA),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share_rounded, size: 18, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text('Share Wishlist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      ),
    ),
  );
}
