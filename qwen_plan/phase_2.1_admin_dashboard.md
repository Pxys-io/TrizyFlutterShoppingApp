# Phase 2.1: Admin Dashboard and Store Management Implementation

## Feature Overview
Implement the admin dashboard functionality to manage platform-wide operations including store management, order approval, user management, and platform analytics. This phase will create the UI and business logic for administrators to oversee and manage the multi-tenant e-commerce platform.

## Related API Endpoints
- **POST** `/api/stores` - Create a new store (Admin only, requires admin access)
- **PUT** `/api/storeOrders/:storeOrderId/confirm` - Approve order (Admin only)
- **POST** `/api/register` - Register user (with `isAdmin` field)
- Additional endpoints that may be available for admin functions (based on API documentation analysis)

## Current Dart Files
- `lib/views/` - Existing UI pages
- `lib/bloc/` - Existing BLoC files
- `lib/components/` - Existing UI components
- `lib/models/order/order_model.dart` - Current order model
- `lib/models/user/user_model.dart` - Current user model

## Files to Create
- `lib/views/admin/admin_dashboard_view.dart` - Main admin dashboard UI
- `lib/bloc/admin/admin_dashboard_bloc.dart` - Admin dashboard BLoC
- `lib/bloc/admin/admin_dashboard_event.dart` - Admin dashboard events
- `lib/bloc/admin/admin_dashboard_state.dart` - Admin dashboard states
- `lib/views/admin/admin_stores_view.dart` - Admin store management UI
- `lib/bloc/admin/admin_stores_bloc.dart` - Admin stores BLoC
- `lib/bloc/admin/admin_stores_event.dart` - Admin stores events
- `lib/bloc/admin/admin_stores_state.dart` - Admin stores states
- `lib/views/admin/admin_orders_view.dart` - Admin order management UI
- `lib/bloc/admin/admin_orders_bloc.dart` - Admin orders BLoC
- `lib/bloc/admin/admin_orders_event.dart` - Admin orders events
- `lib/bloc/admin/admin_orders_state.dart` - Admin orders states
- `lib/views/admin/admin_users_view.dart` - Admin user management UI
- `lib/views/admin/admin_analytics_view.dart` - Admin analytics UI
- `lib/components/admin/admin_summary_card.dart` - Admin summary component
- `lib/components/admin/store_approval_card.dart` - Store approval component
- `lib/models/admin/admin_dashboard_model.dart` - Admin dashboard data model
- `lib/models/admin/create_store_request_model.dart` - Admin store creation model
- `lib/models/admin/admin_orders_filter_model.dart` - Admin order filtering model

## Admin Dashboard Model
```dart
class AdminDashboardData {
  final int totalStores;
  final int activeStores;
  final int pendingStores;
  final int suspendedStores;
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final double totalRevenue;
  final double revenueToday;
  final double revenueThisWeek;
  final double revenueThisMonth;
  final double platformCommission;
  final List<StoreForApproval> storesForApproval;
  final List<RecentOrder> recentOrders;
  final List<PlatformMetric> platformMetrics;
  final List<User> recentUsers;

  AdminDashboardData({
    required this.totalStores,
    required this.activeStores,
    required this.pendingStores,
    required this.suspendedStores,
    required this.totalOrders,
    required this.pendingOrders,
    required this.confirmedOrders,
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.totalRevenue,
    required this.revenueToday,
    required this.revenueThisWeek,
    required this.revenueThisMonth,
    required this.platformCommission,
    required this.storesForApproval,
    required this.recentOrders,
    required this.platformMetrics,
    required this.recentUsers,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      totalStores: json['totalStores'] as int,
      activeStores: json['activeStores'] as int,
      pendingStores: json['pendingStores'] as int,
      suspendedStores: json['suspendedStores'] as int,
      totalOrders: json['totalOrders'] as int,
      pendingOrders: json['pendingOrders'] as int,
      confirmedOrders: json['confirmedOrders'] as int,
      totalUsers: json['totalUsers'] as int,
      activeUsers: json['activeUsers'] as int,
      newUsersToday: json['newUsersToday'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      revenueToday: (json['revenueToday'] as num).toDouble(),
      revenueThisWeek: (json['revenueThisWeek'] as num).toDouble(),
      revenueThisMonth: (json['revenueThisMonth'] as num).toDouble(),
      platformCommission: (json['platformCommission'] as num).toDouble(),
      storesForApproval: (json['storesForApproval'] as List)
          .map((e) => StoreForApproval.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentOrders: (json['recentOrders'] as List)
          .map((e) => RecentOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      platformMetrics: (json['platformMetrics'] as List)
          .map((e) => PlatformMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentUsers: (json['recentUsers'] as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StoreForApproval {
  final String storeId;
  final String storeName;
  final String ownerName;
  final String ownerEmail;
  final String businessId;
  final String taxId;
  final String createdAt;
  final String rejectionReason;

  StoreForApproval({
    required this.storeId,
    required this.storeName,
    required this.ownerName,
    required this.ownerEmail,
    required this.businessId,
    required this.taxId,
    required this.createdAt,
    required this.rejectionReason,
  });

  factory StoreForApproval.fromJson(Map<String, dynamic> json) {
    return StoreForApproval(
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      ownerName: json['ownerName'] as String,
      ownerEmail: json['ownerEmail'] as String,
      businessId: json['businessId'] as String,
      taxId: json['taxId'] as String,
      createdAt: json['createdAt'] as String,
      rejectionReason: json['rejectionReason'] as String,
    );
  }
}

class PlatformMetric {
  final String name;
  final String description;
  final double value;
  final String unit;
  final String trend; // 'up', 'down', 'stable'

  PlatformMetric({
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.trend,
  });

  factory PlatformMetric.fromJson(Map<String, dynamic> json) {
    return PlatformMetric(
      name: json['name'] as String,
      description: json['description'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      trend: json['trend'] as String,
    );
  }
}
```

## Admin Dashboard BLoC

### Events
```dart
abstract class AdminDashboardEvent {}

class LoadAdminDashboard extends AdminDashboardEvent {}

class AdminRefreshDashboard extends AdminDashboardEvent {}

class ApproveStore extends AdminDashboardEvent {
  final String storeId;

  ApproveStore(this.storeId);
}

class RejectStore extends AdminDashboardEvent {
  final String storeId;
  final String reason;

  RejectStore(this.storeId, this.reason);
}
```

### States
```dart
abstract class AdminDashboardState {}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminDashboardData dashboardData;

  AdminDashboardLoaded(this.dashboardData);
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  AdminDashboardError(this.message);
}

class StoreApprovalSuccess extends AdminDashboardState {
  final String message;

  StoreApprovalSuccess(this.message);
}

class StoreRejectionSuccess extends AdminDashboardState {
  final String message;

  StoreRejectionSuccess(this.message);
}
```

### BLoC Implementation
```dart
class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminRepository _adminRepository;

  AdminDashboardBloc(this._adminRepository) : super(AdminDashboardInitial()) {
    on<LoadAdminDashboard>(_onLoadAdminDashboard);
    on<AdminRefreshDashboard>(_onRefreshAdminDashboard);
    on<ApproveStore>(_onApproveStore);
    on<RejectStore>(_onRejectStore);
  }

  Future<void> _onLoadAdminDashboard(
      LoadAdminDashboard event, Emitter<AdminDashboardState> emit) async {
    emit(AdminDashboardLoading());
    
    try {
      final dashboardData = await _adminRepository.getAdminDashboardData();
      emit(AdminDashboardLoaded(dashboardData));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshAdminDashboard(
      AdminRefreshDashboard event, Emitter<AdminDashboardState> emit) async {
    emit(AdminDashboardLoading());
    
    try {
      final dashboardData = await _adminRepository.getAdminDashboardData();
      emit(AdminDashboardLoaded(dashboardData));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }

  Future<void> _onApproveStore(
      ApproveStore event, Emitter<AdminDashboardState> emit) async {
    try {
      await _adminRepository.approveStore(event.storeId);
      final dashboardData = await _adminRepository.getAdminDashboardData();
      emit(AdminDashboardLoaded(dashboardData));
      emit(StoreApprovalSuccess('Store approved successfully'));
    } catch (e) {
      emit(AdminDashboardError('Failed to approve store: ${e.toString()}'));
    }
  }

  Future<void> _onRejectStore(
      RejectStore event, Emitter<AdminDashboardState> emit) async {
    try {
      await _adminRepository.rejectStore(event.storeId, event.reason);
      final dashboardData = await _adminRepository.getAdminDashboardData();
      emit(AdminDashboardLoaded(dashboardData));
      emit(StoreRejectionSuccess('Store rejected successfully'));
    } catch (e) {
      emit(AdminDashboardError('Failed to reject store: ${e.toString()}'));
    }
  }
}
```

## Admin Stores Management

### Admin Stores BLoC Events
```dart
abstract class AdminStoresEvent {}

class LoadAdminStores extends AdminStoresEvent {
  final AdminStoresFilter? filter;

  LoadAdminStores({this.filter});
}

class CreateStoreAdmin extends AdminStoresEvent {
  final CreateStoreRequest request;

  CreateStoreAdmin(this.request);
}

class UpdateStoreAdmin extends AdminStoresEvent {
  final Store store;

  UpdateStoreAdmin(this.store);
}

class DeleteStoreAdmin extends AdminStoresEvent {
  final String storeId;

  DeleteStoreAdmin(this.storeId);
}

class ToggleStoreStatus extends AdminStoresEvent {
  final String storeId;
  final bool newStatus;

  ToggleStoreStatus(this.storeId, this.newStatus);
}

class FilterAdminStores extends AdminStoresEvent {
  final AdminStoresFilter filter;

  FilterAdminStores(this.filter);
}
```

### Admin Stores BLoC States
```dart
abstract class AdminStoresState {}

class AdminStoresInitial extends AdminStoresState {}

class AdminStoresLoading extends AdminStoresState {}

class AdminStoresLoaded extends AdminStoresState {
  final List<Store> stores;
  final AdminStoresFilter? currentFilter;

  AdminStoresLoaded(this.stores, {this.currentFilter});
}

class AdminStoreCreated extends AdminStoresState {
  final Store newStore;

  AdminStoreCreated(this.newStore);
}

class AdminStoreUpdated extends AdminStoresState {
  final Store updatedStore;

  AdminStoreUpdated(this.updatedStore);
}

class AdminStoreDeleted extends AdminStoresState {
  final String storeId;

  AdminStoreDeleted(this.storeId);
}

class AdminStoresError extends AdminStoresState {
  final String message;

  AdminStoresError(this.message);
}
```

### Admin Stores Filter Model
```dart
class AdminStoresFilter {
  final String? name;
  final List<String>? statuses;  // e.g., ['active', 'pending', 'suspended', 'rejected']
  final String? ownerName;
  final String? ownerEmail;
  final String? businessId;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final int? page;
  final int? limit;
  final String? sortBy;  // e.g., 'createdAt', 'name', 'revenue'
  final String? sortOrder;  // 'asc' or 'desc'

  AdminStoresFilter({
    this.name,
    this.statuses,
    this.ownerName,
    this.ownerEmail,
    this.businessId,
    this.createdAfter,
    this.createdBefore,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (name != null) 'name': name,
      if (statuses != null) 'statuses': statuses!.join(','),
      if (ownerName != null) 'ownerName': ownerName,
      if (ownerEmail != null) 'ownerEmail': ownerEmail,
      if (businessId != null) 'businessId': businessId,
      if (createdAfter != null) 'createdAfter': createdAfter!.toIso8601String(),
      if (createdBefore != null) 'createdBefore': createdBefore!.toIso8601String(),
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    }..removeWhere((key, value) => value == null);
  }
}
```

## Admin Orders Management

### Admin Orders Filter Model
```dart
class AdminOrdersFilter {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<String>? statuses;  // e.g., ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled']
  final String? customerName;
  final String? orderId;
  final String? storeName;
  final double? minAmount;
  final double? maxAmount;
  final int? page;
  final int? limit;
  final String? sortBy;  // e.g., 'createdAt', 'totalAmount', 'status'
  final String? sortOrder;  // 'asc' or 'desc'

  AdminOrdersFilter({
    this.dateFrom,
    this.dateTo,
    this.statuses,
    this.customerName,
    this.orderId,
    this.storeName,
    this.minAmount,
    this.maxAmount,
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
      if (storeName != null) 'storeName': storeName,
      if (minAmount != null) 'minAmount': minAmount,
      if (maxAmount != null) 'maxAmount': maxAmount,
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    }..removeWhere((key, value) => value == null);
  }
}
```

### Order Approval BLoC Events
```dart
abstract class AdminStoreOrderEvent {}

class LoadAdminStoreOrders extends AdminStoreOrderEvent {
  final AdminOrdersFilter? filter;

  LoadAdminStoreOrders({this.filter});
}

class ConfirmStoreOrder extends AdminStoreOrderEvent {
  final String storeOrderId;

  ConfirmStoreOrder(this.storeOrderId);
}

class FilterAdminStoreOrders extends AdminStoreOrderEvent {
  final AdminOrdersFilter filter;

  FilterAdminStoreOrders(this.filter);
}
```

### Order Approval BLoC States
```dart
abstract class AdminStoreOrderState {}

class AdminStoreOrdersInitial extends AdminStoreOrderState {}

class AdminStoreOrdersLoading extends AdminStoreOrderState {}

class AdminStoreOrdersLoaded extends AdminStoreOrderState {
  final List<Order> orders;
  final AdminOrdersFilter? currentFilter;

  AdminStoreOrdersLoaded(this.orders, {this.currentFilter});
}

class AdminStoreOrderConfirmed extends AdminStoreOrderState {
  final Order confirmedOrder;

  AdminStoreOrderConfirmed(this.confirmedOrder);
}

class AdminStoreOrdersError extends AdminStoreOrderState {
  final String message;

  AdminStoreOrdersError(this.message);
}
```

## Expected Outcome
- Admin dashboard showing platform-wide metrics and key performance indicators
- Store management interface to approve, reject, or suspend stores
- Order management system with admin-level order confirmation
- User management capabilities
- Platform analytics and reporting
- Store creation functionality for admin users

## Visual Presentation
- Dashboard with comprehensive platform metrics
- Card-based UI showing different aspects of platform health
- Store approval workflow with detailed information
- Order management view with filtering and search
- Analytics charts showing platform trends
- Responsive design for admin panel access on different devices

## Related Notes
- Admin users have elevated privileges to manage the entire platform
- Store approval process involves verifying business credentials
- The admin dashboard should provide insights into platform performance
- Order confirmation by admin may be required for high-value orders or special cases
- The UI should clearly differentiate between admin functions and regular user functions

## Files to Read Before Implementing
- `lib/views/admin/` - If any existing admin pages exist
- `lib/bloc/orders/` - To understand the existing order BLoC patterns
- `lib/models/order/order_model.dart` - Current order model for reference
- `lib/components/` - Existing UI components that might be reusable
- `lib/theme/` - Current theme definition for consistent styling
- `lib/routing/router.dart` - For understanding how to add admin routes
- `lib/di/service_locator.dart` - For adding admin repository to DI

## Architecture
- Will use the existing BLoC pattern for state management
- Repository pattern will abstract data access for admin operations
- Service layer will handle API communication with the backend
- The UI will be built using Flutter widgets following the existing design system
- Will implement proper error handling and loading states
- Role-based access control will be enforced at both UI and service levels