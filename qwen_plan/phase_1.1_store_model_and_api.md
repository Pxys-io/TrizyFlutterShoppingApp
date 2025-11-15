# Phase 1.1: Enhanced Store Model and API Service Implementation

## Feature Overview
Implement a comprehensive Store model and API service to support multistore functionality based on the backend API endpoints. This phase will enhance the existing basic Store model to include all fields required by the API and implement the store-specific API service to communicate with the backend endpoints.

## Related API Endpoint
- **POST** `/api/stores` - Create a new store (Admin only, requires admin access)
- **GET** `/api/storeOrders?storeId=` - Get orders for a specific store (Merchant access)

## Current Dart Files
- `lib/models/store/store_model.dart` - Basic Store model (needs enhancement)
- `lib/utils/api_endpoints.dart` - API endpoints configuration (needs store endpoints)

## Files to Create
- `lib/models/store/store_model.dart` - Enhanced Store model (to be updated)
- `lib/services/stores_api_service.dart` - Store API service
- `lib/repositories/stores_repository.dart` - Store repository
- `lib/models/store/store_response_model.dart` - Response model for store operations
- `lib/models/store/store_request_model.dart` - Request model for store creation

## Enhanced Store Model Structure
```dart
class Store {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final String phone;
  final String email;
  final String website;
  final List<String> merchantIds;  // IDs of merchants who manage this store
  final String ownerId;            // Primary owner of the store
  final String storeLogoUrl;
  final String coverImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating;
  final int totalReviews;
  final Map<String, dynamic> businessHours; // {day: {open, close}}
  final List<String> categories;    // Categories the store operates in
  final String taxId;              // Store's tax identification
  final String businessId;         // Business registration ID
  final String storeType;          // e.g., 'physical', 'online', 'hybrid'
  final double commissionRate;     // Commission rate for the platform
  final String currency;           // Currency code for the store
  final double minimumOrderAmount; // Minimum order amount for this store
  final double deliveryFee;        // Delivery fee for this store
  final int deliveryTimeInMinutes; // Estimated delivery time
  final List<String> paymentMethods; // Payment methods accepted by the store
  final bool isVerified;           // Whether the store is verified by admin
  final DateTime? verifiedAt;      // When the store was verified
  final String? verificationNotes; // Notes from admin regarding verification
  final String? rejectionReason;   // If store was rejected, the reason
  final bool isSuspended;          // Whether the store is temporarily suspended
  final String? suspensionReason;  // Reason for suspension if applicable
  final String adminNotes;         // Internal notes for admin use
  final Map<String, dynamic> settings; // Additional store-specific settings

  Store({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.phone,
    required this.email,
    required this.website,
    required this.merchantIds,
    required this.ownerId,
    required this.storeLogoUrl,
    required this.coverImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.rating,
    required this.totalReviews,
    required this.businessHours,
    required this.categories,
    required this.taxId,
    required this.businessId,
    required this.storeType,
    required this.commissionRate,
    required this.currency,
    required this.minimumOrderAmount,
    required this.deliveryFee,
    required this.deliveryTimeInMinutes,
    required this.paymentMethods,
    required this.isVerified,
    this.verifiedAt,
    this.verificationNotes,
    this.rejectionReason,
    this.isSuspended = false,
    this.suspensionReason,
    this.adminNotes = '',
    required this.settings,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      zipCode: json['zipCode'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      website: json['website'] as String,
      merchantIds: List<String>.from(json['merchantIds']),
      ownerId: json['ownerId'] as String,
      storeLogoUrl: json['storeLogoUrl'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int,
      businessHours: json['businessHours'] as Map<String, dynamic>,
      categories: List<String>.from(json['categories']),
      taxId: json['taxId'] as String,
      businessId: json['businessId'] as String,
      storeType: json['storeType'] as String,
      commissionRate: (json['commissionRate'] as num).toDouble(),
      currency: json['currency'] as String,
      minimumOrderAmount: (json['minimumOrderAmount'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      deliveryTimeInMinutes: json['deliveryTimeInMinutes'] as int,
      paymentMethods: List<String>.from(json['paymentMethods']),
      isVerified: json['isVerified'] as bool,
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt'] as String) : null,
      verificationNotes: json['verificationNotes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      isSuspended: json['isSuspended'] as bool? ?? false,
      suspensionReason: json['suspensionReason'] as String?,
      adminNotes: json['adminNotes'] as String? ?? '',
      settings: json['settings'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zipCode': zipCode,
      'phone': phone,
      'email': email,
      'website': website,
      'merchantIds': merchantIds,
      'ownerId': ownerId,
      'storeLogoUrl': storeLogoUrl,
      'coverImageUrl': coverImageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'rating': rating,
      'totalReviews': totalReviews,
      'businessHours': businessHours,
      'categories': categories,
      'taxId': taxId,
      'businessId': businessId,
      'storeType': storeType,
      'commissionRate': commissionRate,
      'currency': currency,
      'minimumOrderAmount': minimumOrderAmount,
      'deliveryFee': deliveryFee,
      'deliveryTimeInMinutes': deliveryTimeInMinutes,
      'paymentMethods': paymentMethods,
      'isVerified': isVerified,
      if (verifiedAt != null) 'verifiedAt': verifiedAt!.toIso8601String(),
      if (verificationNotes != null) 'verificationNotes': verificationNotes,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      'isSuspended': isSuspended,
      if (suspensionReason != null) 'suspensionReason': suspensionReason,
      'adminNotes': adminNotes,
      'settings': settings,
    };
  }
}
```

## Store Creation Request Model
```dart
class CreateStoreRequest {
  final String name;
  final String description;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final String phone;
  final String email;
  final String? website;
  final String storeLogoUrl;
  final String coverImageUrl;
  final List<String> categories;
  final String storeType;
  final String currency;
  final double minimumOrderAmount;
  final double deliveryFee;
  final int deliveryTimeInMinutes;
  final List<String> paymentMethods;
  final Map<String, dynamic> businessHours;
  final Map<String, dynamic> settings;

  CreateStoreRequest({
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.phone,
    required this.email,
    this.website,
    required this.storeLogoUrl,
    required this.coverImageUrl,
    required this.categories,
    required this.storeType,
    required this.currency,
    required this.minimumOrderAmount,
    required this.deliveryFee,
    required this.deliveryTimeInMinutes,
    required this.paymentMethods,
    required this.businessHours,
    required this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zipCode': zipCode,
      'phone': phone,
      'email': email,
      'website': website,
      'storeLogoUrl': storeLogoUrl,
      'coverImageUrl': coverImageUrl,
      'categories': categories,
      'storeType': storeType,
      'currency': currency,
      'minimumOrderAmount': minimumOrderAmount,
      'deliveryFee': deliveryFee,
      'deliveryTimeInMinutes': deliveryTimeInMinutes,
      'paymentMethods': paymentMethods,
      'businessHours': businessHours,
      'settings': settings,
    };
  }
}
```

## API Service Implementation
```dart
class StoresApiService {
  final Dio _dio;
  final String _baseUrl;

  StoresApiService(this._dio, this._baseUrl);

  // Create a new store (Admin only)
  Future<ApiResponse<Store>> createStore(CreateStoreRequest request) async {
    try {
      final response = await _dio.post(
        '${_baseUrl}${ApiEndpoints.stores}',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
        ),
      );
      return ApiResponse.success(Store.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Unknown error');
    }
  }

  // Get store orders by store ID
  Future<ApiResponse<List<Order>>> getStoreOrders(String storeId) async {
    try {
      final response = await _dio.get(
        '${_baseUrl}${ApiEndpoints.storeOrders}',
        queryParameters: {'storeId': storeId},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
        ),
      );
      
      final orders = (response.data as List)
          .map((json) => Order.fromJson(json))
          .toList();
      return ApiResponse.success(orders);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Unknown error');
    }
  }

  Future<String> _getAuthToken() async {
    // Implementation to retrieve auth token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }
}
```

## API Endpoints Extension
Add to `lib/utils/api_endpoints.dart`:
```dart
// Store-related endpoints
static const String stores = '/api/stores';
static const String storeOrders = '/api/storeOrders';
```

## Expected Outcome
- Enhanced Store model with comprehensive fields for multistore functionality
- API service to interact with store endpoints
- Create store request model for structured data transmission
- Proper error handling and authentication management

## Visual Presentation
The enhanced Store model will serve as the foundation for:
1. Admin panel to manage multiple stores
2. Merchant dashboards to manage their stores
3. Store-specific pages in the customer app
4. Store filtering and browsing functionality

## Related Notes
- The current Store model is basic and needs significant enhancement to match the API requirements
- Store creation is Admin-only, but merchants can be assigned to stores through the merchantIds field
- The ownership model includes both an ownerId and merchantIds to distinguish between primary owner and other merchants with access

## Files to Read Before Implementing
- `lib/models/store/store_model.dart` - Current basic store model
- `lib/utils/api_endpoints.dart` - Current API endpoint configuration
- `lib/services/` directory - To understand the existing service patterns
- `lib/models/order/order_model.dart` - To understand how orders are structured for the storeOrders endpoint
- Authentication service files to understand token management

## Architecture
- The implementation will follow the existing architecture patterns in the codebase
- Repository pattern will be used to abstract data access
- BLoC pattern will be used for state management
- Service layer will handle API communication
- Model layer will handle data serialization/deserialization