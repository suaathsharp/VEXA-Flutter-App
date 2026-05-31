import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;

  const CategoryPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Map categoryName to model subCategory
    final List<ProductModel> filteredProducts = allProducts.where((p) {
      final name = categoryName.toUpperCase();
      if (name == 'SHIRTS') return p.subCategory == 'Shirts';
      if (name == 'TROUSERS') return p.subCategory == 'Trousers' || p.subCategory == 'Bottoms';
      if (name == 'T-SHIRTS') return p.subCategory == 'T-Shirts';
      if (name == 'DENIM') return p.subCategory == 'Denim';
      if (name == 'DRESSES') return p.subCategory == 'Dresses' || p.subCategory == 'Frocks';
      if (name == 'FOOTWEAR') return p.subCategory == 'Footwear';
      if (name == 'ACCESSORIES') return p.subCategory == 'Accessories';
      return true; // Default to all if 'MORE' or unknown
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.tune_rounded, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: filteredProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No products in $categoryName',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
          return AnimatedBuilder(
            animation: wishlistModel,
            builder: (ctx, _) {
              final isWishlisted = wishlistModel.isWishlisted(product.id);
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
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
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: product.placeholderColor,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: product.placeholderColor),
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
                              duration: const Duration(milliseconds: 200),
                              width: 32,
                              height: 32,
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
                                size: 16,
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
      ),
    );
  }
}
