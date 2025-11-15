# Corrected Phase 1.2: Store Orders Model and API Service Implementation (Based on API Documentation)

## Feature Overview
Implement Store Order models and API services that match the exact specifications from the backend API documentation. This phase will create models for store orders that directly correspond to the API's request/response structures for order management by merchants and admins.

## Related API Endpoints
- **GET** `/api/storeOrders?storeId=` - Get orders for a specific store (Merchant access)
- **PUT** `/api/storeOrders/:storeOrderId` - Update order status (Merchant access)
- **PUT** `/api/storeOrders/:storeOrderId/confirm` - Approve order (Admin only)

## API Response Structure for Get Store Orders
```json
{
  "storeOrders": [
    {
      "_id": "6553d3e3c7e3f3e3c7e3f3ec",
      "storeId": "6553d3e3c7e3f3e3c7e3f3e4",
      "orderId": "6553d3e3c7e3f3e3c7e3f3eb",
      "state": "prepared",
      "createdAt": "2023-11-14T12:00:00.000Z",
      "updatedAt": "2023-11-14T12:00:00.000Z"
    }
  ]
}
```

## API Request/Response Structure for Update Order Status
**Request:**
```json
{
  "state": "prepared"
}
```

**Response:**
```json
{
  "_id": "6553d3e3c7e3f3e3c7e3f3ec",
  "storeId": "6553d3e3c7e3f3e3c7e3f3e4",
  "orderId": "6553d3e3c7e3f3e3c7e3f3eb",
  "state": "prepared",
  "createdAt": "2023-11-14T12:00:00.000Z",
  "updatedAt": "2023-11-14T12:00:00.000Z"
}
```

## API Response Structure for Confirm Order
```json
{
  "_id": "6553d3e3c7e3f3e3c7e3f3ec",
  "storeId": "6553d3e3c7e3f3e3c7e3f3e4",
  "orderId": "6553d3e3c7e3f3e3c7e3f3eb",
  "state": "confirmed",
  "createdAt": "2023-11-14T12:00:00.000Z",
  "updatedAt": "2023-11-14T12:00:00.000Z"
}
```

## Files to Create
- `lib/models/store_order/store_order_model.dart` - Store order model matching API structure
- `lib/models/store_order/update_store_order_request.dart` - Update store order request model
- `lib/models/store_order/get_store_orders_response.dart` - Get store orders response model
- `lib/services/store_orders_api_service.dart` - Store orders API service
- `lib/repositories/store_orders_repository.dart` - Store orders repository

## Store Order Model Implementation
```dart
class StoreOrder {
  final String id;
  final String storeId;
  final String orderId;
  final String state;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoreOrder({
    required this.id,
    required this.storeId,
    required this.orderId,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreOrder.fromJson(Map<String, dynamic> json) {
    return StoreOrder(
      id: json['_id'] as String,
      storeId: json['storeId'] as String,
      orderId: json['orderId'] as String,
      state: json['state'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'storeId': storeId,
      'orderId': orderId,
      'state': state,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

## Update Store Order Request Model
```dart
class UpdateStoreOrderRequest {
  final String state;

  UpdateStoreOrderRequest({
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'state': state,
    };
  }
}
```

## Get Store Orders Response Model
```dart
class GetStoreOrdersResponse {
  final List<StoreOrder> storeOrders;

  GetStoreOrdersResponse({
    required this.storeOrders,
  });

  factory GetStoreOrdersResponse.fromJson(Map<String, dynamic> json) {
    final storeOrdersJson = json['storeOrders'] as List;
    final storeOrders = storeOrdersJson
        .map((item) => StoreOrder.fromJson(item as Map<String, dynamic>))
        .toList();
    
    return GetStoreOrdersResponse(
      storeOrders: storeOrders,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeOrders': storeOrders.map((order) => order.toJson()).toList(),
    };
  }
}
```

## Store Orders API Service Implementation
```dart
class StoreOrdersApiService {
  final Dio _dio;
  final String _baseUrl;

  StoreOrdersApiService(this._dio, this._baseUrl);

  // Get store orders by store ID
  Future<ApiResponse<List<StoreOrder>>> getStoreOrders(String storeId) async {
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
      
      final storeOrdersResponse = GetStoreOrdersResponse.fromJson(response.data);
      return ApiResponse.success(storeOrdersResponse.storeOrders);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Unknown error');
    }
  }

  // Update store order status (Merchant access)
  Future<ApiResponse<StoreOrder>> updateStoreOrderStatus(
    String storeOrderId,
    String newState,
  ) async {
    try {
      final request = UpdateStoreOrderRequest(state: newState);
      final response = await _dio.put(
        '${_baseUrl}${ApiEndpoints.storeOrders}/$storeOrderId',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
        ),
      );
      return ApiResponse.success(StoreOrder.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Unknown error');
    }
  }

  // Confirm store order (Admin only)
  Future<ApiResponse<StoreOrder>> confirmStoreOrder(String storeOrderId) async {
    try {
      final response = await _dio.put(
        '${_baseUrl}${ApiEndpoints.storeOrders}/$storeOrderId/confirm',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
        ),
      );
      return ApiResponse.success(StoreOrder.fromJson(response.data));
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

## Expected Outcome
- Store Order model that matches the exact API response structure
- Get Store Orders response model that matches the API response structure
- API services to interact with the store orders endpoints
- Proper error handling and authentication management
- Differentiation between merchant and admin operations

## Visual Presentation
The Store Order models will serve as the foundation for:
1. Merchant dashboard to manage their store orders
2. Admin panel to approve orders
3. Order status tracking and updates
4. Proper data serialization/deserialization matching the backend API

## Related Notes
- The API uses `_id` for the store order identifier, not `id`
- The `state` field represents the order status (e.g., 'prepared', 'confirmed')
- Get orders endpoint requires a `storeId` query parameter
- Update order endpoint requires the new `state` in the request body
- Confirm order endpoint has a special `/confirm` path and is admin-only

## Files to Read Before Implementing
- `lib/models/order/order_model.dart` - Current order model for reference on patterns
- `lib/services/` directory - To understand existing service patterns
- Authentication service files to understand token management
- Previous store model implementations for consistency

## Architecture
- Will follow the existing repository pattern for data abstraction
- BLoC pattern will handle state management
- Service layer will handle API communication
- Model layer will handle data serialization/deserialization matching API structure
- Clear separation between merchant and admin operations in the service layer