# Corrected Phase 2.1: Admin Dashboard - Order Confirmation Implementation (Based on API Documentation)

## Feature Overview
Implement the admin dashboard functionality specifically for order confirmation using the exact API structures from the documentation. This phase will create the UI and business logic for administrators to approve orders as specified in the backend API documentation.

## Related API Endpoint
- **PUT** `/api/storeOrders/:storeOrderId/confirm` - Approve order (Admin only)

## API Structure (from documentation)
### Confirm Order Response
```json
{
  "_id": "6553d3e3c7e3f3e3c7e3f3ec",
  "storeId": "6553d3e3c7e3f3e3c7e3f3e4",
  "orderId": "6553d3e3c7e3f3e3c7e3f3eb",
  "state": "confirmed",
  "createdAt": "2023-11-14T12:00:00.000Z",
  "updatedAt": "2023-11-14T12:00:00.000Z"
}
```

## Note on API Documentation
The API documentation at https://store-backend-eta.vercel.app/docs shows limited admin-specific endpoints beyond the order confirmation endpoint. The `/api/stores` endpoint is documented as requiring admin access but is for store creation. There's no detailed documentation for comprehensive admin features like user management, other store management functions, etc.

## Current Dart Files
- `lib/views/` - Existing UI pages
- `lib/bloc/` - Existing BLoC files
- `lib/components/` - Existing UI components
- `lib/models/order/order_model.dart` - Current order model
- `lib/models/store_order/store_order_model.dart` - The StoreOrder model based on API documentation

## Files to Create
- `lib/views/admin/admin_dashboard_view.dart` - Admin dashboard UI focused on order confirmation
- `lib/bloc/admin/admin_dashboard_bloc.dart` - Admin dashboard BLoC
- `lib/bloc/admin/admin_dashboard_event.dart` - Admin dashboard events
- `lib/bloc/admin/admin_dashboard_state.dart` - Admin dashboard states
- `lib/views/admin/admin_order_confirmation_view.dart` - Admin order confirmation UI
- `lib/bloc/admin/admin_orders_bloc.dart` - Admin orders BLoC
- `lib/components/admin/order_confirmation_card.dart` - Order confirmation component
- `lib/models/admin/admin_orders_filter_model.dart` - Admin order filtering model

## Admin Orders Filter Model
```dart
class AdminOrdersFilter {
  final String? storeId;  // Filter by specific store
  final String? state;    // Filter by order state (e.g., 'pending', 'prepared', 'confirmed')
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? orderId;
  final int? page;
  final int? limit;

  AdminOrdersFilter({
    this.storeId,
    this.state,
    this.dateFrom,
    this.dateTo,
    this.orderId,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (storeId != null) 'storeId': storeId,
      if (state != null) 'state': state,
      if (dateFrom != null) 'dateFrom': dateFrom!.toIso8601String(),
      if (dateTo != null) 'dateTo': dateTo!.toIso8601String(),
      if (orderId != null) 'orderId': orderId,
      'page': page,
      'limit': limit,
    }..removeWhere((key, value) => value == null);
  }
}
```

## Admin Orders BLoC Implementation

### Events
```dart
abstract class AdminOrdersEvent {}

class LoadAdminOrders extends AdminOrdersEvent {
  final AdminOrdersFilter? filter;

  LoadAdminOrders({this.filter});
}

class ConfirmStoreOrder extends AdminOrdersEvent {
  final String storeOrderId;

  ConfirmStoreOrder(this.storeOrderId);
}

class FilterAdminOrders extends AdminOrdersEvent {
  final AdminOrdersFilter filter;

  FilterAdminOrders(this.filter);
}
```

### States
```dart
abstract class AdminOrdersState {}

class AdminOrdersInitial extends AdminOrdersState {}

class AdminOrdersLoading extends AdminOrdersState {}

class AdminOrdersLoaded extends AdminOrdersState {
  final List<StoreOrder> orders;
  final AdminOrdersFilter? currentFilter;

  AdminOrdersLoaded(this.orders, {this.currentFilter});
}

class AdminOrderConfirmed extends AdminOrdersState {
  final StoreOrder confirmedOrder;

  AdminOrderConfirmed(this.confirmedOrder);
}

class AdminOrdersError extends AdminOrdersState {
  final String message;

  AdminOrdersError(this.message);
}
```

### BLoC Implementation
```dart
class AdminOrdersBloc extends Bloc<AdminOrdersEvent, AdminOrdersState> {
  final StoreOrdersRepository _storeOrdersRepository;

  AdminOrdersBloc(this._storeOrdersRepository) : super(AdminOrdersInitial()) {
    on<LoadAdminOrders>(_onLoadAdminOrders);
    on<ConfirmStoreOrder>(_onConfirmStoreOrder);
    on<FilterAdminOrders>(_onFilterAdminOrders);
  }

  Future<void> _onLoadAdminOrders(
      LoadAdminOrders event, Emitter<AdminOrdersState> emit) async {
    emit(AdminOrdersLoading());
    
    try {
      // Admins can view all store orders, so we'll need to implement 
      // a method to get all orders across stores (this might require
      // backend API enhancement since current API only supports per-store queries)
      // For now, we'll implement with a placeholder approach
      final orders = await _storeOrdersRepository.getAllStoreOrders(event.filter);
      emit(AdminOrdersLoaded(orders, currentFilter: event.filter));
    } catch (e) {
      emit(AdminOrdersError(e.toString()));
    }
  }

  Future<void> _onConfirmStoreOrder(
      ConfirmStoreOrder event, Emitter<AdminOrdersState> emit) async {
    try {
      final confirmedOrder = await _storeOrdersRepository.confirmStoreOrder(event.storeOrderId);
      // Reload orders to reflect the confirmation
      add(LoadAdminOrders());
      emit(AdminOrderConfirmed(confirmedOrder));
    } catch (e) {
      emit(AdminOrdersError('Failed to confirm order: ${e.toString()}'));
    }
  }

  Future<void> _onFilterAdminOrders(
      FilterAdminOrders event, Emitter<AdminOrdersState> emit) async {
    add(LoadAdminOrders(filter: event.filter));
  }
}
```

## Expected Outcome
- Admin interface to view all platform orders
- Order confirmation functionality using the documented API endpoint
- Filtering capabilities for admin order management
- Proper authentication and authorization following API requirements (admin access only)

## Visual Presentation
- Dashboard showing all platform orders requiring admin attention
- Clear visual indicators of orders that need confirmation
- Confirmation button with appropriate styling
- Order details showing store ID, order ID, current state, and timestamps
- Filtering options for admin efficiency

## Related Notes
- The API documentation specifically mentions that confirm endpoint requires "Admin access required"
- The confirmation endpoint changes state to "confirmed" as per the response example
- This is a specific admin function that differs from merchant order updates
- The documentation doesn't provide details on how to retrieve all orders for admins (only by store for merchants)

## Files to Read Before Implementing
- `lib/models/store_order/store_order_model.dart` - The StoreOrder model based on API documentation
- `lib/services/store_orders_api_service.dart` - Store orders API service
- `lib/bloc/orders/` - To understand existing order BLoC patterns
- `lib/components/` - Existing UI components that might be reusable
- `lib/theme/` - Current theme definition for consistent styling

## Architecture
- Will use the existing BLoC pattern for state management
- Repository pattern will abstract data access for admin operations
- Service layer will handle API communication with the backend following documented structures
- The UI will be built using Flutter widgets following existing design system
- Will implement proper error handling and loading states
- Authentication will be handled according to API documentation requirements (admin access only)