import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'admin_stock_event.dart';
import 'admin_stock_state.dart';
import '../../../repositories/stock_repository.dart';
import '../../../models/stock/stock_model.dart';

/// BLoC for managing admin stock operations.
class AdminStockBloc extends Bloc<AdminStockEvent, AdminStockState> {
  final StockRepository _stockRepository = GetIt.instance<StockRepository>();

  AdminStockBloc() : super(const AdminStockState()) {
    on<LoadAdminStocks>(_onLoadAdminStocks);
    on<AddAdminStock>(_onAddAdminStock);
    on<UpdateAdminStock>(_onUpdateAdminStock);
    on<DeleteAdminStock>(_onDeleteAdminStock);
  }

  /// Handles loading stock entries, optionally filtered by store ID or product ID.
  Future<void> _onLoadAdminStocks(LoadAdminStocks event, Emitter<AdminStockState> emit) async {
    // For now, we'll just emit an empty state since we don't have an API endpoint to list stocks
    // In a real implementation, you'd have an API endpoint like GET /api/stock?storeId=&productId=
    emit(const AdminStockState(status: AdminStockStatus.success, stocks: []));
  }

  /// Handles adding a new stock entry.
  Future<void> _onAddAdminStock(AddAdminStock event, Emitter<AdminStockState> emit) async {
    emit(state.copyWith(status: AdminStockStatus.loading));
    try {
      final newStock = await _stockRepository.createStock(
        storeId: event.storeId,
        productId: event.productId,
        totalQuantity: event.totalQuantity,
        pricing: event.pricing,
      );
      final updatedStocks = List<Stock>.from(state.stocks)..add(newStock);
      emit(state.copyWith(status: AdminStockStatus.success, stocks: updatedStocks));
    } catch (e) {
      emit(state.copyWith(status: AdminStockStatus.failure, errorMessage: e.toString()));
    }
  }

  /// Handles updating an existing stock entry.
  Future<void> _onUpdateAdminStock(UpdateAdminStock event, Emitter<AdminStockState> emit) async {
    // For now, we'll show that this is not implemented since the API doesn't have this endpoint
    emit(state.copyWith(status: AdminStockStatus.failure, errorMessage: "Update stock endpoint not available in API"));
  }

  /// Handles deleting a stock entry.
  Future<void> _onDeleteAdminStock(DeleteAdminStock event, Emitter<AdminStockState> emit) async {
    // For now, we'll show that this is not implemented since the API doesn't have this endpoint
    emit(state.copyWith(status: AdminStockStatus.failure, errorMessage: "Delete stock endpoint not available in API"));
  }
}