import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/features/shop/product_detail_page.dart';
import 'package:flutter_application_1/features/shop/product_listing_page.dart';
import 'package:flutter_application_1/features/shop/cart_page.dart';
import 'package:flutter_application_1/core/widgets/hover_zoom.dart';

class WomenSectionPage extends StatefulWidget {
  const WomenSectionPage({super.key});
  @override
  State<WomenSectionPage> createState() => _WomenSectionPageState();
}

class _WomenSectionPageState extends State<WomenSectionPage> {
  String _activeCategory = 'All';
  final List<String> _categories = ['All', 'Tops', 'Blouses', 'Dresses', 'Accessories'];

  List<ProductModel> get _filtered => _activeCategory == 'All'
      ? womenProducts
      : womenProducts.where((p) => p.subCategory == _activeCategory).toList();

  void _openProduct(ProductModel prod) {
    HapticFeedback.lightImpact();
    Navigator.push(context,
        PageRouteBuilder(
          pageBuilder: (context, anim, secAnim) => ProductDetailPage(product: prod),
          transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 280),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildTopBar()),
          SliverToBoxAdapter(child: _buildBanner()),
          SliverToBoxAdapter(child: _buildCategoryTabs()),
          SliverToBoxAdapter(child: _buildPromoBanner()),
          SliverToBoxAdapter(child: _buildTrendingHeader()),
          SliverToBoxAdapter(child: _buildTrendingRow()),
          SliverToBoxAdapter(child: _buildSelectionHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.68,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _buildProductCard(_filtered[i]),
                childCount: _filtered.length,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16, right: 16, bottom: 14,
      ),
      child: Row(children: [
        // Back Button
        Material(
          color: Colors.transparent,
          child: HoverZoom(
            child: InkWell(
              onTap: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
              borderRadius: BorderRadius.circular(10),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20)),
            ),
          ),
        ),
        // VEXA (tap = home)
        Expanded(child: Center(child: HoverZoom(
          child: GestureDetector(
            onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('VEXA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
          ),
        ))),
        // Cart
        AnimatedBuilder(
          animation: cartModel,
          builder: (context, child) => Material(
            color: Colors.transparent,
            child: HoverZoom(
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CartPage())),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(clipBehavior: Clip.none, children: [
                    const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                    if (cartModel.count > 0)
                      Positioned(top: -4, right: -6,
                        child: Container(width: 15, height: 15,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: Center(child: Text('${cartModel.count}',
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))))),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

    Widget _buildBanner() {
    return Container(
      height: 240, width: double.infinity,
      color: Colors.black,
      child: Stack(children: [
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 30, 140, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("WOMEN'S\nCOLLECTION",
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.1)),
            const SizedBox(height: 10),
            Text('Elegance Redefined for the Modern Woman', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
            const SizedBox(height: 20),
            Row(children: [
              _statChip('NEW ARRIVALS'), const SizedBox(width: 8), _statChip('TOP BRANDS'),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _statChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
  );

    Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      height: 66,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isActive = cat == _activeCategory;
          return HoverZoom(
            child: GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); setState(() => _activeCategory = cat); },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isActive ? AppColors.primary : const Color(0xFFDDDDDD)),
                ),
                child: Text(cat,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  )),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: HoverZoom(
        child: Container(
          height: 120, width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1515347619362-75efb60882e7?w=800'),
              fit: BoxFit.cover,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Summer Dress Edit 🌸',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Lightweight & Breathable Essentials', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                const SizedBox(height: 8),
                const Text('LKR 1,999 – 6,999',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTrendingHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 22, 14, 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Trending in Women', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductListingPage(title: "Women's Trending", breadcrumb: 'Home > Women > Trending', products: womenProducts))),
          child: const Text('VIEW ALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
      ]),
    );
  }

  Widget _buildTrendingRow() {
    final trending = womenProducts.take(2).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SizedBox(
        height: 260, // Bounded height required since _buildProductCard has Expanded inside
        child: Row(children: trending.map((p) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: p == trending.last ? 0 : 10),
              child: _buildProductCard(p),
            ),
          );
        }).toList()),
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 20, 14, 10),
      child: Text('Our Selection', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return HoverZoom(
      child: GestureDetector(
        onTap: () => _openProduct(product),
        child: AnimatedBuilder(
          animation: Listenable.merge([wishlistModel, cartModel]),
          builder: (context, child) {
            final isWL = wishlistModel.isWishlisted(product.id);
            return Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Stack(children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: product.placeholderColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, _) => Center(child: CustomPaint(size: const Size(70, 100), painter: _WomenProductPainter(product))),
                    ),
                  ),
                  Positioned(top: 8, right: 8,
                    child: HoverZoom(
                      child: GestureDetector(
                        onTap: () { HapticFeedback.lightImpact(); wishlistModel.toggle(product.id); },
                        child: Container(width: 30, height: 30,
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
                          child: Icon(isWL ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 15, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  Positioned(bottom: 8, right: 8,
                    child: HoverZoom(
                      child: GestureDetector(
                        onTap: () { HapticFeedback.mediumImpact(); cartModel.add(product); },
                        child: Container(width: 32, height: 32,
                          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.shopping_cart_outlined, size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ])),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(product.brand, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(product.price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ]),
                ),
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -3))]),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _navItem(Icons.home_rounded, 'HOME', true, () => Navigator.of(context).popUntil((r) => r.isFirst)),
            _navItem(Icons.search_rounded, 'SEARCH', false, () {}),
            _navItem(Icons.shopping_bag_outlined, 'CART', false,
              () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CartPage()))),
            _navItem(Icons.person_outline_rounded, 'PROFILE', false, () {}),
          ]),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return HoverZoom(
      child: GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: active ? AppColors.primary : AppColors.textHint, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textHint)),
          if (active) Container(margin: const EdgeInsets.only(top: 3), width: 4, height: 4,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}

// ── PAINTERS ──────────────────────────────────────────────────────────────

class _WomenProductPainter extends CustomPainter {
  final ProductModel product;
  _WomenProductPainter(this.product);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.2)..style = PaintingStyle.fill;
    final cx = size.width * 0.5;
    canvas.drawCircle(Offset(cx, size.height * 0.1), 14, paint);
    final path = Path();
    path.moveTo(cx - 22, size.height * 0.18);
    path.quadraticBezierTo(cx - 30, size.height * 0.4, cx - 32, size.height);
    path.lineTo(cx + 32, size.height);
    path.quadraticBezierTo(cx + 30, size.height * 0.4, cx + 22, size.height * 0.18);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
