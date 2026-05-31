import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/features/shop/cart_page.dart';
import 'package:flutter_application_1/core/widgets/hover_zoom.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/datastore/app_data_store.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String _selectedSize = '';
  Color _selectedColor = Colors.transparent;
  int _qty = 1;
  bool _descExpanded = false;
  int _imageIndex = 0;
  final PageController _pageController = PageController();

  late ProductModel _p;

  @override
  void initState() {
    super.initState();
    _p = widget.product;
    _selectedSize = _p.availableSizes.isNotEmpty
        ? _p.availableSizes[1 < _p.availableSizes.length ? 1 : 0]
        : '';
    _selectedColor =
        _p.availableColors.isNotEmpty ? _p.availableColors[0] : Colors.black;

    // Track product view in Cloud Firestore and activity logs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppDataStore>(context, listen: false).recordProductView(_p);
      }
    });
  }

  String get _totalPrice {
    final val =
        double.tryParse(_p.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return 'LKR ${(val * _qty).toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    cartModel.add(_p, size: _selectedSize, color: _selectedColor);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Added to cart 🛒'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _buyNow() {
    HapticFeedback.mediumImpact();
    cartModel.add(_p, size: _selectedSize, color: _selectedColor);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              _buildImageSection(),
              _buildProductInfo(),
            ]),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  Widget _buildImageSection() {
    return SizedBox(
      height: 340,
      child: Stack(children: [
        SizedBox(
          height: 340,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (idx) => setState(() => _imageIndex = idx),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product_image_${_p.id}_$index',
                child: Image.network(
                  _p.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (ctx, _, __) => Container(color: _p.placeholderColor),
                ),
              );
            },
          ),
        ),
        // Top buttons
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HoverZoom(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
                Row(children: [
                  // Share
                  HoverZoom(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showShareSheet();
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.share_outlined,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  // Wishlist
                  AnimatedBuilder(
                    animation: wishlistModel,
                    builder: (context, child) {
                      final isWL = wishlistModel.isWishlisted(_p.id);
                      return HoverZoom(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            wishlistModel.toggle(_p.id);
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isWL
                                  ? AppColors.primary
                                  : Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isWL
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ]),
              ],
            ),
          ),
        ),
        // Dot indicators
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _imageIndex ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _imageIndex
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  Widget _buildProductInfo() {
    return Container(
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildThumbnailRow(),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Brand + rating
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'VEXA MEN\'S WEAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              Row(children: [
                Icon(Icons.star_rounded,
                    size: 14, color: Colors.amber.shade600),
                Text(
                  ' ${_p.rating} (${_p.reviewCount})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ]),
            ]),
            const SizedBox(height: 6),
            Text(_p.name,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            // In stock
            Row(children: [
              const Icon(Icons.check_circle_rounded,
                  size: 14, color: Color(0xFF27AE60)),
              const SizedBox(width: 4),
              const Text('In Stock',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF27AE60),
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            // Price row
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(_p.price,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              if (_p.originalPrice != null) ...[
                const SizedBox(width: 10),
                Text(_p.originalPrice!,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textHint,
                        decoration: TextDecoration.lineThrough)),
              ],
              if (_p.discountPercent != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(_p.discountPercent!,
                      style: const TextStyle(
                          color: Color(0xFF27AE60),
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ]),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 20),

            // ── SIZE SELECTOR ─────────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('SELECT SIZE',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              GestureDetector(
                onTap: _showSizeGuide,
                child: const Text('Size Guide →',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _p.availableSizes.map((size) {
                final isSelected = size == _selectedSize;
                return HoverZoom(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedSize = size);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFDDDDDD),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          size,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── COLOR + QUANTITY ROW ──────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('COLOR',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Row(
                    children: _p.availableColors.map((color) {
                      final isSelected =
                          _selectedColor.toARGB32() == color.toARGB32();
                      return HoverZoom(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedColor = color);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 10),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: isSelected ? 2.5 : 0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ]),
              ),
              // Quantity
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('QUANTITY',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Row(children: [
                  _qtyBtn(Icons.remove_rounded, () {
                    setState(() {
                      if (_qty > 1) _qty--;
                    });
                  }),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('$_qty',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ),
                  _qtyBtn(Icons.add_rounded,
                      () => setState(() => _qty++)),
                ]),
              ]),
            ]),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 20),

            // ── PRODUCT DESCRIPTION ───────────────────────────────────
            GestureDetector(
              onTap: () =>
                  setState(() => _descExpanded = !_descExpanded),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                const Text('Product Description',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                Icon(
                  _descExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
              ]),
            ),
            if (_descExpanded) ...[
              const SizedBox(height: 12),
              Text(_p.description,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.6)),
            ],
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 20),

            // ── CUSTOMER REVIEWS ──────────────────────────────────────
            const Text('Customer Reviews',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('${_p.rating}',
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _starRow(_p.rating),
                const SizedBox(height: 4),
                Text(
                  'BASED ON ${_p.reviewCount} RATINGS',
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3),
                ),
              ]),
              const Spacer(),
              const Text('VIEW ALL',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ]),
            if (_p.reviews.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._p.reviews.map((r) => _buildReviewCard(r)),
            ] else ...[
              const SizedBox(height: 12),
              Text('No reviews yet.',
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 13)),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _buildThumbnailRow() {
    return Container(
      color: const Color(0xFFF8F8F8),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        children: List.generate(4, (i) {
          return HoverZoom(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                setState(() => _imageIndex = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 10),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _p.placeholderColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _imageIndex == i ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  _p.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => Container(color: _p.placeholderColor),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _starRow(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star_rounded,
              size: 16, color: Colors.amber.shade600);
        }
        if (i < rating) {
          return Icon(Icons.star_half_rounded,
              size: 16, color: Colors.amber.shade600);
        }
        return Icon(Icons.star_border_rounded,
            size: 16, color: Colors.amber.shade600);
      }),
    );
  }

  Widget _buildReviewCard(ReviewModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(r.name,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text(r.timeAgo,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textHint)),
        ]),
        const SizedBox(height: 6),
        Text(r.text,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5)),
      ]),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return HoverZoom(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
          ),
          child: Icon(icon, size: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
          child: Row(children: [
            // Total price
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('TOTAL PRICE',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(_totalPrice,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
            ]),
            const SizedBox(width: 14),
            // Add to Cart
            Expanded(
              child: HoverZoom(
                child: GestureDetector(
                  onTap: _addToCart,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border:
                          Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: const Center(
                      child: Text('ADD TO CART',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Buy Now
            HoverZoom(
              child: GestureDetector(
                onTap: _buyNow,
                child: Container(
                  height: 48,
                  width: 110,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('BUY NOW',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showSizeGuide() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text('Size Guide',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(8)),
            children: const [
              TableRow(children: [
                _SizeTableCell('Size'),
                _SizeTableCell('Chest (in)'),
                _SizeTableCell('Waist (in)'),
              ]),
              TableRow(children: [
                _SizeTableCell('XS'),
                _SizeTableCell('34-36'),
                _SizeTableCell('28-30'),
              ]),
              TableRow(children: [
                _SizeTableCell('S'),
                _SizeTableCell('36-38'),
                _SizeTableCell('30-32'),
              ]),
              TableRow(children: [
                _SizeTableCell('M'),
                _SizeTableCell('38-40'),
                _SizeTableCell('32-34'),
              ]),
              TableRow(children: [
                _SizeTableCell('L'),
                _SizeTableCell('40-42'),
                _SizeTableCell('34-36'),
              ]),
              TableRow(children: [
                _SizeTableCell('XL'),
                _SizeTableCell('42-44'),
                _SizeTableCell('36-38'),
              ]),
              TableRow(children: [
                _SizeTableCell('XXL'),
                _SizeTableCell('44-46'),
                _SizeTableCell('38-40'),
              ]),
            ],
          ),
        ]),
      ),
    );
  }

  void _showShareSheet() {
    final options = [
      (
        'WhatsApp',
        Icons.chat_rounded,
        const Color(0xFF25D366),
      ),
      (
        'Instagram',
        Icons.camera_alt_rounded,
        const Color(0xFFE1306C),
      ),
      (
        'Copy Link',
        Icons.link_rounded,
        const Color(0xFF666666),
      ),
      (
        'More',
        Icons.more_horiz_rounded,
        const Color(0xFF999999),
      ),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text('Share Product',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: options.map((opt) {
              final label = opt.$1;
              final icon = opt.$2;
              final color = opt.$3;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('$label share selected'),
                    backgroundColor: color,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ));
                },
                child: Column(children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ]),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }
}

// ── Size Table Cell Widget ────────────────────────────────────────────────
class _SizeTableCell extends StatelessWidget {
  final String text;
  const _SizeTableCell(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
      );
}
