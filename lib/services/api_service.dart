import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// Service that communicates with the backend (Node.js/Express + MongoDB).
///
/// The backend is responsible for verifying the Firebase ID token and
/// performing CRUD operations against MongoDB.
///
/// ── Setup ─────────────────────────────────────────────────────────────────
/// Update [baseUrl] to point to your deployed backend server.
/// For local development during testing:
///   - Android emulator → http://10.0.2.2:3000/api
///   - iOS simulator    → http://localhost:3000/api
///   - Web / real device → http://<your-ip>:3000/api
/// ──────────────────────────────────────────────────────────────────────────
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // ═══════════════════════════════════════════════════════════════════════
  // TODO: Replace with your backend URL before deploying.
  // ═══════════════════════════════════════════════════════════════════════
  static const String baseUrl = 'http://localhost:3000/api';

  // ── Auth helpers ────────────────────────────────────────────────────────

  /// Get the current Firebase ID token for authenticated requests.
  Future<String?> _getIdToken() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Build standard headers with the Firebase auth token.
  Future<Map<String, String>> _headers() async {
    final token = await _getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Auth ────────────────────────────────────────────────────────────────

  /// Register or fetch the user from MongoDB after Firebase sign-in.
  ///
  /// Call this immediately after a successful Firebase Google Sign-In
  /// to ensure the user document exists in MongoDB.
  ///
  /// [role] can be "vendor" or "customer".
  Future<Map<String, dynamic>?> login({String role = 'vendor'}) async {
    try {
      final headers = await _headers();
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: jsonEncode({'role': role}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['user'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.login error: $e');
      return null;
    }
  }

  // ── User / Profile ─────────────────────────────────────────────────────

  /// Fetch the vendor's profile from MongoDB via backend.
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final headers = await _headers();
      final res = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getProfile error: $e');
      return null;
    }
  }

  /// Update the vendor's profile.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final headers = await _headers();
      final res = await http.put(
        Uri.parse('$baseUrl/users/me'),
        headers: headers,
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.updateProfile error: $e');
      return false;
    }
  }

  // ── Products ─────────────────────────────────────────────────────────────

  /// Fetch all products from MongoDB.
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final headers = await _headers();
      final res = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getProducts error: $e');
      return [];
    }
  }

  /// Create a new product.
  Future<bool> createProduct(Map<String, dynamic> product) async {
    try {
      final headers = await _headers();
      final res = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: jsonEncode(product),
      );
      return res.statusCode == 201;
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.createProduct error: $e');
      return false;
    }
  }

  /// Update an existing product.
  Future<bool> updateProduct(
      String productId, Map<String, dynamic> data) async {
    try {
      final headers = await _headers();
      final res = await http.put(
        Uri.parse('$baseUrl/products/$productId'),
        headers: headers,
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.updateProduct error: $e');
      return false;
    }
  }

  /// Delete a product.
  Future<bool> deleteProduct(String productId) async {
    try {
      final headers = await _headers();
      final res = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.deleteProduct error: $e');
      return false;
    }
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  /// Fetch all orders from MongoDB.
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final headers = await _headers();
      final res = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getOrders error: $e');
      return [];
    }
  }

  /// Update an order's status.
  Future<bool> updateOrderStatus(
      String orderId, String newStatus) async {
    try {
      final headers = await _headers();
      final res = await http.put(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: headers,
        body: jsonEncode({'status': newStatus}),
      );
      return res.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.updateOrderStatus error: $e');
      return false;
    }
  }

  // ── Offers ────────────────────────────────────────────────────────────────

  /// Fetch all offers from MongoDB.
  Future<List<Map<String, dynamic>>> getOffers() async {
    try {
      final headers = await _headers();
      final res = await http.get(
        Uri.parse('$baseUrl/offers'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.getOffers error: $e');
      return [];
    }
  }

  /// Create a new offer.
  Future<bool> createOffer(Map<String, dynamic> offer) async {
    try {
      final headers = await _headers();
      final res = await http.post(
        Uri.parse('$baseUrl/offers'),
        headers: headers,
        body: jsonEncode(offer),
      );
      return res.statusCode == 201;
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.createOffer error: $e');
      return false;
    }
  }

  /// Delete an offer.
  Future<bool> deleteOffer(String offerId) async {
    try {
      final headers = await _headers();
      final res = await http.delete(
        Uri.parse('$baseUrl/offers/$offerId'),
        headers: headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('ApiService.deleteOffer error: $e');
      return false;
    }
  }
}
