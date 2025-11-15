import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:trizy_app/models/order/check_order_status_response.dart';
import 'package:trizy_app/models/order/get_user_orders_response.dart';
import 'package:trizy_app/models/order/order_details_response.dart';
import '../models/order/store_order.dart';
import '../utils/api_endpoints.dart';
import '../utils/networking_manager.dart';

class OrdersApiService{
  final NetworkingManager _networkingManager = GetIt.instance<NetworkingManager>();
  final Logger _logger = Logger();

  Future<CheckOrderStatusResponse> checkOrderStatus({required String paymentIntentId}) async {
    try {
      final response = await _networkingManager.get(
        endpoint: ApiEndpoints.checkOrderStatus,
        queryParams: {"paymentIntentId":paymentIntentId},
        addAuthToken: true
      );
      return CheckOrderStatusResponse.fromJson(response);
    }
    catch (e) {
      _logger.e("Error checking order status: $e");
      throw Exception('Failed to check order status: $e');
    }
  }

  Future<GetUserOrdersResponse> getUserOrders({required int page}) async {
    try {
      final response = await _networkingManager.get(
          endpoint: ApiEndpoints.getUserOrders,
          queryParams: {"page":page.toString()},
          addAuthToken: true
      );
      return GetUserOrdersResponse.fromJson(response);
    }
    catch (e) {
      _logger.e("Error getting user orders: $e");
      throw Exception('Failed to get user orders: $e');
    }
  }

  Future<OrderDetailsResponse> getOrderDetails({required String orderId}) async {
    try {
      final response = await _networkingManager.get(
          endpoint: ApiEndpoints.getOrderDetails,
          urlParams: {"orderId":orderId},
          addAuthToken: true
      );
      return OrderDetailsResponse.fromJson(response);
    }
    catch (e) {
      _logger.e("Error getting order details: $e");
      throw Exception('Failed to get order details: $e');
    }
  }

  Future<OrderDetailsResponse> getLatestOrderDetails() async {
    try {
      final response = await _networkingManager.get(
          endpoint: ApiEndpoints.getLatestOrderDetails,
          addAuthToken: true
      );
      return OrderDetailsResponse.fromJson(response);
    }
    catch (e) {
      _logger.e("Error getting latest order details: $e");
      throw Exception('Failed to get latest order details: $e');
    }
  }

  // New Store Order APIs based on API documentation
  Future<StoreOrder> createOrder({
    required String storeId,
    required String productId,
    required int quantity,
    required double price,
    required String addressId,
  }) async {
    try {
      final body = {
        'storeId': storeId,
        'productId': productId,
        'quantity': quantity,
        'price': price,
        'addressId': addressId,
      };
      final response = await _networkingManager.post(
        endpoint: 'api/orders', // Based on API doc: POST /api/orders
        body: body,
        addAuthToken: true,
      );
      // The API returns both order and storeOrder, so we need to handle that
      if (response.containsKey('storeOrder')) {
        return StoreOrder.fromJson(response['storeOrder']);
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<StoreOrder> approveStoreOrder({
    required String storeOrderId,
  }) async {
    try {
      final response = await _networkingManager.put(
        endpoint: 'api/storeOrders/$storeOrderId/confirm', // Based on API doc: PUT /api/storeOrders/{storeOrderId}/confirm
        body: {}, // Empty body for confirmation
        addAuthToken: true,
      );
      return StoreOrder.fromJson(response);
    } catch (e) {
      throw Exception('Failed to approve store order: $e');
    }
  }

  Future<StoreOrder> updateOrderStatus({
    required String storeOrderId,
    required String state,
  }) async {
    try {
      final body = {'state': state};
      final response = await _networkingManager.put(
        endpoint: 'api/storeOrders/$storeOrderId', // Based on API doc: PUT /api/storeOrders/{storeOrderId}
        body: body,
        addAuthToken: true,
      );
      return StoreOrder.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<List<StoreOrder>> getStoreOrders({String? storeId}) async {
    try {
      String endpoint = 'api/storeOrders'; // Based on API doc: GET /api/storeOrders?storeId=
      if (storeId != null) {
        endpoint += '?storeId=$storeId';
      }
      final response = await _networkingManager.get(
        endpoint: endpoint,
        addAuthToken: true,
      );
      if (response is List) {
        return response.values.map((item) => StoreOrder.fromJson(item)).toList();
      } else if (response is Map<String, dynamic>) {
        // Handle case where response is a Map that might contain a list of orders
        // This could happen if the API returns a paginated response with orders in a specific field
        if (response.containsKey('data') && response['data'] is List) {
          return (response['data'] as List).map((item) => StoreOrder.fromJson(item)).toList();
        } else if (response.containsKey('orders') && response['orders'] is List) {
          return (response['orders'] as List).map((item) => StoreOrder.fromJson(item)).toList();
        } else {
          throw Exception('Unexpected response format: missing orders list in Map');
        }
      } else {
        throw Exception('Unexpected response format: neither List nor Map');
      }
    } catch (e) {
      throw Exception('Failed to get store orders: $e');
    }
  }
}