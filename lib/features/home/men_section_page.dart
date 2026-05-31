import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/features/shop/product_listing_page.dart';
import 'package:flutter_application_1/features/shop/product_detail_page.dart';
import 'package:flutter_application_1/features/shop/cart_page.dart';
import 'package:flutter_application_1/core/widgets/hover_zoom.dart';

class MenSectionPage extends StatefulWidget {
  const MenSectionPage({super.key});

  @override
  State<MenSectionPage> createState() => _MenSectionPageState();
}

class _MenSectionPageState extends State<MenSectionPage> {
  String _activeCategory = 'All';
  final List<String> _categories = ['All', 'Shirts', 'T-Shirts', 'Denim', 'Trousers', 'Accessories'];

  List<ProductModel> get _filteredProducts => _activeCategory == 'All'
      ? menProducts
      : menProducts.where((p) => p.subCategory == _activeCategory).toList();

  void _goHome() {
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _goCart() {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
  }

  void _openProduct(ProductModel p) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => ProductDetailPage(product: p),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── TOP BAR ────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildTopBar()),

          // ── PROMO BANNER ───────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildPromoBanner()),

          // ── CATEGORY TABS ───────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildCategoryTabs()),

          // ── SEASONAL HIGHLIGHT ──────────────────────────────────────────
          SliverToBoxAdapter(child: _buildSeasonalBanner()),

          // ── PRODUCT GRID ────────────────────────────────────────────────
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
                (context, i) => _buildProductCard(_filteredProducts[i]),
                childCount: _filteredProducts.length,
              ),
            ),
          ),
        ],
      ),

      // ── FILTER FLOATING BUTTON ────────────────────────────────────────
      floatingActionButton: _buildFilterFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ── BOTTOM NAV ────────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: AppColors.dark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16, right: 16, bottom: 14,
      ),
      child: Row(children: [
        // Back
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
        // Logo
        Expanded(child: Center(child: HoverZoom(
          child: GestureDetector(
            onTap: _goHome,
            child: const Text('VEXA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
          ),
        ))),
        // Icons
        Row(children: [
          Material(
            color: Colors.transparent,
            child: HoverZoom(
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(Icons.search_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: HoverZoom(
              child: InkWell(
                onTap: _goCart,
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
      height: 240, width: double.infinity,
      color: Colors.black,
      child: Stack(children: [
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1490367532201-b9bc1dc483f6?w=800',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 30, 140, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("MEN'S\nCOLLECTION",
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.1)),
            const SizedBox(height: 10),
            Text('Timeless Style for Every Occasion', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
            const SizedBox(height: 20),
            Row(children: [
              _statChip('240+ PRODUCTS'),
              const SizedBox(width: 8),
              _statChip('12 BRANDS'),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _statChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
  );

  // ─────────────────────────────────────────────────────────────────────
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
                  color: isActive ? AppColors.dark : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isActive ? AppColors.dark : const Color(0xFFDDDDDD)),
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

    Widget _buildSeasonalBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: HoverZoom(
        child: Container(
          height: 120, width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1B2A6B),
            borderRadius: BorderRadius.circular(18),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1480455624313-e29b44bbfde1?w=800'),
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
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('New Formal Collection', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Sharp & Sophisticated Essentials', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                const SizedBox(height: 8),
                const Text('UP TO 40% OFF', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return HoverZoom(
      child: GestureDetector(
        onTap: () => _openProduct(product),
        child: AnimatedBuilder(
          animation: Listenable.merge([wishlistModel, cartModel]),
          builder: (_, _) {
            final isWishlisted = wishlistModel.isWishlisted(product.id);
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image + overlays
                  Expanded(
                    child: Stack(children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: product.placeholderColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, _) => Center(child: CustomPaint(size: const Size(70, 100), painter: _ProductImagePainter(product))),
                        ),
                      ),
                      // Badge
                      if (product.badge != null)
                        Positioned(top: 8, left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: product.badge == 'SALE' ? AppColors.primary : const Color(0xFF27AE60),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(product.badge!, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      // Wishlist
                      Positioned(top: 6, right: 6,
                        child: HoverZoom(
                          child: GestureDetector(
                            onTap: () { HapticFeedback.lightImpact(); wishlistModel.toggle(product.id); },
                            child: Container(width: 30, height: 30,
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
                              child: Icon(isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 15, color: AppColors.primary)),
                          ),
                        ),
                      ),
                      // Cart button (bottom right)
                      Positioned(bottom: 8, right: 8,
                        child: HoverZoom(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              cartModel.add(product);
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${product.name} added to cart 🛒'),
                                backgroundColor: AppColors.primary,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ));
                            },
                            child: Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8)]),
                              child: const Icon(Icons.shopping_cart_outlined, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(product.brand, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      // Stars + count
                      Row(children: [
                        Icon(Icons.star_rounded, size: 12, color: Colors.amber.shade600),
                        Text(' ${product.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text(' (${product.reviewCount})', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text(product.price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        if (product.originalPrice != null) ...[
                          const SizedBox(width: 4),
                          Text(product.originalPrice!, style: const TextStyle(fontSize: 10, color: AppColors.textHint,
                            decoration: TextDecoration.lineThrough)),
                        ],
                      ]),
                    ]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  Widget _buildFilterFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => const ProductListingPage(title: 'Shirts – Men', breadcrumb: 'Home > Men > Shirts')));
      },
      backgroundColor: AppColors.primary,
      elevation: 4,
      icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
      label: const Text('FILTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5)),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -3))]),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(Icons.home_rounded, 'HOME', true, _goHome),
              _navItem(Icons.search_rounded, 'SEARCH', false, _showSearch),
              _navItem(Icons.shopping_bag_outlined, 'CART', false, _goCart),
              _navItem(Icons.person_outline_rounded, 'PROFILE', false, () {}),
            ],
          ),
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

  void _showSearch() {
    showSearch(context: context, delegate: _VexaSearchDelegate(menProducts));
  }
}

// ──────────────────────────────────────────────────────────────────────────
//  SEARCH DELEGATE
// ──────────────────────────────────────────────────────────────────────────
class _VexaSearchDelegate extends SearchDelegate<String> {
  final List<ProductModel> products;
  _VexaSearchDelegate(this.products);

  @override
  ThemeData appBarTheme(BuildContext context) => ThemeData(
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.dark, foregroundColor: Colors.white),
    inputDecorationTheme: const InputDecorationTheme(hintStyle: TextStyle(color: Colors.white54)),
  );

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = products.where((p) =>
      p.name.toLowerCase().contains(query.toLowerCase()) ||
      p.brand.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final p = results[i];
        return ListTile(
          leading: Container(width: 40, height: 40, color: p.placeholderColor,
            child: Image.network(p.imageUrl, fit: BoxFit.cover, errorBuilder: (ctx, _, _) => CustomPaint(painter: _ProductImagePainter(p)))),
          title: Text(p.name),
          subtitle: Text(p.price, style: const TextStyle(color: AppColors.primary)),
          onTap: () {
            close(context, p.id);
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)));
          },
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
//  CUSTOM PAINTERS
// ──────────────────────────────────────────────────────────────────────────

class _ProductImagePainter extends CustomPainter {
  final ProductModel product;
  _ProductImagePainter(this.product);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.2)..style = PaintingStyle.fill;
    final cx = size.width * 0.5;
    switch (product.subCategory) {
      case 'Trousers':
      case 'Denim':
        final path = Path();
        path.moveTo(cx - 26, 0); path.lineTo(cx + 26, 0);
        path.lineTo(cx + 18, size.height * 0.5); path.lineTo(cx + 26, size.height);
        path.lineTo(cx + 8, size.height); path.lineTo(cx, size.height * 0.55);
        path.lineTo(cx - 8, size.height); path.lineTo(cx - 26, size.height);
        path.lineTo(cx - 18, size.height * 0.5); path.close();
        canvas.drawPath(path, paint);
        break;
      default:
        final path = Path();
        path.moveTo(cx - 20, 0); path.lineTo(cx - 32, 14);
        path.lineTo(cx - 22, 18); path.lineTo(cx - 22, size.height);
        path.lineTo(cx + 22, size.height); path.lineTo(cx + 22, 18);
        path.lineTo(cx + 32, 14); path.lineTo(cx + 20, 0);
        path.quadraticBezierTo(cx + 8, 11, cx, 11);
        path.quadraticBezierTo(cx - 8, 11, cx - 20, 0);
        canvas.drawPath(path, paint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
