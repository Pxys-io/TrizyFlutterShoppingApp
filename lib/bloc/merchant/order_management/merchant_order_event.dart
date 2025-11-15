import 'package:equatable/equatable.dart';

/// Base class for all events related to merchant order management.
abstract class MerchantOrderEvent extends Equatable {
  const MerchantOrderEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load orders for a specific store managed by a merchant.
class LoadMerchantOrders extends MerchantOrderEvent {
  final String storeId;
  const LoadMerchantOrders(this.storeId);
  @override
  List<Object?> get props => [storeId];
}

/// Event to update the status of a specific order.
class UpdateMerchantOrderStatus extends MerchantOrderEvent {
  final String storeOrderId; // API uses 'orderId' for store order ID
  final String status;
  final String storeId; // Needed to reload orders for the specific store
  const UpdateMerchantOrderStatus({required this.storeOrderId, required this.status, required this.storeId});
  @override
  List<Object?> get props => [storeOrderId, status, storeId];
}