import 'api_service.dart';

class OfferManager {
  OfferManager._privateConstructor();
  static final OfferManager _instance = OfferManager._privateConstructor();
  factory OfferManager() => _instance;

  List<Map<String, dynamic>> _offers = [];

  List<Map<String, dynamic>> get offers => List.unmodifiable(_offers);

  /// Fetch all offers from the backend.
  Future<void> loadOffers() async {
    _offers = await ApiService.instance.getOffers();
  }

  /// Add a new offer via the backend API.
  Future<bool> addOffer({
    required String title,
    required String discount,
    required String code,
    required String productName,
  }) async {
    final success = await ApiService.instance.createOffer({
      'title': title,
      'discount': discount,
      'code': code,
      'productName': productName,
    });

    if (success) {
      // Reload to get the latest list from the backend
      await loadOffers();
    }
    return success;
  }

  /// Delete an offer by its MongoDB _id.
  Future<bool> deleteOffer(String offerId) async {
    final success = await ApiService.instance.deleteOffer(offerId);
    if (success) {
      _offers.removeWhere((o) => o['_id'] == offerId);
    }
    return success;
  }

  // Remove an offer at a specific index.
  void removeOfferAt(int index) {
    if (index >= 0 && index < _offers.length) {
      _offers.removeAt(index);
    }
  }
}
