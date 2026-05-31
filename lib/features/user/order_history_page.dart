import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/features/shop/cart_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String _activeTab = 'All';
  final List<String> _tabs = ['All', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  // Mock data to match the Figma exact design
  final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 'VX-99283',
      'date': '18 Jan 2025',
      'status': 'Processing',
      'itemCount': 3,
      'total': '8,700',
      'images': [
        'https://images.unsplash.com/photo-1596755094514-f87e32f08286?w=200',
        'https://images.unsplash.com/photo-1519238321852-5a21e0eb7e31?w=200',
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=200',
      ],
      'deliveryInfo': 'Est. Delivery: 21–23 Jan 2025',
      'deliveryIcon': Icons.local_shipping_outlined,
      'action': 'REORDER',
      'actionIcon': Icons.refresh_rounded,
    },
    {
      'id': 'VX-88120',
      'date': '12 Jan 2025',
      'status': 'Delivered',
      'itemCount': 1,
      'total': '4,200',
      'images': [
        'https://images.unsplash.com/photo-1542272604-787c3835535d?w=200',
      ],
      'deliveryInfo': 'Delivered on 14 Jan 2025',
      'deliveryIcon': Icons.check_circle_outline_rounded,
      'action': 'REORDER',
      'actionIcon': Icons.refresh_rounded,
    },
    {
      'id': 'VX-99104',
      'date': '16 Jan 2025',
      'status': 'Shipped',
      'itemCount': 2,
      'total': '12,400',
      'images': [
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=200',
        'https://images.unsplash.com/photo-1594938298596-eb5fd3f502ff?w=200',
      ],
      'deliveryInfo': 'Arriving Tomorrow',
      'deliveryIcon': Icons.local_shipping_outlined,
      'action': 'TRACK',
      'actionIcon': Icons.location_on_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredOrders = _activeTab == 'All'
        ? _mockOrders
        : _mockOrders.where((o) => o['status'] == _activeTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Very light grey background
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: GestureDetector(
          onTap: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
        ),
        title: const Text('My Orders', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        titleSpacing: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.filter_list_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(child: Text('No orders found', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _tabs.map((tab) {
            final isActive = tab == _activeTab;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeTab = tab);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab,
                      style: TextStyle(
                        color: isActive ? AppColors.primary : const Color(0xFF9CA3AF),
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 2,
                      width: 16,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: ID, Date, Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ORDER ID: ${order['id']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(order['date'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              _buildStatusBadge(order['status']),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 2: Images and Price
          Row(
            children: [
              // Overlapping Images
              SizedBox(
                width: 100,
                height: 50,
                child: Stack(
                  children: [
                    for (int i = 0; i < (order['images'] as List).length; i++)
                      Positioned(
                        left: i * 25.0,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: DecorationImage(
                              image: NetworkImage(order['images'][i]),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${order['itemCount']} ${order['itemCount'] == 1 ? "Item" : "Items"}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  const SizedBox(height: 2),
                  Text('LKR ${order['total']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 3: Delivery Info Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(order['deliveryIcon'], size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Text(order['deliveryInfo'], style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Row 4: Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text('VIEW DETAILS', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.mediumImpact(); },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(order['action'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        const SizedBox(width: 6),
                        Icon(order['actionIcon'], color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'Processing':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        icon = Icons.hourglass_top_rounded;
        break;
      case 'Delivered':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        icon = Icons.check_box_rounded;
        break;
      case 'Shipped':
      default:
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF3730A3);
        icon = Icons.inventory_2_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navIcon(Icons.home_outlined, false, () => Navigator.of(context).popUntil((r) => r.isFirst)),
              _navIcon(Icons.search_rounded, false, () {}),
              _navIcon(Icons.shopping_bag_outlined, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()))),
              _navIcon(Icons.person_outline_rounded, true, () {}), // Currently on profile/orders flow
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.primary : const Color(0xFF9CA3AF), size: 24),
            if (active) ...[
              const SizedBox(height: 4),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
            ]
          ],
        ),
      ),
    );
  }
}
