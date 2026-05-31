import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/features/home/home_page.dart';
import 'package:flutter_application_1/features/discovery/explore_page.dart';
import 'package:flutter_application_1/features/shop/cart_page.dart';
import 'package:flutter_application_1/features/user/profile_page.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const ExplorePage(),
      const CartPage(),
      const ProfilePage(),
    ];
    _controllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    _controllers[0].forward();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTap(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.lightImpact();
    _controllers[_currentIndex].reverse();
    setState(() => _currentIndex = index);
    _controllers[index].forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.explore_rounded, 'label': 'Explore'},
      {'icon': Icons.shopping_bag_outlined, 'label': 'Cart'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = _currentIndex == i;
              return GestureDetector(
                onTap: () => _onTabTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: i == 2
                            ? AnimatedBuilder(
                                animation: cartModel,
                                builder: (_, __) => Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      items[i]['icon'] as IconData,
                                      color: isSelected ? AppColors.primary : const Color(0xFF9E9E9E),
                                      size: 24,
                                    ),
                                    if (cartModel.count > 0)
                                      Positioned(
                                        right: -6, top: -4,
                                        child: Container(
                                          width: 16, height: 16,
                                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                          child: Center(child: Text('${cartModel.count}',
                                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : Icon(
                                items[i]['icon'] as IconData,
                                color: isSelected ? AppColors.primary : const Color(0xFF9E9E9E),
                                size: 24,
                              ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
