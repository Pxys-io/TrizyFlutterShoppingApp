import 'package:equatable/equatable.dart';

/// Base class for all events related to admin store management.
abstract class AdminStoreEvent extends Equatable {
  const AdminStoreEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all stores for admin management.
class LoadAdminStores extends AdminStoreEvent {}

/// Event to add a new store.
class AddAdminStore extends AdminStoreEvent {
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final List<String>? merchantIds;

  const AddAdminStore({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.merchantIds,
  });

  @override
  List<Object?> get props => [name, address, city, state, country, postalCode, merchantIds ?? []];
}

/// Event to update an existing store.
class UpdateAdminStore extends AdminStoreEvent {
  final String id;
  final String? name;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final List<String>? merchantIds;

  const UpdateAdminStore({
    required this.id,
    this.name,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.merchantIds,
  });

  @override
  List<Object?> get props => [id, name, address, city, state, country, postalCode, merchantIds ?? []];
}

/// Event to delete a store.
class DeleteAdminStore extends AdminStoreEvent {
  final String id;
  const DeleteAdminStore(this.id);
  @override
  List<Object?> get props => [id];
}