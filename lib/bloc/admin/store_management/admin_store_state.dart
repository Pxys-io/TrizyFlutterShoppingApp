import 'package:equatable/equatable.dart';
import '../../../models/store/store_model.dart';

/// Represents the status of admin store management operations.
enum AdminStoreStatus { initial, loading, success, failure }

/// State for admin store management.
class AdminStoreState extends Equatable {
  final AdminStoreStatus status;
  final List<Store> stores;
  final String? errorMessage;

  const AdminStoreState({
    this.status = AdminStoreStatus.initial,
    this.stores = const [],
    this.errorMessage,
  });

  /// Creates a copy of this [AdminStoreState] with updated values.
  AdminStoreState copyWith({
    AdminStoreStatus? status,
    List<Store>? stores,
    String? errorMessage,
  }) {
    return AdminStoreState(
      status: status ?? this.status,
      stores: stores ?? this.stores,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stores, errorMessage];
}