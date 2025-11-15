# Corrected Phase 1.1: Store Model and API Service Implementation (Based on API Documentation)

## Feature Overview
Implement a Store model and API service that matches the exact specifications from the backend API documentation. This phase will create models that directly correspond to the API's request/response structures for store creation and management.

## Related API Endpoint
- **POST** `/api/stores` - Create a new store (Admin only, requires admin access)

## API Request Structure
```json
{
  "name": "My Awesome Store",
  "address": "123 Main St",
  "city": "Anytown",
  "state": "CA",
  "country": "USA",
  "postalCode": "90210",
  "merchantIds": []
}
```

## API Response Structure
```json
{
  "_id": "6553d3e3c7e3f3e3c7e3f3e4",
  "name": "My Awesome Store",
  "address": "123 Main St",
  "city": "Anytown",
  "state": "CA",
  "country": "USA",
  "postalCode": "90210",
  "merchantIds": [],
  "createdAt": "2023-11-14T12:00:00.000Z",
  "updatedAt": "2023-11-14T12:00:00.000Z"
}
```

## Files to Create
- `lib/models/store/store_model.dart` - Store model matching API structure
- `lib/models/store/create_store_request.dart` - Create store request model
- `lib/services/stores_api_service.dart` - Store API service
- `lib/repositories/stores_repository.dart` - Store repository
- `lib/utils/api_endpoints.dart` - Update with store endpoints

## Store Model Implementation
```dart
class Store {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final List<String> merchantIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.merchantIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      postalCode: json['postalCode'] as String,
      merchantIds: List<String>.from(json['merchantIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'merchantIds': merchantIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

## Create Store Request Model
```dart
class CreateStoreRequest {
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final List<String> merchantIds;

  CreateStoreRequest({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.merchantIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'merchantIds': merchantIds,
    };
  }
}
```

## Store API Service Implementation
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

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }
}
```

## API Endpoints Update
```dart
// Store-related endpoints
static const String stores = '/api/stores';
static const String storeOrders = '/api/storeOrders';
```

## Expected Outcome
- Store model that matches the exact API response structure
- Create store request model that matches the API request structure
- API service to interact with the store endpoint
- Proper error handling and authentication management

## Visual Presentation
The Store model will serve as the foundation for:
1. Admin panel to create and manage stores
2. Store management functionality
3. Proper data serialization/deserialization matching the backend API

## Related Notes
- The API uses `_id` for the store identifier, not `id`
- Field names in the API match exactly what's documented
- The `postalCode` field is used instead of `zipCode`
- The `merchantIds` field is an array of strings

## Files to Read Before Implementing
- `lib/utils/api_endpoints.dart` - Current API endpoint configuration
- `lib/services/` directory - To understand existing service patterns
- Authentication service files to understand token management

## Architecture
- Will follow the existing repository pattern for data abstraction
- BLoC pattern will handle state management
- Service layer will handle API communication
- Model layer will handle data serialization/deserialization matching API structure