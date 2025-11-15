# Phase 1.3: Merchant/Store Owner Dashboard Implementation

## Feature Overview
Implement the core dashboard functionality for merchants/store owners to manage their stores. This phase will create the UI and business logic for merchants to view and manage their store information, orders, and performance metrics.

## Related API Endpoints
- **GET** `/api/storeOrders?storeId=` - Get orders for a specific store (Merchant access)
- **PUT** `/api/storeOrders/:storeOrderId` - Update order status (Merchant access)

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
- `lib/models/store/store_dashboard_model.dart` - Dashboard data model
- `lib/models/store/store_orders_filter_model.dart` - Order filtering model

## Store Dashboard Model
```dart
class StoreDashboardData {
  final String storeId;
  final String storeName;
  final int totalOrders;
  final int pendingOrders;
  final int processingOrders;
  final int completedOrders;
  final double revenue;
  final double revenueToday;
  final double revenueThisWeek;
  final double revenueThisMonth;
  final int newCustomers;
  final double avgOrderValue;
  final double conversionRate;
  final List<RecentOrder> recentOrders;
  final List<ProductPerformance> topSellingProducts;
  final List<Store> managedStores;  // For merchants managing multiple stores

  StoreDashboardData({
    required this.storeId,
    required this.storeName,
    required this.totalOrders,
    required this.pendingOrders,
    required this.processingOrders,
    required this.completedOrders,
    required this.revenue,
    required this.revenueToday,
    required this.revenueThisWeek,
    required this.revenueThisMonth,
    required this.newCustomers,
    required this.avgOrderValue,
    required this.conversionRate,
    required this.recentOrders,
    required this.topSellingProducts,
    required this.managedStores,
  });

  factory StoreDashboardData.fromJson(Map<String, dynamic> json) {
    return StoreDashboardData(
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      totalOrders: json['totalOrders'] as int,
      pendingOrders: json['pendingOrders'] as int,
      processingOrders: json['processingOrders'] as int,
      completedOrders: json['completedOrders'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      revenueToday: (json['revenueToday'] as num).toDouble(),
      revenueThisWeek: (json['revenueThisWeek'] as num).toDouble(),
      revenueThisMonth: (json['revenueThisMonth'] as num).toDouble(),
      newCustomers: json['newCustomers'] as int,
      avgOrderValue: (json['avgOrderValue'] as num).toDouble(),
      conversionRate: (json['conversionRate'] as num).toDouble(),
      recentOrders: (json['recentOrders'] as List)
          .map((e) => RecentOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      topSellingProducts: (json['topSellingProducts'] as List)
          .map((e) => ProductPerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
      managedStores: (json['managedStores'] as List)
          .map((e) => Store.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RecentOrder {
  final String orderId;
  final String customerId;
  final String customerName;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String paymentMethod;

  RecentOrder({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      orderId: json['orderId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paymentMethod: json['paymentMethod'] as String,
    );
  }
}

class ProductPerformance {
  final String productId;
  final String productName;
  final String productImage;
  final int unitsSold;
  final double revenueGenerated;
  final double avgRating;

  ProductPerformance({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.unitsSold,
    required this.revenueGenerated,
    required this.avgRating,
  });

  factory ProductPerformance.fromJson(Map<String, dynamic> json) {
    return ProductPerformance(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      unitsSold: json['unitsSold'] as int,
      revenueGenerated: (json['revenueGenerated'] as num).toDouble(),
      avgRating: (json['avgRating'] as num).toDouble(),
    );
  }
}
```

## Store Dashboard BLoC

### Events
```dart
abstract class StoreDashboardEvent {}

class LoadStoreDashboard extends StoreDashboardEvent {
  final String storeId;

  LoadStoreDashboard(this.storeId);
}

class SwitchStore extends StoreDashboardEvent {
  final String storeId;

  SwitchStore(this.storeId);
}

class RefreshStoreDashboard extends StoreDashboardEvent {
  final String storeId;

  RefreshStoreDashboard(this.storeId);
}
```

### States
```dart
abstract class StoreDashboardState {}

class StoreDashboardInitial extends StoreDashboardState {}

class StoreDashboardLoading extends StoreDashboardState {}

class StoreDashboardLoaded extends StoreDashboardState {
  final StoreDashboardData dashboardData;

  StoreDashboardLoaded(this.dashboardData);
}

class StoreDashboardError extends StoreDashboardState {
  final String message;

  StoreDashboardError(this.message);
}
```

### BLoC Implementation
```dart
class StoreDashboardBloc extends Bloc<StoreDashboardEvent, StoreDashboardState> {
  final StoresRepository _storesRepository;
  final AuthRepository _authRepository;

  StoreDashboardBloc(this._storesRepository, this._authRepository) 
      : super(StoreDashboardInitial()) {
    on<LoadStoreDashboard>(_onLoadStoreDashboard);
    on<SwitchStore>(_onSwitchStore);
    on<RefreshStoreDashboard>(_onRefreshStoreDashboard);
  }

  Future<void> _onLoadStoreDashboard(
      LoadStoreDashboard event, Emitter<StoreDashboardState> emit) async {
    emit(StoreDashboardLoading());
    
    try {
      final dashboardData = await _storesRepository.getStoreDashboard(event.storeId);
      emit(StoreDashboardLoaded(dashboardData));
    } catch (e) {
      emit(StoreDashboardError(e.toString()));
    }
  }

  Future<void> _onSwitchStore(
      SwitchStore event, Emitter<StoreDashboardState> emit) async {
    try {
      await _authRepository.switchStore(event.storeId);
      add(LoadStoreDashboard(event.storeId));
    } catch (e) {
      emit(StoreDashboardError('Failed to switch store: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshStoreDashboard(
      RefreshStoreDashboard event, Emitter<StoreDashboardState> emit) async {
    emit(StoreDashboardLoading());
    
    try {
      final dashboardData = await _storesRepository.getStoreDashboard(event.storeId);
      emit(StoreDashboardLoaded(dashboardData));
    } catch (e) {
      emit(StoreDashboardError(e.toString()));
    }
  }
}
```

## Store Orders BLoC

### Events
```dart
abstract class StoreOrdersEvent {}

class LoadStoreOrders extends StoreOrdersEvent {
  final String storeId;
  final StoreOrdersFilter? filter;

  LoadStoreOrders(this.storeId, {this.filter});
}

class UpdateOrderStatus extends StoreOrdersEvent {
  final String storeOrderId;
  final String newStatus;
  final String storeId;

  UpdateOrderStatus({
    required this.storeOrderId,
    required this.newStatus,
    required this.storeId,
  });
}

class FilterStoreOrders extends StoreOrdersEvent {
  final String storeId;
  final StoreOrdersFilter filter;

  FilterStoreOrders(this.storeId, this.filter);
}
```

### States
```dart
abstract class StoreOrdersState {}

class StoreOrdersInitial extends StoreOrdersState {}

class StoreOrdersLoading extends StoreOrdersState {}

class StoreOrdersLoaded extends StoreOrdersState {
  final List<Order> orders;
  final StoreOrdersFilter? currentFilter;

  StoreOrdersLoaded(this.orders, {this.currentFilter});
}

class StoreOrdersError extends StoreOrdersState {
  final String message;

  StoreOrdersError(this.message);
}

class StoreOrderStatusUpdated extends StoreOrdersState {
  final Order updatedOrder;

  StoreOrderStatusUpdated(this.updatedOrder);
}
```

### BLoC Implementation
```dart
class StoreOrdersBloc extends Bloc<StoreOrdersEvent, StoreOrdersState> {
  final OrdersRepository _ordersRepository;

  StoreOrdersBloc(this._ordersRepository) : super(StoreOrdersInitial()) {
    on<LoadStoreOrders>(_onLoadStoreOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<FilterStoreOrders>(_onFilterStoreOrders);
  }

  Future<void> _onLoadStoreOrders(
      LoadStoreOrders event, Emitter<StoreOrdersState> emit) async {
    emit(StoreOrdersLoading());
    
    try {
      final orders = await _ordersRepository.getStoreOrders(event.storeId, event.filter);
      emit(StoreOrdersLoaded(orders, currentFilter: event.filter));
    } catch (e) {
      emit(StoreOrdersError(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
      UpdateOrderStatus event, Emitter<StoreOrdersState> emit) async {
    try {
      final updatedOrder = await _ordersRepository.updateStoreOrderStatus(
        event.storeOrderId,
        event.newStatus,
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
    add(LoadStoreOrders(event.storeId, filter: event.filter));
  }
}
```

## Store Orders Filter Model
```dart
class StoreOrdersFilter {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<String>? statuses;  // e.g., ['pending', 'processing', 'completed']
  final String? customerName;
  final String? orderId;
  final int? page;
  final int? limit;
  final String? sortBy;  // e.g., 'createdAt', 'totalAmount'
  final String? sortOrder;  // 'asc' or 'desc'

  StoreOrdersFilter({
    this.dateFrom,
    this.dateTo,
    this.statuses,
    this.customerName,
    this.orderId,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (dateFrom != null) 'dateFrom': dateFrom!.toIso8601String(),
      if (dateTo != null) 'dateTo': dateTo!.toIso8601String(),
      if (statuses != null) 'statuses': statuses!.join(','),
      if (customerName != null) 'customerName': customerName,
      if (orderId != null) 'orderId': orderId,
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    }..removeWhere((key, value) => value == null);
  }
}
```

## Expected Outcome
- Merchant dashboard showing store performance metrics
- Order management interface for merchants to update order statuses
- Ability to filter and search store orders
- Navigation between multiple stores for merchants managing more than one
- Real-time updates of order statuses

## Visual Presentation
- Dashboard with key performance metrics (sales, orders, customers)
- Card-based UI showing store summary information
- Order list with status indicators and quick action buttons
- Filtering and search functionality for orders
- Store selector for merchants managing multiple stores
- Charts showing sales trends and performance metrics

## Related Notes
- Merchants can only access orders for stores they are assigned to
- The order status update functionality follows the backend API requirements
- Dashboard metrics need to be calculated based on the store's data
- The UI should be responsive and work well on both mobile and tablet devices for merchants

## Files to Read Before Implementing
- `lib/views/orders/` - To understand the existing order UI patterns
- `lib/bloc/orders/` - To understand the existing order BLoC patterns
- `lib/models/order/order_model.dart` - Current order model for reference
- `lib/components/` - Existing UI components that might be reusable
- `lib/theme/` - Current theme definition for consistent styling

## Architecture
- Will use the existing BLoC pattern for state management
- Repository pattern will abstract data access for store operations
- Service layer will handle API communication with the backend
- The UI will be built using Flutter widgets following the existing design system
- Will implement proper error handling and loading states