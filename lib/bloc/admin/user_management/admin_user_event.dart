import 'package:equatable/equatable.dart';
import '../../../models/user/user_model.dart';

/// Base class for all events related to admin user management.
abstract class AdminUserEvent extends Equatable {
  const AdminUserEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all users for admin management.
class LoadAdminUsers extends AdminUserEvent {}

/// Event to add a new user.
class AddAdminUser extends AdminUserEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final bool isAdmin;
  const AddAdminUser({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.isAdmin = false,
  });
  @override
  List<Object?> get props => [email, password, firstName, lastName, isAdmin];
}

/// Event to update an existing user.
class UpdateAdminUser extends AdminUserEvent {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final bool? isAdmin;
  const UpdateAdminUser({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.isAdmin,
  });
  @override
  List<Object?> get props => [id, email, firstName, lastName, isAdmin];
}

/// Event to delete a user.
class DeleteAdminUser extends AdminUserEvent {
  final String id;
  const DeleteAdminUser(this.id);
  @override
  List<Object?> get props => [id];
}