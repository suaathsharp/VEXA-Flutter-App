import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/features/shop/product_detail_page.dart';
import 'package:flutter_application_1/features/shop/product_listing_page.dart';
import 'package:flutter_application_1/features/shop/cart_page.dart';
import 'package:flutter_application_1/features/user/profile_page.dart';
import 'package:flutter_application_1/core/widgets/hover_zoom.dart';

class KidsSectionPage extends StatefulWidget {
  const KidsSectionPage({super.key});
  @override
  State<KidsSectionPage> createState() => _KidsSectionPageState();
}

class _KidsSectionPageState extends State<KidsSectionPage> {
  String _activeAge = 'All Ages';
  String _activeGender = 'All';
  final List<String> _genderFilters = ['All', 'Boy', 'Girl'];
  String _activeCategory = 'All';

  final List<String> _ageFilters = ['All Ages', '0–2 YRS', '3–5 YRS', '6–9 YRS'];
  final List<String> _categories = ['All', 'T-Shirts', 'Frocks', 'Shorts', 'Accessories'];

  // Kids orange accent
  static const Color _kidsAccent = Color(0xFFE8A020);

  List<ProductModel> get _filtered {
    var list = kidsProducts;
    if (_activeAge != 'All Ages') {
      final map = {'0–2 YRS': '0-2', '3–5 YRS': '3-5', '6–9 YRS': '6-9'};
      final key = map[_activeAge] ?? '';
      list = list.where((p) => p.brand.toLowerCase().contains(key.split('-')[0])).toList();
    }
    if (_activeCategory != 'All') {
      list = list.where((p) => p.subCategory == _activeCategory).toList();
    }
    if (_activeGender != 'All') {
      list = list.where((p) => p.gender == _activeGender).toList();
    }
    return list;
  }

  void _openProduct(ProductModel p) {
    HapticFeedback.lightImpact();
    Navigator.push(context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => ProductDetailPage(product: p),
          transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
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
          SliverToBoxAdapter(child: _buildAgeFilter()),
          SliverToBoxAdapter(child: _buildCategoryTabs()),
          SliverToBoxAdapter(child: _buildGenderTabs()),
          SliverToBoxAdapter(child: _buildPromoBanner()),
          SliverToBoxAdapter(child: _buildNewArrivalsHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
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
        // Back / Profile Button (User reported Profile button issue)
        Material(
          color: Colors.transparent,
          child: HoverZoom(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20)),
            ),
          ),
        ),
        // VEXA Logo
        Expanded(child: Center(child: HoverZoom(
          child: GestureDetector(
            onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('VEXA', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
          ),
        ))),
        // Cart
        AnimatedBuilder(
          animation: cartModel,
          builder: (_, _) => Material(
            color: Colors.transparent,
            child: HoverZoom(
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
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
      height: 200, width: double.infinity,
      color: Colors.black,
      child: Stack(children: [
        Positioned.fill(
          child: Row(children: [
            Expanded(flex: 2, child: Container()),
            Expanded(
              flex: 3,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.centerLeft, end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.black, Colors.black],
                  stops: [0.0, 0.4, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.network('https://images.unsplash.com/photo-1514090458221-65bb69cf63e6?w=800', fit: BoxFit.cover),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 30, 140, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("KIDS COLLECTION",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5, height: 1.1)),
            const SizedBox(height: 5),
            Text('Fun & Comfortable Styles', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            const SizedBox(height: 12),
            Row(children: [
              _statChip('NEW ARRIVALS'), const SizedBox(width: 8), _statChip('TOP BRANDS'),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _statChip(String label) => Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600));

  Widget _buildAgeFilter() {
    return Container(
      color: _kidsAccent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        scrollDirection: Axis.horizontal,
        child: Row(children: _ageFilters.map((age) {
          final isActive = age == _activeAge;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: HoverZoom(
              child: GestureDetector(
                onTap: () { HapticFeedback.lightImpact(); setState(() => _activeAge = age); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5)),
                  ),
                  child: Text(age,
                    style: TextStyle(
                      color: isActive ? _kidsAccent : Colors.white,
                      fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          );
        }).toList()),
      ),
    );
  }

    Widget _buildGenderTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _genderFilters.map((g) {
          final isActive = g == _activeGender;
          return HoverZoom(
            child: GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); setState(() => _activeGender = g); },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? _kidsAccent : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? _kidsAccent : const Color(0xFFDDDDDD)),
                ),
                child: Text(g, style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
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
                  color: isActive ? _kidsAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isActive ? _kidsAccent : const Color(0xFFDDDDDD)),
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
              image: NetworkImage('https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=800'),
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
                const Text('Playwear Essentials', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Durable and soft materials for active kids', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                const SizedBox(height: 8),
                const Text('FROM LKR 999', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildNewArrivalsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('New Arrivals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ProductListingPage(title: "Kids Collection", breadcrumb: 'Home > Kids > All', products: kidsProducts))),
          child: const Text('VIEW ALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
      ]),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return HoverZoom(
      child: GestureDetector(
        onTap: () => _openProduct(product),
        child: AnimatedBuilder(
          animation: Listenable.merge([wishlistModel, cartModel]),
          builder: (_, _) {
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
                      errorBuilder: (ctx, _, _) => Center(child: CustomPaint(size: const Size(70, 95), painter: _KidsProductPainter(product))),
                    ),
                  ),
                  // Age badge
                  Positioned(top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: _kidsAccent, borderRadius: BorderRadius.circular(6)),
                      child: Text(product.brand.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)))),
                  // Wishlist
                  Positioned(top: 8, right: 8,
                    child: HoverZoom(
                      child: GestureDetector(
                        onTap: () { HapticFeedback.lightImpact(); wishlistModel.toggle(product.id); },
                        child: Container(width: 28, height: 28,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(isWL ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 14, color: AppColors.primary))),
                    )),
                ])),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()))),
            _navItem(Icons.person_outline_rounded, 'PROFILE', false, () {}),
          ]),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: active ? AppColors.primary : AppColors.textHint, size: 24),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
          color: active ? AppColors.primary : AppColors.textHint)),
        if (active) Container(margin: const EdgeInsets.only(top: 3), width: 4, height: 4,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
      ]),
    );
  }
}

// ── PAINTERS ──────────────────────────────────────────────────────────────

class _KidsProductPainter extends CustomPainter {
  final ProductModel product;
  _KidsProductPainter(this.product);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.22)..style = PaintingStyle.fill;
    final cx = size.width * 0.5;
    if (product.subCategory == 'Accessories') {
      // Cap shape
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, size.height * 0.4), width: size.width * 0.7, height: size.height * 0.35), p);
      canvas.drawRect(Rect.fromLTRB(cx - size.width * 0.35, size.height * 0.5, cx + size.width * 0.5, size.height * 0.6), p);
    } else {
      // Small shirt
      final path = Path();
      path.moveTo(cx - 18, 0); path.lineTo(cx - 28, 12);
      path.lineTo(cx - 20, 16); path.lineTo(cx - 20, size.height);
      path.lineTo(cx + 20, size.height); path.lineTo(cx + 20, 16);
      path.lineTo(cx + 28, 12); path.lineTo(cx + 18, 0);
      path.quadraticBezierTo(cx + 8, 10, cx, 10);
      path.quadraticBezierTo(cx - 8, 10, cx - 18, 0);
      canvas.drawPath(path, p);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter _) => false;
}
