import 'package:equatable/equatable.dart';
import '../../../models/order/store_order.dart';

/// Represents the status of merchant order management operations.
enum MerchantOrderStatus { initial, loading, success, failure }

/// State for merchant order management.
class MerchantOrderState extends Equatable {
  final MerchantOrderStatus status;
  final List<StoreOrder> orders;
  final String? errorMessage;

  const MerchantOrderState({
    this.status = MerchantOrderStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });

  /// Creates a copy of this [MerchantOrderState] with updated values.
  MerchantOrderState copyWith({
    MerchantOrderStatus? status,
    List<StoreOrder>? orders,
    String? errorMessage,
  }) {
    return MerchantOrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage];
}