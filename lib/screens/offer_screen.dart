import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/offer_manager.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  final _titleController = TextEditingController();
  final _discountController = TextEditingController();
  final _codeController = TextEditingController();
  String? _selectedProduct;

  @override
  void dispose() {
    _titleController.dispose();
    _discountController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _saveOffer() {
    OfferManager().addOffer(
      title: _titleController.text.trim().isEmpty ? 'Untitled Offer' : _titleController.text.trim(),
      discount: _discountController.text.trim().isEmpty ? '0%' : _discountController.text.trim(),
      code: _codeController.text.trim().isEmpty ? 'CODE${DateTime.now().millisecondsSinceEpoch}' : _codeController.text.trim(),
      productName: _selectedProduct ?? 'Any',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offer created (demo)')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Offer'),
        backgroundColor: AppColors.bannerGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _discountController,
              decoration: const InputDecoration(
                labelText: 'Discount (e.g., 20%)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Coupon Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedProduct,
              decoration: const InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(),
              ),
              items: SampleData.products
                  .map((p) => DropdownMenuItem(value: p.name, child: Text(p.name)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedProduct = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Create', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
