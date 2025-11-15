import 'package:equatable/equatable.dart';

/// Base class for all events related to multistore integration state.
abstract class MultistoreIntegrationEvent extends Equatable {
  const MultistoreIntegrationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the multistore integration state, typically on app startup.
class InitializeMultistore extends MultistoreIntegrationEvent {}

/// Event to set or switch the current store ID for an admin user acting as a merchant.
class SetCurrentStore extends MultistoreIntegrationEvent {
  final String storeId;
  const SetCurrentStore(this.storeId);
  @override
  List<Object?> get props => [storeId];
}

/// Event to clear the current store ID.
class ClearCurrentStore extends MultistoreIntegrationEvent {}

/// Event to refresh the current user's authentication status and role.
class RefreshAuthStatus extends MultistoreIntegrationEvent {}