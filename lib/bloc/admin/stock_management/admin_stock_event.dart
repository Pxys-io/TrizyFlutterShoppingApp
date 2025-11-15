import 'package:equatable/equatable.dart';
import '../../../models/stock/stock_model.dart';

/// Base class for all events related to admin stock management.
abstract class AdminStockEvent extends Equatable {
  const AdminStockEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load stock entries for admin management.
class LoadAdminStocks extends AdminStockEvent {
  final String? storeId; // Optional filter
  final String? productId; // Optional filter
  const LoadAdminStocks({this.storeId, this.productId});
  @override
  List<Object?> get props => [storeId, productId];
}

/// Event to add a new stock entry.
class AddAdminStock extends AdminStockEvent {
  final String storeId;
  final String productId;
  final int totalQuantity;
  final List<PricingTier> pricing;

  const AddAdminStock({
    required this.storeId,
    required this.productId,
    required this.totalQuantity,
    required this.pricing,
  });

  @override
  List<Object?> get props => [storeId, productId, totalQuantity, pricing];
}

/// Event to update an existing stock entry.
class UpdateAdminStock extends AdminStockEvent {
  final String id;
  final String? storeId;
  final String? productId;
  final int? totalQuantity;
  final List<PricingTier>? pricing;

  const UpdateAdminStock({
    required this.id,
    this.storeId,
    this.productId,
    this.totalQuantity,
    this.pricing,
  });

  @override
  List<Object?> get props => [id, storeId, productId, totalQuantity, pricing ?? []];
}

/// Event to delete a stock entry.
class DeleteAdminStock extends AdminStockEvent {
  final String id;
  const DeleteAdminStock(this.id);
  @override
  List<Object?> get props => [id];
}