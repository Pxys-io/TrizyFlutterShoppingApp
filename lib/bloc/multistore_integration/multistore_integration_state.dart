import 'package:equatable/equatable.dart';
import '../../models/user/user_model.dart'; // Import User model

/// Represents the global state for multistore integration and user context.
class MultistoreState extends Equatable {
  final bool isAuthenticated;
  final User? currentUser;
  final String? currentStoreId; // The store ID currently being managed by an admin-merchant

  const MultistoreState({
    this.isAuthenticated = false,
    this.currentUser,
    this.currentStoreId,
  });

  /// Returns true if the current user has the admin role.
  bool get isAdmin => currentUser?.isAdmin == true;

  /// Returns true if a [currentStoreId] is set, indicating an admin is managing a specific store.
  bool get isManagingStore => currentStoreId != null;

  /// Creates a copy of this [MultistoreState] with updated values.
  MultistoreState copyWith({
    bool? isAuthenticated,
    User? currentUser,
    String? currentStoreId,
  }) {
    return MultistoreState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      currentStoreId: currentStoreId, // Allow null to clear
    );
  }

  @override
  List<Object?> get props => [isAuthenticated, currentUser, currentStoreId];
}