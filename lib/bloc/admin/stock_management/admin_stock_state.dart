import 'package:equatable/equatable.dart';
import '../../../models/stock/stock_model.dart';

/// Represents the status of admin stock management operations.
enum AdminStockStatus { initial, loading, success, failure }

/// State for admin stock management.
class AdminStockState extends Equatable {
  final AdminStockStatus status;
  final List<Stock> stocks;
  final String? errorMessage;

  const AdminStockState({
    this.status = AdminStockStatus.initial,
    this.stocks = const [],
    this.errorMessage,
  });

  /// Creates a copy of this [AdminStockState] with updated values.
  AdminStockState copyWith({
    AdminStockStatus? status,
    List<Stock>? stocks,
    String? errorMessage,
  }) {
    return AdminStockState(
      status: status ?? this.status,
      stocks: stocks ?? this.stocks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stocks, errorMessage];
}