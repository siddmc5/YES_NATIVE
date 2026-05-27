import '../models/models.dart';

class OfferManager {
  // Singleton pattern
  OfferManager._privateConstructor();
  static final OfferManager _instance = OfferManager._privateConstructor();
  factory OfferManager() => _instance;

  // Internal mutable offers list, initialized from SampleData.offers
  final List<Map<String, dynamic>> _offers = List.from(SampleData.offers);

  // Public getter returning unmodifiable view
  List<Map<String, dynamic>> get offers => List.unmodifiable(_offers);

  // Add a new offer to the top of the list
  void addOffer({
    required String title,
    required String discount,
    required String code,
    required String productName,
  }) {
    final offer = {
      'title': title,
      'discount': discount,
      'code': code,
      'productName': productName,
    };
    _offers.insert(0, offer);
    // TODO: Persist to local storage if needed.
  }
}
