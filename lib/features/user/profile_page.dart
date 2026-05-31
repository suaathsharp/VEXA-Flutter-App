import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/datastore/app_data_store.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/data/models/app_models.dart';
import 'package:flutter_application_1/features/user/order_history_page.dart';
import 'package:flutter_application_1/features/user/wishlist_page.dart';
import 'package:flutter_application_1/features/shop/checkout/add_address_screen.dart';
import 'package:flutter_application_1/features/auth/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showEditProfileSheet() {
    final store = Provider.of<AppDataStore>(context, listen: false);
    final nameCtrl = TextEditingController(text: store.user.name);
    final emailCtrl = TextEditingController(text: store.user.email);
    final phoneCtrl = TextEditingController(text: store.user.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 24, left: 24, right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close_rounded, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 24),
            _inputField('Full Name', nameCtrl),
            const SizedBox(height: 16),
            _inputField('Email', emailCtrl),
            const SizedBox(height: 16),
            _inputField('Phone Number', phoneCtrl),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
                HapticFeedback.mediumImpact();
                await store.updateProfile(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                );
                if (mounted) {
                  Navigator.pop(context);
                  _showSnackbar('Profile updated successfully!');
                }
              },
              child: Container(
                height: 52, width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Center(child: Text('SAVE CHANGES', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
          child: TextField(
            controller: ctrl,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Text('No new notifications', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLanguageSheet() {
    final store = Provider.of<AppDataStore>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _langTile('English', store),
            _langTile('Sinhala', store),
            _langTile('Tamil', store),
          ],
        ),
      ),
    );
  }

  Widget _langTile(String lang, AppDataStore store) => ListTile(
    title: Text(lang),
    trailing: store.user.language == lang ? const Icon(Icons.check, color: AppColors.primary) : null,
    onTap: () {
      store.updateProfile(language: lang);
      Navigator.pop(context);
    },
  );

  void _showCurrencySheet() {
    final store = Provider.of<AppDataStore>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Currency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _currTile('LKR', store),
            _currTile('USD', store),
            _currTile('EUR', store),
          ],
        ),
      ),
    );
  }

  Widget _currTile(String curr, AppDataStore store) => ListTile(
    title: Text(curr),
    trailing: store.user.currency == curr ? const Icon(Icons.check, color: AppColors.primary) : null,
    onTap: () {
      store.updateProfile(currency: curr);
      Navigator.pop(context);
    },
  );

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppDataStore>();
    final user = store.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            leadingWidth: 48,
            leading: const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 24),
            ),
            title: const Text('VEXA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: 3)),
            centerTitle: true,
            actions: [
              AnimatedBuilder(
                animation: cartModel,
                builder: (_, _) => Stack(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                    ),
                    if (cartModel.count > 0)
                      Positioned(
                        right: 10, top: 2,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: Center(child: Text('${cartModel.count}',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.black,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Stack(
                        children: [
                          Container(
                            width: 84, height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              ),
                              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20)],
                            ),
                            child: Center(
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, size: 13, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(user.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _stat(user.orderCount.toString(), 'ORDERS'),
                          _vDivider(),
                          _stat(user.wishlistCount.toString(), 'WISHLIST'),
                          _vDivider(),
                          _stat(user.reviewCount.toString(), 'REVIEWS'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _actionButton(Icons.edit_rounded, 'Edit Profile', _showEditProfileSheet),
                          const SizedBox(width: 10),
                          _actionButton(Icons.share_rounded, 'Share', () {}),
                          const SizedBox(width: 10),
                          _actionButton(Icons.settings_rounded, null, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _section('MY ACCOUNT', [
                    _tile(Icons.edit_outlined, 'Edit Profile', _showEditProfileSheet),
                    _tile(Icons.shopping_bag_outlined, 'My Orders', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryPage()))),
                    _tile(Icons.favorite_border_rounded, 'My Wishlist', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage()))),
                    _tile(Icons.location_on_outlined, 'Saved Addresses', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()))),
                    _tile(Icons.notifications_outlined, 'Notifications', () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _buildNotificationsSheet(context),
                      );
                    }),
                  ]),
                  const SizedBox(height: 14),
                  _section('PREFERENCES', [
                    _tileWithTrailing(Icons.language_rounded, 'Language', user.language, _showLanguageSheet),
                    _tileWithTrailing(Icons.attach_money_rounded, 'Currency', user.currency, _showCurrencySheet),
                    _tileWithSwitch(Icons.contrast_rounded, 'Appearance'),
                  ]),
                  const SizedBox(height: 14),
                  _section('SUPPORT', [
                    _tile(Icons.chat_bubble_outline_rounded, 'Chat Support', () => _showSnackbar('Connecting to Chat Support...')),
                    _tile(Icons.help_outline_rounded, 'FAQ', () => _showSnackbar('Opening FAQ...')),
                    _tile(Icons.description_outlined, 'Terms & Privacy', () => _showSnackbar('Opening Terms & Privacy...')),
                    _tile(Icons.info_outline_rounded, 'About VEXA', () => _showSnackbar('About VEXA v1.0.0')),
                  ]),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      final store = Provider.of<AppDataStore>(context, listen: false);
                      await store.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, _, _) => const LoginScreen(),
                            transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _stat(String val, String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(children: [
      Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, letterSpacing: 0.5, fontWeight: FontWeight.w500)),
    ]),
  );

  static Widget _vDivider() => Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2));

  static Widget _actionButton(IconData icon, String? label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: label != null ? 14 : 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          if (label != null) ...[
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    ),
  );

  static Widget _section(String title, List<Widget> tiles) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)),
      ),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(children: tiles),
        ),
      ),
    ],
  );

  static Widget _tile(IconData icon, String label, VoidCallback onTap) => InkWell(
    onTap: () { HapticFeedback.selectionClick(); onTap(); },
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
        const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textHint),
      ]),
    ),
  );

  static Widget _tileWithTrailing(IconData icon, String label, String trailing, [VoidCallback? onTap]) => InkWell(
    onTap: () {
      if (onTap != null) {
        HapticFeedback.lightImpact();
        onTap();
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
        Text(trailing, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
    ),
  );

  static Widget _tileWithSwitch(IconData icon, String label) => _SwitchTile(icon: icon, label: label);
}

class _SwitchTile extends StatefulWidget {
  final IconData icon;
  final String label;
  const _SwitchTile({required this.icon, required this.label});
  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  bool _val = false;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Icon(widget.icon, size: 20, color: AppColors.textSecondary),
      const SizedBox(width: 14),
      Expanded(child: Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
      Switch(value: _val, onChanged: (v) => setState(() => _val = v),
        activeThumbColor: AppColors.primary, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    ]),
  );
}
