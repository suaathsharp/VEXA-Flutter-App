import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/features/shop/product_detail_page.dart';
import 'package:flutter_application_1/features/shop/cart_page.dart';

class ProductListingPage extends StatefulWidget {
  final String title;
  final String breadcrumb;
  final List<ProductModel>? products;

  const ProductListingPage({
    super.key,
    required this.title,
    required this.breadcrumb,
    this.products,
  });

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  String _activeFilter = 'All';
  String _sortBy = 'Default';
  int _visibleCount = 4;
  final List<String> _filters = ['All', 'Price', 'Size', 'Color', 'Brand'];

  List<ProductModel> get _baseProducts => widget.products ?? menProducts;

  List<ProductModel> get _displayedProducts {
    List<ProductModel> list = List.from(_baseProducts);
    if (_sortBy == 'Price ↑') list.sort((a, b) => _price(a).compareTo(_price(b)));
    if (_sortBy == 'Price ↓') list.sort((a, b) => _price(b).compareTo(_price(a)));
    return list.take(_visibleCount).toList();
  }

  double _price(ProductModel prod) =>
      double.tryParse(prod.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

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
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildBreadcrumb(),
            _buildFilterBar(),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Products count + sort
                  SliverToBoxAdapter(child: _buildCountSort()),
                  // Product grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _buildCard(_displayedProducts[i]),
                        childCount: _displayedProducts.length,
                      ),
                    ),
                  ),
                  // Load More
                  SliverToBoxAdapter(child: _buildLoadMore()),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
          GestureDetector(
            onTap: () => _showSearch(),
            child: const Icon(Icons.search_rounded, size: 22, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 18),
          AnimatedBuilder(
            animation: cartModel,
            builder: (context, child) => GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CartPage())),
              child: Stack(clipBehavior: Clip.none, children: [
                const Icon(Icons.shopping_bag_outlined, size: 22, color: AppColors.textPrimary),
                if (cartModel.count > 0)
                  Positioned(top: -4, right: -6,
                    child: Container(width: 15, height: 15,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(child: Text('${cartModel.count}',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))))),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    final parts = widget.breadcrumb.split(' > ');
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          for (int i = 0; i < parts.length; i++) ...[
            if (i > 0) const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textHint),
            Text(
              parts[i].trim(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: i == parts.length - 1 ? FontWeight.w700 : FontWeight.w400,
                color: i == parts.length - 1 ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        children: [
          // Filter chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _filters.map((f) {
                  final isActive = f == _activeFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () { HapticFeedback.lightImpact(); setState(() => _activeFilter = f); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isActive ? AppColors.primary : const Color(0xFFDDDDDD)),
                        ),
                        child: Text(f,
                          style: TextStyle(
                            color: isActive ? Colors.white : AppColors.textSecondary,
                            fontSize: 12, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Sort button
          GestureDetector(
            onTap: _showSortSheet,
            child: Row(children: [
              Text('Sort', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textPrimary),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCountSort() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(children: [
        Text('${_baseProducts.length} Products Found',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    );
  }

  Widget _buildCard(ProductModel product) {
    return GestureDetector(
      onTap: () => _openProduct(product),
      child: AnimatedBuilder(
        animation: Listenable.merge([wishlistModel, cartModel]),
        builder: (context, child) {
          final isWishlisted = wishlistModel.isWishlisted(product.id);
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Stack(children: [
                  Container(width: double.infinity,
                    decoration: BoxDecoration(color: product.placeholderColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                    child: Center(child: CustomPaint(size: const Size(70, 100),
                      painter: _MenListProductPainter(product)))),
                  if (product.badge != null)
                    Positioned(top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.badge == 'SALE' ? AppColors.primary : const Color(0xFF27AE60),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(product.badge!, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                      )),
                  Positioned(top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () { HapticFeedback.lightImpact(); wishlistModel.toggle(product.id); },
                      child: Container(width: 30, height: 30,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
                        child: Icon(isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 15, color: AppColors.primary)),
                    )),
                  Positioned(bottom: 8, right: 8,
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
                      child: Container(width: 34, height: 34,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8)]),
                        child: const Icon(Icons.shopping_cart_outlined, size: 17, color: Colors.white)),
                    )),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(product.brand, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.4)),
                  const SizedBox(height: 2),
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.star_rounded, size: 12, color: Colors.amber.shade600),
                    Text(' ${product.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(' (${product.reviewCount})', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 4),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Text(product.price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    if (product.originalPrice != null) ...[
                      const SizedBox(width: 4),
                      Text(product.originalPrice!, style: const TextStyle(fontSize: 9, color: AppColors.textHint, decoration: TextDecoration.lineThrough)),
                    ],
                  ]),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildLoadMore() {
    final hasMore = _visibleCount < _baseProducts.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(children: [
        if (hasMore)
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); setState(() => _visibleCount += 4); },
            child: Container(
              width: double.infinity, height: 48,
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Center(child: Text('Load More', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700))),
            ),
          ),
        const SizedBox(height: 8),
        Text("You've viewed ${_displayedProducts.length} of ${_baseProducts.length} products",
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _baseProducts.isEmpty ? 1 : _displayedProducts.length / _baseProducts.length,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 3,
          ),
        ),
        const SizedBox(height: 20),
      ]),
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
            _navItem(Icons.home_rounded, 'HOME', false, () => Navigator.of(context).popUntil((r) => r.isFirst)),
            _navItem(Icons.search_rounded, 'SEARCH', true, _showSearch),
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

  void _showSearch() {
    showSearch(context: context, delegate: _ListSearchDelegate(_baseProducts));
  }

  void _showSortSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Sort By', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          for (final s in ['Default', 'Price ↑', 'Price ↓'])
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(s, style: TextStyle(fontSize: 14, color: AppColors.textPrimary,
                fontWeight: s == _sortBy ? FontWeight.w700 : FontWeight.w400)),
              trailing: s == _sortBy ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () { setState(() => _sortBy = s); Navigator.pop(ctx); },
            ),
        ]),
      ),
    );
  }
}

class _ListSearchDelegate extends SearchDelegate<String> {
  final List<ProductModel> products;
  _ListSearchDelegate(this.products);

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
    final results = products.where((prod) =>
      prod.name.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (ctx, i) => ListTile(
        title: Text(results[i].name),
        subtitle: Text(results[i].price, style: const TextStyle(color: AppColors.primary)),
        onTap: () {
          close(context, '');
          Navigator.push(context, MaterialPageRoute(builder: (ctx2) => ProductDetailPage(product: results[i])));
        },
      ),
    );
  }
}

class _MenListProductPainter extends CustomPainter {
  final ProductModel product;
  _MenListProductPainter(this.product);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.18)..style = PaintingStyle.fill;
    final cx = size.width * 0.5;
    if (product.subCategory == 'Trousers' || product.subCategory == 'Denim') {
      final path = Path();
      path.moveTo(cx - 26, 0); path.lineTo(cx + 26, 0);
      path.lineTo(cx + 18, size.height * 0.5); path.lineTo(cx + 26, size.height);
      path.lineTo(cx + 8, size.height); path.lineTo(cx, size.height * 0.55);
      path.lineTo(cx - 8, size.height); path.lineTo(cx - 26, size.height);
      path.lineTo(cx - 18, size.height * 0.5); path.close();
      canvas.drawPath(path, paint);
    } else {
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
