import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/offer_manager.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  final OfferManager _manager = OfferManager();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    await _manager.loadOffers();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _createOffer() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateOfferSheet(),
    );

    if (result == null || !mounted) return;

    setState(() => _isLoading = true);
    final success = await _manager.addOffer(
      title: result['title'] ?? 'Untitled Offer',
      discount: result['discount'] ?? '0%',
      code: result['code'] ?? 'CODE${DateTime.now().millisecondsSinceEpoch}',
      productName: result['productName'] ?? 'Any',
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Offer created successfully' : 'Failed to create offer'),
        ),
      );
    }
  }

  Future<void> _deleteOffer(String offerId) async {
    final success = await _manager.deleteOffer(offerId);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Offer deleted' : 'Failed to delete offer'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final offers = _manager.offers;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Offers'),
        backgroundColor: colors.bannerGreen,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _createOffer,
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : offers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_offer_outlined,
                          size: 48, color: colors.textLight),
                      const SizedBox(height: 12),
                      Text('No offers yet',
                          style: TextStyle(
                              color: colors.textMedium,
                              fontSize: 16,
                              fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      Text('Tap + to create your first offer',
                          style: TextStyle(
                              color: colors.textLight,
                              fontSize: 13,
                              fontFamily: 'Poppins')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOffers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: offers.length,
                    itemBuilder: (ctx, i) {
                      final offer = offers[i];
                      return _OfferCard(
                        title: offer['title'] as String? ?? '',
                        discount: offer['discount'] as String? ?? '',
                        code: offer['code'] as String? ?? '',
                        productName: offer['productName'] as String? ?? '',
                        offerId: offer['_id'] as String? ?? '',
                        onDelete: _deleteOffer,
                        colors: colors,
                      );
                    },
                  ),
                ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String title;
  final String discount;
  final String code;
  final String productName;
  final String offerId;
  final Function(String) onDelete;
  final ThemeColors colors;

  const _OfferCard({
    required this.title,
    required this.discount,
    required this.code,
    required this.productName,
    required this.offerId,
    required this.onDelete,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.discount_outlined,
                color: colors.primary, size: 24),
          ),
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
                const SizedBox(height: 4),
                Text('Discount: $discount  |  Code: $code',
                    style: TextStyle(
                        color: colors.textLight,
                        fontSize: 12,
                        fontFamily: 'Poppins')),
                Text('Product: $productName',
                    style: TextStyle(
                        color: colors.textLight,
                        fontSize: 11,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  title: Text('Delete Offer',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: colors.textDark)),
                  content: Text('Remove "$title"?',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: colors.textMedium)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: colors.textLight,
                              fontFamily: 'Poppins')),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onDelete(offerId);
                      },
                      child: Text('Delete',
                          style: TextStyle(
                              color: colors.error,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
          ),
        ],
      ),
    );
  }
}

class _CreateOfferSheet extends StatefulWidget {
  const _CreateOfferSheet();

  @override
  State<_CreateOfferSheet> createState() => _CreateOfferSheetState();
}

class _CreateOfferSheetState extends State<_CreateOfferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _discountController = TextEditingController();
  final _codeController = TextEditingController();
  final _productController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _discountController.dispose();
    _codeController.dispose();
    _productController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'title': _titleController.text.trim().isEmpty
          ? 'Untitled Offer'
          : _titleController.text.trim(),
      'discount': _discountController.text.trim().isEmpty
          ? '0%'
          : _discountController.text.trim(),
      'code': _codeController.text.trim().isEmpty
          ? 'CODE${DateTime.now().millisecondsSinceEpoch}'
          : _codeController.text.trim(),
      'productName': _productController.text.trim().isEmpty
          ? 'Any'
          : _productController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Create Offer',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textDark,
                      fontFamily: 'Poppins')),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Monsoon Superfoods Deal',
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _discountController,
                decoration: InputDecoration(
                  labelText: 'Discount',
                  hintText: 'e.g. 20% or ₹50 off',
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Coupon Code',
                  hintText: 'e.g. MONSOON20',
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Code is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _productController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g. SlimSure Lite (or "Any")',
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Create Offer',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
