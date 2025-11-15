import 'package:equatable/equatable.dart';
import '../../../models/user/user_model.dart';

/// Represents the status of admin user management operations.
enum AdminUserStatus { initial, loading, success, failure }

/// State for admin user management.
class AdminUserState extends Equatable {
  final AdminUserStatus status;
  final List<User> users;
  final String? errorMessage;

  const AdminUserState({
    this.status = AdminUserStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  /// Creates a copy of this [AdminUserState] with updated values.
  AdminUserState copyWith({
    AdminUserStatus? status,
    List<User>? users,
    String? errorMessage,
  }) {
    return AdminUserState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}