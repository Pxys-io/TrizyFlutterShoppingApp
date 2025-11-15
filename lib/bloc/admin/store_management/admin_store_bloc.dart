import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'admin_store_event.dart';
import 'admin_store_state.dart';
import '../../../repositories/stores_repository.dart';
import '../../../models/store/store_model.dart';

/// BLoC for managing admin store operations.
class AdminStoreBloc extends Bloc<AdminStoreEvent, AdminStoreState> {
  final StoresRepository _storesRepository = GetIt.instance<StoresRepository>();

  AdminStoreBloc() : super(const AdminStoreState()) {
    on<LoadAdminStores>(_onLoadAdminStores);
    on<AddAdminStore>(_onAddAdminStore);
    on<UpdateAdminStore>(_onUpdateAdminStore);
    on<DeleteAdminStore>(_onDeleteAdminStore);
  }

  /// Handles loading all stores.
  Future<void> _onLoadAdminStores(LoadAdminStores event, Emitter<AdminStoreState> emit) async {
    // For now, we'll just emit an empty state since we don't have an API endpoint to list all stores
    // In a real implementation, you'd have an API endpoint like GET /api/stores
    emit(const AdminStoreState(status: AdminStoreStatus.success, stores: []));
  }

  /// Handles adding a new store.
  Future<void> _onAddAdminStore(AddAdminStore event, Emitter<AdminStoreState> emit) async {
    emit(state.copyWith(status: AdminStoreStatus.loading));
    try {
      final newStore = await _storesRepository.createStore(
        name: event.name,
        address: event.address,
        city: event.city,
        state: event.state,
        country: event.country,
        postalCode: event.postalCode,
        merchantIds: event.merchantIds,
      );
      final updatedStores = List<Store>.from(state.stores)..add(newStore);
      emit(state.copyWith(status: AdminStoreStatus.success, stores: updatedStores));
    } catch (e) {
      emit(state.copyWith(status: AdminStoreStatus.failure, errorMessage: e.toString()));
    }
  }

  /// Handles updating an existing store.
  Future<void> _onUpdateAdminStore(UpdateAdminStore event, Emitter<AdminStoreState> emit) async {
    // For now, we'll show that this is not implemented since the API doesn't have this endpoint
    emit(state.copyWith(status: AdminStoreStatus.failure, errorMessage: "Update store endpoint not available in API"));
  }

  /// Handles deleting a store.
  Future<void> _onDeleteAdminStore(DeleteAdminStore event, Emitter<AdminStoreState> emit) async {
    // For now, we'll show that this is not implemented since the API doesn't have this endpoint
    emit(state.copyWith(status: AdminStoreStatus.failure, errorMessage: "Delete store endpoint not available in API"));
  }
}