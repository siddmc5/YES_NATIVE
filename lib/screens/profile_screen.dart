import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../theme_provider.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  String _storeName = 'Yes Native Store';
  String _storeEmail = 'yesnative@vendor.com';
  String _storePhone = '+91 98765 43210';
  String _storeAddress = '12, MG Road, Bengaluru - 560001';
  String _storeDescription =
      'Premium traditional superfoods and wellness products since 2020.';

  final String _upiId = 'yesnative@upi';
  final String _bankName = 'State Bank of India';
  final String _accountNo = 'XXXX-XXXX-1234';

  void _showStoreProfileEdit() {
    final nameCtrl = TextEditingController(text: _storeName);
    final emailCtrl = TextEditingController(text: _storeEmail);
    final phoneCtrl = TextEditingController(text: _storePhone);
    final addrCtrl = TextEditingController(text: _storeAddress);
    final descCtrl = TextEditingController(text: _storeDescription);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Store Profile',
                      style: AppTextStyles.heading2.copyWith(
                          color: context.colors.textDark)),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildField('Store Name', nameCtrl),
              const SizedBox(height: 14),
              _buildField('Email', emailCtrl),
              const SizedBox(height: 14),
              _buildField('Phone', phoneCtrl),
              const SizedBox(height: 14),
              _buildField('Address', addrCtrl, maxLines: 2),
              const SizedBox(height: 14),
              _buildField('Description', descCtrl, maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _storeName = nameCtrl.text;
                      _storeEmail = emailCtrl.text;
                      _storePhone = phoneCtrl.text;
                      _storeAddress = addrCtrl.text;
                      _storeDescription = descCtrl.text;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: colors.textDark,
                fontFamily: 'Poppins')),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showPaymentSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Settings',
                      style: AppTextStyles.heading2.copyWith(
                          color: context.colors.textDark)),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _PaymentOption(
                icon: Icons.account_balance_rounded,
                title: 'Bank Account',
                subtitle: '$_bankName • $_accountNo',
                colors: context.colors,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _PaymentOption(
                icon: Icons.phone_android_rounded,
                title: 'UPI ID',
                subtitle: _upiId,
                colors: context.colors,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _PaymentOption(
                icon: Icons.qr_code_rounded,
                title: 'QR Code',
                subtitle: 'Scan to pay',
                colors: context.colors,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _PaymentOption(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Wallet',
                subtitle: 'Balance: ₹12,450',
                colors: context.colors,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: context.colors.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Payouts are processed every Monday',
                        style: TextStyle(
                            color: context.colors.textDark,
                            fontSize: 13,
                            fontFamily: 'Poppins'),
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
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Store'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Store header
            Container(
              width: double.infinity,
              color: colors.cardBackground,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.store_rounded,
                            color: colors.primary, size: 40),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(_storeName,
                      style: AppTextStyles.heading2.copyWith(color: colors.primary)),
                  const SizedBox(height: 4),
                  Text(_storeEmail,
                      style: TextStyle(
                          color: colors.textMedium,
                          fontFamily: 'Poppins',
                          fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StoreStatPill(label: 'Products', value: '8', colors: colors),
                      const SizedBox(width: 12),
                      _StoreStatPill(label: 'Orders', value: '312', colors: colors),
                      const SizedBox(width: 12),
                      _StoreStatPill(label: 'Rating', value: '4.8 ★', colors: colors),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Store Profile
            _MenuSection(
              title: 'Store Management',
              colors: colors,
              items: [
                _MenuItemData(
                  icon: Icons.storefront_outlined,
                  label: 'Store Profile',
                  subtitle: 'Name, Email, Address, Description',
                  onTap: _showStoreProfileEdit,
                ),
                _MenuItemData(
                  icon: Icons.payment_outlined,
                  label: 'Payment Settings',
                  subtitle: 'Bank, UPI, QR, Wallet',
                  onTap: _showPaymentSettings,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Theme toggle
            _ThemeToggleCard(
              colors: colors,
              isDark: themeProvider.isDarkMode,
              onToggle: () => themeProvider.toggleTheme(),
            ),
            const SizedBox(height: 10),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      FadeSlideRoute(page: const LoginScreen()),
                      (_) => false,
                    );
                  },
                  icon: Icon(Icons.logout_rounded, color: colors.error),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────

class _StoreStatPill extends StatelessWidget {
  final String label;
  final String value;
  final ThemeColors colors;

  const _StoreStatPill({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.primary,
              fontFamily: 'Poppins',
            ),
          ),
          Text(label,
              style: TextStyle(
                  color: colors.textLight,
                  fontSize: 11,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
}

class _MenuSection extends StatelessWidget {
  final String title;
  final ThemeColors colors;
  final List<_MenuItemData> items;

  const _MenuSection({
    required this.title,
    required this.colors,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: colors.textLight,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          ...items.map((item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(item.icon, color: colors.primary, size: 22),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: colors.textDark,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textLight,
                    fontFamily: 'Poppins',
                  ),
                ),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: colors.textLight),
                onTap: item.onTap,
              )),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeColors colors;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.textDark,
                        fontFamily: 'Poppins',
                        fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(
                        color: colors.textLight,
                        fontSize: 12,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.textLight, size: 20),
        ],
      ),
    );
  }
}

class _ThemeToggleCard extends StatelessWidget {
  final ThemeColors colors;
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggleCard({
    required this.colors,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: colors.primary,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isDark ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: colors.textDark,
              ),
            ),
          ),
          Switch(
            value: isDark,
            onChanged: (_) => onToggle(),
            activeThumbColor: colors.primary,
          ),
        ],
      ),
    );
  }
}
