# Corrected Phase 1.3: Merchant/Store Owner Dashboard Implementation (Based on API Documentation)

## Feature Overview
Implement the core dashboard functionality for merchants/store owners to manage their stores using the exact API structures from the documentation. This phase will create the UI and business logic for merchants to view and manage their store orders based on the documented API endpoints.

## Related API Endpoints
- **GET** `/api/storeOrders?storeId=` - Get orders for a specific store (Merchant access)
- **PUT** `/api/storeOrders/:storeOrderId` - Update order status (Merchant access)

## API Structures (from documentation)
### Get Store Orders Response
```json
{
  "storeOrders": [
    {
      "_id": "6553d3e3c7e3f3e3c7e3f3ec",
      "storeId": "6553d3e3c7e3f3e3c7e3f3e4",
      "orderId": "6553d3e3c7e3f3e3c7e3f3eb",
      "state": "prepared",
      "createdAt": "2023-11-14T12:00:00.000Z",
      "updatedAt": "2023-11-14T12:00:00.000Z"
    }
  ]
}
```

### Update Order Request/Response
**Request:**
```json
{
  "state": "prepared"
}
```

**Response:**
```json
{
  "_id": "6553d3e3c7e3f3e3c7e3f3ec",
  "storeId": "6553d3e3c7e3f3e3c7e3f3e4",
  "orderId": "6553d3e3c7e3f3e3c7e3f3eb",
  "state": "prepared",
  "createdAt": "2023-11-14T12:00:00.000Z",
  "updatedAt": "2023-11-14T12:00:00.000Z"
}
```

## Current Dart Files
- `lib/views/` - Existing UI pages
- `lib/bloc/` - Existing BLoC files
- `lib/components/` - Existing UI components
- `lib/models/order/order_model.dart` - Current order model

## Files to Create
- `lib/views/store_owner/store_dashboard_view.dart` - Main merchant dashboard UI
- `lib/bloc/store_owner/store_dashboard_bloc.dart` - Dashboard BLoC
- `lib/bloc/store_owner/store_dashboard_event.dart` - Dashboard events
- `lib/bloc/store_owner/store_dashboard_state.dart` - Dashboard states
- `lib/views/store_owner/store_orders_view.dart` - Store orders management UI
- `lib/bloc/store_owner/store_orders_bloc.dart` - Store orders BLoC
- `lib/bloc/store_owner/store_orders_event.dart` - Store orders events
- `lib/bloc/store_owner/store_orders_state.dart` - Store orders states
- `lib/views/store_owner/store_settings_view.dart` - Store settings UI
- `lib/components/store_owner/store_summary_card.dart` - Store summary component
- `lib/components/store_owner/order_status_changer.dart` - Order status component
- `lib/models/store_order_filter_model.dart` - Order filtering model

## Store Order Filter Model
```dart
class StoreOrderFilter {
  final String storeId;
  final String? state;  // Filter by order state (e.g., 'pending', 'prepared', 'confirmed')
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? orderId;
  final int? page;
  final int? limit;

  StoreOrderFilter({
    required this.storeId,
    this.state,
    this.dateFrom,
    this.dateTo,
    this.orderId,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      'storeId': storeId,
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

## Store Orders BLoC Implementation

### Events
```dart
abstract class StoreOrdersEvent {}

class LoadStoreOrders extends StoreOrdersEvent {
  final String storeId;
  final StoreOrderFilter? filter;

  LoadStoreOrders(this.storeId, {this.filter});
}

class UpdateOrderStatus extends StoreOrdersEvent {
  final String storeOrderId;
  final String newState;
  final String storeId;

  UpdateOrderStatus({
    required this.storeOrderId,
    required this.newState,
    required this.storeId,
  });
}

class FilterStoreOrders extends StoreOrdersEvent {
  final StoreOrderFilter filter;

  FilterStoreOrders(this.filter);
}
```

### States
```dart
abstract class StoreOrdersState {}

class StoreOrdersInitial extends StoreOrdersState {}

class StoreOrdersLoading extends StoreOrdersState {}

class StoreOrdersLoaded extends StoreOrdersState {
  final List<StoreOrder> orders;
  final StoreOrderFilter? currentFilter;

  StoreOrdersLoaded(this.orders, {this.currentFilter});
}

class StoreOrdersError extends StoreOrdersState {
  final String message;

  StoreOrdersError(this.message);
}

class StoreOrderStatusUpdated extends StoreOrdersState {
  final StoreOrder updatedOrder;

  StoreOrderStatusUpdated(this.updatedOrder);
}
```

### BLoC Implementation
```dart
class StoreOrdersBloc extends Bloc<StoreOrdersEvent, StoreOrdersState> {
  final StoreOrdersRepository _storeOrdersRepository;

  StoreOrdersBloc(this._storeOrdersRepository) : super(StoreOrdersInitial()) {
    on<LoadStoreOrders>(_onLoadStoreOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<FilterStoreOrders>(_onFilterStoreOrders);
  }

  Future<void> _onLoadStoreOrders(
      LoadStoreOrders event, Emitter<StoreOrdersState> emit) async {
    emit(StoreOrdersLoading());
    
    try {
      final orders = await _storeOrdersRepository.getStoreOrders(event.storeId, event.filter);
      emit(StoreOrdersLoaded(orders, currentFilter: event.filter));
    } catch (e) {
      emit(StoreOrdersError(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
      UpdateOrderStatus event, Emitter<StoreOrdersState> emit) async {
    try {
      final updatedOrder = await _storeOrdersRepository.updateStoreOrderStatus(
        event.storeOrderId,
        event.newState,
      );
      // Reload orders to reflect the update
      add(LoadStoreOrders(event.storeId));
      emit(StoreOrderStatusUpdated(updatedOrder));
    } catch (e) {
      emit(StoreOrdersError('Failed to update order status: ${e.toString()}'));
    }
  }

  Future<void> _onFilterStoreOrders(
      FilterStoreOrders event, Emitter<StoreOrdersState> emit) async {
    add(LoadStoreOrders(event.filter.storeId, filter: event.filter));
  }
}
```

## Expected Outcome
- Merchant dashboard showing store orders
- Order management interface for merchants to update order statuses
- Ability to filter store orders by various criteria
- Real-time updates of order statuses based on API documentation
- Proper authentication and authorization following API requirements

## Visual Presentation
- Order list with status indicators and quick action buttons
- Order details showing store ID, order ID, current state, and timestamps
- Status update controls with dropdown options based on valid states
- Filtering and search functionality for orders
- Clear visual indicators of order status changes

## Related Notes
- Merchants can only access orders for stores they are assigned to (as per API documentation)
- The order status update functionality matches the documented API requirements
- The API endpoint requires storeId as a query parameter for getting orders
- The update endpoint requires the new state in the request body

## Files to Read Before Implementing
- `lib/models/store_order/store_order_model.dart` - The StoreOrder model based on API documentation
- `lib/views/orders/` - To understand existing order UI patterns
- `lib/bloc/orders/` - To understand existing order BLoC patterns
- `lib/components/` - Existing UI components that might be reusable
- `lib/theme/` - Current theme definition for consistent styling

## Architecture
- Will use the existing BLoC pattern for state management
- Repository pattern will abstract data access for store operations
- Service layer will handle API communication with the backend following documented structures
- The UI will be built using Flutter widgets following existing design system
- Will implement proper error handling and loading states
- Authentication will be handled according to API documentation requirements