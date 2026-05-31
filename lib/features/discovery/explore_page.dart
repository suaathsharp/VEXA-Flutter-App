import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/features/shop/product_detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final List<String> _tags = ['Trending Now', 'Women', 'Kids', 'Men\'s Wear', 'Dresses', 'Accessories'];
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeTag = 'Trending Now';
  List<ProductModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    var all = [...menProducts, ...womenProducts, ...kidsProducts];
    if (q.isNotEmpty) all = all.where((p) => p.name.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q)).toList();
    if (_activeTag == 'Women') return all.where((p) => p.category == 'women').toList();
    if (_activeTag == 'Kids') return all.where((p) => p.category == 'kids').toList();
    if (_activeTag == 'Men\'s Wear') return all.where((p) => p.category == 'men').toList();
    if (_activeTag == 'Dresses') return all.where((p) => p.subCategory == 'Dresses').toList();
    if (_activeTag == 'Accessories') return all.where((p) => p.subCategory == 'Accessories').toList();
    return all.take(16).toList(); // Trending
  }

  void _openProduct(ProductModel p) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Explore',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(
              body: Center(child: Text('QR Scanner Dummy Screen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ))),
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textPrimary)
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Search Field
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search for brands and products...',
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          // Horizontal Tags
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tags.length,
                itemBuilder: (context, index) {
                  final tag = _tags[index];
                  final active = tag == _activeTag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 8),
                    child: GestureDetector(
                      onTap: () { HapticFeedback.selectionClick(); setState(() => _activeTag = tag); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: active ? AppColors.primary : const Color(0xFFE5E7EB)),
                          boxShadow: active ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : null,
                        ),
                        child: Center(
                          child: Text(tag, style: TextStyle(
                            color: active ? Colors.white : const Color(0xFF4B5563),
                            fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w600)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Discovery Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildExploreCard(_filtered[i]),
                childCount: _filtered.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildExploreCard(ProductModel p) {
    return GestureDetector(
      onTap: () => _openProduct(p),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              Container(color: p.placeholderColor, child: Image.network(p.imageUrl, fit: BoxFit.cover, width: double.infinity)),
              Positioned(top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border_rounded, size: 14, color: AppColors.primary))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.brand.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(p.price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ]),
          ),
        ]),
      ),
    );
  }
}
