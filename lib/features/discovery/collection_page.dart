import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';

class CollectionPage extends StatelessWidget {
  final String title;
  final String subtitle;

  const CollectionPage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.dark,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradientColors(),
                  ),
                ),
                child: Center(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = trendingProducts[index % trendingProducts.length];
                  return AnimatedBuilder(
                    animation: wishlistModel,
                    builder: (ctx, _) {
                      final isWishlisted =
                          wishlistModel.isWishlisted(product.id);
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: product.placeholderColor,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      wishlistModel.toggle(product.id);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: isWishlisted
                                            ? AppColors.primary
                                            : Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isWishlisted
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        size: 18,
                                        color: isWishlisted
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(product.price,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                childCount: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _gradientColors() {
    switch (title.toLowerCase()) {
      case 'women':
        return [AppColors.womenGradientTop, AppColors.womenGradientBottom];
      case 'men':
        return [AppColors.menCard, const Color(0xFF0D1829)];
      case 'kids':
        return [AppColors.kidsCard, const Color(0xFFB85A00)];
      default:
        return [AppColors.dark, AppColors.darkCard];
    }
  }
}
