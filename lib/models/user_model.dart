/// Vendor user model that maps to the MongoDB `users` collection.
///
/// Both this vendor app and the future user (customer) app will share
/// the same Firebase Auth project. The `role` field distinguishes
/// vendors from customers.
class VendorUser {
  /// Firebase Auth UID (unique identifier).
  final String uid;

  /// Display name from Google profile.
  final String displayName;

  /// Email from Google profile.
  final String email;

  /// URL of the user's Google profile photo.
  final String? photoUrl;

  /// Role: "vendor" for vendor-side, "customer" for user-side.
  final String role;

  /// Vendor-specific fields (only relevant when role == "vendor").
  final String? businessName;
  final String? phone;
  final String? address;

  /// Timestamp when the user document was created in MongoDB.
  final DateTime? createdAt;

  /// Timestamp of the last update.
  final DateTime? updatedAt;

  const VendorUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.role = 'vendor',
    this.businessName,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a [VendorUser] from a JSON map (returned by the backend API).
  factory VendorUser.fromJson(Map<String, dynamic> json) {
    return VendorUser(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] as String? ?? 'vendor',
      businessName: json['businessName'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to a JSON map for sending to the backend.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'businessName': businessName,
      'phone': phone,
      'address': address,
    };
  }
}
