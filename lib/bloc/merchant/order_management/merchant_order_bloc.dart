import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'merchant_order_event.dart';
import 'merchant_order_state.dart';
import '../../../repositories/orders_repository.dart';
import '../../../models/order/store_order.dart';

/// BLoC for managing merchant order operations for a specific store.
class MerchantOrderBloc extends Bloc<MerchantOrderEvent, MerchantOrderState> {
  final OrdersRepository _ordersRepository = GetIt.instance<OrdersRepository>();

  MerchantOrderBloc() : super(const MerchantOrderState()) {
    on<LoadMerchantOrders>(_onLoadMerchantOrders);
    on<UpdateMerchantOrderStatus>(_onUpdateMerchantOrderStatus);
  }

  /// Handles loading orders for a specific store.
  Future<void> _onLoadMerchantOrders(LoadMerchantOrders event, Emitter<MerchantOrderState> emit) async {
    emit(state.copyWith(status: MerchantOrderStatus.loading));
    try {
      final orders = await _ordersRepository.getStoreOrders(storeId: event.storeId);
      emit(state.copyWith(status: MerchantOrderStatus.success, orders: orders));
    } catch (e) {
      emit(state.copyWith(status: MerchantOrderStatus.failure, errorMessage: e.toString()));
    }
  }

  /// Handles updating the status of a specific order.
  Future<void> _onUpdateMerchantOrderStatus(UpdateMerchantOrderStatus event, Emitter<MerchantOrderState> emit) async {
    emit(state.copyWith(status: MerchantOrderStatus.loading));
    try {
      final updatedOrder = await _ordersRepository.updateOrderStatus(
        storeOrderId: event.storeOrderId,
        state: event.status,
      );
      // Reload orders for the specific store after update to reflect changes
      final orders = await _ordersRepository.getStoreOrders(storeId: event.storeId);
      emit(state.copyWith(status: MerchantOrderStatus.success, orders: orders));
    } catch (e) {
      emit(state.copyWith(status: MerchantOrderStatus.failure, errorMessage: e.toString()));
    }
  }
}