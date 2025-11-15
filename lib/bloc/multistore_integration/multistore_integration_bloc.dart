import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'multistore_integration_event.dart';
import 'multistore_integration_state.dart';
import '../../repositories/auth_repository.dart';

/// BLoC for managing global multistore integration state, including authentication and user role.
class MultistoreIntegrationBloc extends Bloc<MultistoreIntegrationEvent, MultistoreState> {
  final AuthRepository _authRepository = GetIt.instance<AuthRepository>();

  MultistoreIntegrationBloc() : super(const MultistoreState()) {
    on<InitializeMultistore>(_onInitializeMultistore);
    on<SetCurrentStore>(_onSetCurrentStore);
    on<ClearCurrentStore>(_onClearCurrentStore);
    on<RefreshAuthStatus>(_onRefreshAuthStatus);
  }

  /// Handles the [InitializeMultistore] event to set up initial state.
  Future<void> _onInitializeMultistore(InitializeMultistore event, Emitter<MultistoreState> emit) async {
    await _authRepository.init(); // Ensure AuthRepository is initialized
    emit(state.copyWith(
      isAuthenticated: _authRepository.isAuthenticated(),
      currentUser: _authRepository.currentUser,
      currentStoreId: _authRepository.currentStoreId,
    ));
  }

  /// Handles the [SetCurrentStore] event to update the current store ID.
  Future<void> _onSetCurrentStore(SetCurrentStore event, Emitter<MultistoreState> emit) async {
    if (_authRepository.isAdmin()) { // Only admins can manage a store context
      await _authRepository.setCurrentStoreId(event.storeId);
      emit(state.copyWith(currentStoreId: event.storeId));
    }
  }

  /// Handles the [ClearCurrentStore] event to remove the current store ID.
  Future<void> _onClearCurrentStore(ClearCurrentStore event, Emitter<MultistoreState> emit) async {
    await _authRepository.clearCurrentStoreId();
    emit(state.copyWith(currentStoreId: null));
  }

  /// Handles the [RefreshAuthStatus] event to update authentication and user details.
  Future<void> _onRefreshAuthStatus(RefreshAuthStatus event, Emitter<MultistoreState> emit) async {
    emit(state.copyWith(
      isAuthenticated: _authRepository.isAuthenticated(),
      currentUser: _authRepository.currentUser,
      currentStoreId: _authRepository.currentStoreId,
    ));
  }
}