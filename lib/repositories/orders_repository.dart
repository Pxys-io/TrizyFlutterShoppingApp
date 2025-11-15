import 'package:trizy_app/models/order/check_order_status_response.dart';
import 'package:trizy_app/models/order/get_user_orders_response.dart';
import 'package:trizy_app/models/order/order_details_response.dart';
import 'package:trizy_app/services/orders_api_service.dart';

import '../di/locator.dart';
import '../models/order/store_order.dart';
import '../services/local/local_product_service.dart';

class OrdersRepository {
  final OrdersApiService ordersApiService;
  final LocalProductService localProductService = getIt<LocalProductService>();
  OrdersRepository(this.ordersApiService);

  Future<CheckOrderStatusResponse> checkOrderStatus({required String paymentIntentId}) async {
    try {
      final CheckOrderStatusResponse response = await ordersApiService.checkOrderStatus(paymentIntentId: paymentIntentId);
      if(response.order != null){
        // order created, clear local cart
        localProductService.clearCart();
      }
      return response;
    } catch (e) {
      throw Exception('Failed to check order status: $e');
    }
  }


  Future<GetUserOrdersResponse> getUserOrders({required int page}) async {
    try {
      final GetUserOrdersResponse response = await ordersApiService.getUserOrders(page: page);
      return response;
    } catch (e) {
      throw Exception('Failed to get user ordersw: $e');
    }
  }


  Future<OrderDetailsResponse> getOrderDetails({required String orderId}) async {
    try {
      final OrderDetailsResponse response = await ordersApiService.getOrderDetails(orderId: orderId);
      return response;
    } catch (e) {
      throw Exception('Failed to get order details: $e');
    }
  }


  Future<OrderDetailsResponse> getLatestOrderDetails() async {
    try {
      final OrderDetailsResponse response = await ordersApiService.getLatestOrderDetails();
      return response;
    } catch (e) {
      throw Exception('Failed to get order details: $e');
    }
  }

  // Store Order Methods
  Future<StoreOrder> createOrder({
    required String storeId,
    required String productId,
    required int quantity,
    required double price,
    required String addressId,
  }) async {
    try {
      return await ordersApiService.createOrder(
        storeId: storeId,
        productId: productId,
        quantity: quantity,
        price: price,
        addressId: addressId,
      );
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<StoreOrder> approveStoreOrder({
    required String storeOrderId,
  }) async {
    try {
      return await ordersApiService.approveStoreOrder(
        storeOrderId: storeOrderId,
      );
    } catch (e) {
      throw Exception('Failed to approve store order: $e');
    }
  }

  Future<StoreOrder> updateOrderStatus({
    required String storeOrderId,
    required String state,
  }) async {
    try {
      return await ordersApiService.updateOrderStatus(
        storeOrderId: storeOrderId,
        state: state,
      );
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<List<StoreOrder>> getStoreOrders({String? storeId}) async {
    try {
      return await ordersApiService.getStoreOrders(storeId: storeId);
    } catch (e) {
      throw Exception('Failed to get store orders: $e');
    }
  }

}