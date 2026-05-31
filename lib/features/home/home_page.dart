import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/features/discovery/category_page.dart';
import 'package:flutter_application_1/features/discovery/collection_page.dart';
import 'package:flutter_application_1/features/discovery/all_trending_page.dart';
import 'package:flutter_application_1/features/home/men_section_page.dart';
import 'package:flutter_application_1/features/home/women_section_page.dart';
import 'package:flutter_application_1/features/home/kids_section_page.dart';
import 'package:flutter_application_1/features/shop/product_detail_page.dart';
import 'package:flutter_application_1/features/shop/cart_page.dart';
import 'package:flutter_application_1/core/widgets/hover_zoom.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/datastore/app_data_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigate(Widget page) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => page,
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8), // Match the light off-white background
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Top App Bar ──────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader()),

          // ── Search Bar ───────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildSearchBar()),

          // ── Hero Banner ──────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeroBanner()),

          // ── Shop By Section ──────────────────────────────────────────
          SliverToBoxAdapter(child: _buildShopBySection()),

          // ── Trending Now ─────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildTrendingSection()),

          // ── Categories ───────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildCategoriesSection()),

          // ── Bottom Padding ───────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  // ────────────────────────────────────────────────────────────────────────
  //  HEADER
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final store = Provider.of<AppDataStore>(context);
    final userName = store.user.name;

    return Container(
      color: AppColors.dark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 18,
      ),
      child: Row(
        children: [
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: Color(0xFFB0B0C0),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Hello, $userName ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Text('👋', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ],
            ),
          ),

          // Notification Bell
          Material(
            color: Colors.transparent,
            child: HoverZoom(
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                },
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Bag / Orders Icon
          Material(
            color: Colors.transparent,
            child: HoverZoom(
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CartPage()));
                },
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.dark, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //  SEARCH BAR
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFFF8F8F8),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded,
                color: Colors.grey.shade400, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search VEXA...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            // Filter icon
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //  HERO BANNER
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      color: const Color(0xFFF8F8F8),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: HoverZoom(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _navigate(const CollectionPage(title: 'New Collection', subtitle: '2025 Summer Edit'));
          },
          child: Container(
            height: 185,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF2A1A4E),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1515347619362-75efb60882e7?w=800'),
                fit: BoxFit.cover,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF5E6CC), borderRadius: BorderRadius.circular(6)),
                        child: const Text('NEW COLLECTION', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                      ),
                      const SizedBox(height: 10),
                      const Text('2025 Summer Edit', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, height: 1.1)),
                      const SizedBox(height: 6),
                      const Text('Starting from LKR 1,499', style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 12, fontWeight: FontWeight.w400)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('SHOP NOW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //  SHOP BY SECTION
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildShopBySection() {
    return Container(
      color: const Color(0xFFF8F8F8),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop By Section',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Women – large card
          _buildWomenCard(),
          const SizedBox(height: 10),

          // Men + Kids – row
          Row(
            children: [
              Expanded(child: _buildSectionCard('MEN', AppColors.menCard, 'https://images.unsplash.com/photo-1617137968427-85924c800a22?w=800')),
              const SizedBox(width: 10),
              Expanded(child: _buildSectionCard('KIDS', AppColors.kidsCard, 'https://images.unsplash.com/photo-1514090458221-65bb69cf63e6?w=800')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWomenCard() {
    return HoverZoom(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigate(const WomenSectionPage());
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF6B1B4A),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800'),
              fit: BoxFit.cover,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Container(color: Colors.black.withValues(alpha: 0.3)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('WOMEN', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    SizedBox(height: 4),
                    Text('New Arrivals', style: TextStyle(color: Color(0xFFDDAACC), fontSize: 13, fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16, // Arrow positioned neatly on the right
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String label, Color fallbackColor, String imageUrl) {
    return HoverZoom(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (label == 'MEN') { _navigate(const MenSectionPage()); return; }
          if (label == 'KIDS') { _navigate(const KidsSectionPage()); return; }
        },
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: fallbackColor,
            borderRadius: BorderRadius.circular(18),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Container(color: Colors.black.withValues(alpha: 0.35)),
              Center(
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //  TRENDING NOW
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildTrendingSection() {
    return Container(
      color: const Color(0xFFF8F8F8),
      padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text(
                      'Trending Now ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text('🔥', style: TextStyle(fontSize: 16)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _navigate(const AllTrendingPage());
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Horizontal scroll
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: trendingProducts.length,
              itemBuilder: (context, index) {
                final product = trendingProducts[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: 14,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: _buildProductCard(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return AnimatedBuilder(
      animation: Listenable.merge([wishlistModel, cartModel]),
      builder: (context, _) {
        final isWishlisted = wishlistModel.isWishlisted(product.id);
        return HoverZoom(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _navigate(ProductDetailPage(product: product));
            },
            child: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image area
                  Stack(
                    children: [
                      Container(
                        height: 190,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: product.placeholderColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Container(color: product.placeholderColor),
                        ),
                      ),
                      // Wishlist button
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            wishlistModel.toggle(product.id);
                            if (!isWishlisted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${product.name} added to wishlist ❤️'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Name & price
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.price,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //  CATEGORIES
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildCategoriesSection() {
    final categories = [
      {'label': 'SHIRTS', 'icon': Icons.dry_cleaning_outlined},
      {'label': 'TROUSERS', 'icon': Icons.checkroom_outlined},
      {'label': 'T-SHIRTS', 'icon': Icons.checkroom_rounded},
      {'label': 'DENIM', 'icon': Icons.grid_view_rounded},
      {'label': 'DRESSES', 'icon': Icons.accessibility_new_rounded},
      {'label': 'FOOTWEAR', 'icon': Icons.directions_walk_outlined},
      {'label': 'ACCESSORIES', 'icon': Icons.watch_outlined},
      {'label': 'MORE', 'icon': Icons.grid_view_rounded},
    ];

    return Container(
      color: const Color(0xFFF8F8F8),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _buildCategoryItem(
                cat['label'] as String,
                cat['icon'] as IconData,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon) {
    return HoverZoom(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigate(CategoryPage(categoryName: label));
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
