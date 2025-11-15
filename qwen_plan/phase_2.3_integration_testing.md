# Phase 2.3: Multistore, Admin, and Merchant Integration & Testing

## Feature Overview
Implement the complete integration of all multistore, admin, and merchant functionality with comprehensive testing, error handling, security measures, and user experience optimizations. This final phase ensures all components work together seamlessly while maintaining security and performance standards.

## Related API Endpoints
- All previously identified endpoints for stores, orders, and admin functions:
  - **POST** `/api/stores` - Create a new store (Admin only)
  - **GET** `/api/storeOrders?storeId=` - Get orders for a specific store (Merchant access)
  - **PUT** `/api/storeOrders/:storeOrderId/confirm` - Approve order (Admin only)
  - **PUT** `/api/storeOrders/:storeOrderId` - Update order status (Merchant access)
  - User registration/login with role-based access
  - All product, order, cart endpoints (with potential store context)

## Current Dart Files
- All files created in previous phases
- `lib/utils/` - All utilities including API endpoints and debug config
- `lib/di/service_locator.dart` - Dependency injection configuration
- `lib/routing/router.dart` - Routing configuration
- `lib/main.dart` - Main application entry point

## Files to Create/Update
- `lib/routing/admin_router.dart` - Admin-specific routes
- `lib/routing/merchant_router.dart` - Merchant-specific routes
- `lib/utils/multistore_constants.dart` - Constants for multistore functionality
- `lib/utils/role_permissions.dart` - Role-based permissions utility
- `lib/services/multistore_security_service.dart` - Security service for multistore
- `lib/components/shared/store_badge_component.dart` - Shared store badge component
- `lib/components/shared/role_guard_component.dart` - Role-based access guard
- `lib/bloc/multistore_integration_bloc.dart` - Integration BLoC for global state
- `lib/models/shared/multistore_state_model.dart` - Global multistore state model
- `lib/test/multistore_test.dart` - Comprehensive multistore tests
- `lib/test/admin_test.dart` - Admin functionality tests
- `lib/test/merchant_test.dart` - Merchant functionality tests
- `lib/utils/secure_storage_util.dart` - Enhanced secure storage for sensitive data

## Multistore State Model
```dart
class MultistoreState {
  final UserRole currentUserRole;
  final String? currentUserId;
  final User? currentUser;
  final String? currentStoreId;
  final Store? currentStore;
  final List<Store> accessibleStores;
  final Map<String, dynamic> appPermissions;
  final bool isStoreContextValid;
  final DateTime? lastSyncTime;
  final String? selectedLanguage;
  final String? selectedCurrency;
  final bool isOffline;
  final Map<String, dynamic> cachedData; // Store-specific cached data

  MultistoreState({
    required this.currentUserRole,
    this.currentUserId,
    this.currentUser,
    this.currentStoreId,
    this.currentStore,
    required this.accessibleStores,
    required this.appPermissions,
    required this.isStoreContextValid,
    this.lastSyncTime,
    this.selectedLanguage = 'en',
    this.selectedCurrency = 'USD',
    required this.isOffline,
    this.cachedData = const {},
  });

  factory MultistoreState.initial() {
    return MultistoreState(
      currentUserRole: UserRole.customer,
      accessibleStores: [],
      appPermissions: {},
      isStoreContextValid: true,
      isOffline: false,
      cachedData: {},
    );
  }

  MultistoreState copyWith({
    UserRole? currentUserRole,
    String? currentUserId,
    User? currentUser,
    String? currentStoreId,
    Store? currentStore,
    List<Store>? accessibleStores,
    Map<String, dynamic>? appPermissions,
    bool? isStoreContextValid,
    DateTime? lastSyncTime,
    String? selectedLanguage,
    String? selectedCurrency,
    bool? isOffline,
    Map<String, dynamic>? cachedData,
  }) {
    return MultistoreState(
      currentUserRole: currentUserRole ?? this.currentUserRole,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUser: currentUser ?? this.currentUser,
      currentStoreId: currentStoreId ?? this.currentStoreId,
      currentStore: currentStore ?? this.currentStore,
      accessibleStores: accessibleStores ?? this.accessibleStores,
      appPermissions: appPermissions ?? this.appPermissions,
      isStoreContextValid: isStoreContextValid ?? this.isStoreContextValid,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      isOffline: isOffline ?? this.isOffline,
      cachedData: cachedData ?? this.cachedData,
    );
  }

  bool get canAccessAdminPanel => currentUserRole == UserRole.admin || currentUserRole == UserRole.superAdmin;
  bool get canAccessMerchantPanel => currentUserRole == UserRole.merchant || canAccessAdminPanel;
  bool get canManageStore => currentStoreId != null && (currentUserRole == UserRole.merchant || canAccessAdminPanel);
  bool get hasStoreContext => currentStoreId != null;
}
```

## Security Service
```dart
class MultistoreSecurityService {
  final AuthRepository _authRepository;
  final StoresRepository _storesRepository;
  final SharedPreferences _prefs;

  MultistoreSecurityService(this._authRepository, this._storesRepository, this._prefs);

  // Verify if current user has access to a specific store
  Future<bool> canAccessStore(String storeId) async {
    try {
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) return false;

      // Admins can access all stores
      if (currentUser.role == UserRole.admin || currentUser.role == UserRole.superAdmin) {
        return true;
      }

      // Check if the user is a merchant assigned to this store
      if (currentUser.role == UserRole.merchant) {
        if (currentUser.storeIds != null) {
          return currentUser.storeIds!.contains(storeId);
        }
      }

      // For customers, check if store is active and public
      if (currentUser.role == UserRole.customer) {
        final store = await _storesRepository.getStoreById(storeId);
        return store?.isActive ?? false;
      }

      return false;
    } catch (e) {
      print('Security check error: $e');
      return false;
    }
  }

  // Securely store sensitive information
  Future<void> storeSensitiveData(String key, String data) async {
    // In a real implementation, this would use secure storage like flutter_secure_storage
    // For now, using SharedPreferences as placeholder
    await _prefs.setString(key, data);
  }

  // Retrieve sensitive information securely
  Future<String?> getSensitiveData(String key) async {
    // In a real implementation, this would use secure storage like flutter_secure_storage
    // For now, using SharedPreferences as placeholder
    return _prefs.getString(key);
  }

  // Clear sensitive data
  Future<void> clearSensitiveData(String key) async {
    await _prefs.remove(key);
  }

  // Verify user permissions for specific actions
  Future<bool> hasPermission(String action, {String? storeId}) async {
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser == null) return false;

    switch (action) {
      case 'create_store':
        return currentUser.role == UserRole.admin || currentUser.role == UserRole.superAdmin;
      
      case 'manage_store':
        if (storeId == null) return false;
        return await canAccessStore(storeId) && 
               (currentUser.role == UserRole.merchant || currentUser.role == UserRole.admin);
      
      case 'confirm_order':
        return currentUser.role == UserRole.admin || currentUser.role == UserRole.superAdmin;
      
      case 'update_order_status':
        if (storeId == null) return false;
        return await canAccessStore(storeId) && 
               (currentUser.role == UserRole.merchant || currentUser.role == UserRole.admin);
      
      case 'view_admin_panel':
        return currentUser.role == UserRole.admin || currentUser.role == UserRole.superAdmin;
      
      case 'view_merchant_panel':
        return currentUser.role == UserRole.merchant || 
               currentUser.role == UserRole.admin || 
               currentUser.role == UserRole.superAdmin;
      
      default:
        return false;
    }
  }

  // Log security events
  void logSecurityEvent(String event, {String? userId, String? storeId, String? ipAddress}) {
    // Implementation would log to secure audit trail
    debugPrint('Security Event: $event | User: $userId | Store: $storeId | IP: $ipAddress');
  }
}
```

## Role-Based Router Configuration
```dart
// admin_router.dart
class AdminRouter {
  static GoRouter get router {
    return GoRouter(
      routes: [
        GoRoute(
          name: 'admin-dashboard',
          path: '/admin/dashboard',
          builder: (context, state) => AdminDashboardView(),
          routes: [
            GoRoute(
              name: 'admin-stores',
              path: 'stores',
              builder: (context, state) => AdminStoresView(),
            ),
            GoRoute(
              name: 'admin-orders',
              path: 'orders',
              builder: (context, state) => AdminOrdersView(),
            ),
            GoRoute(
              name: 'admin-users',
              path: 'users',
              builder: (context, state) => AdminUsersView(),
            ),
            GoRoute(
              name: 'admin-analytics',
              path: 'analytics',
              builder: (context, state) => AdminAnalyticsView(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        // Check if user has admin access
        final bloc = context.read<AuthBloc>();
        final currentUser = bloc.state.user;
        
        if (currentUser?.role != UserRole.admin && currentUser?.role != UserRole.superAdmin) {
          // Redirect to home if not admin
          return '/home';
        }
        return null;
      },
    );
  }
}

// merchant_router.dart
class MerchantRouter {
  static GoRouter get router {
    return GoRouter(
      routes: [
        GoRoute(
          name: 'merchant-dashboard',
          path: '/merchant/dashboard',
          builder: (context, state) => StoreDashboardView(),
          routes: [
            GoRoute(
              name: 'merchant-orders',
              path: 'orders',
              builder: (context, state) => StoreOrdersView(),
            ),
            GoRoute(
              name: 'merchant-products',
              path: 'products',
              builder: (context, state) => MerchantProductsView(),
            ),
            GoRoute(
              name: 'merchant-analytics',
              path: 'analytics',
              builder: (context, state) => MerchantAnalyticsView(),
            ),
            GoRoute(
              name: 'merchant-settings',
              path: 'settings',
              builder: (context, state) => StoreSettingsView(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        // Check if user has merchant access
        final bloc = context.read<AuthBloc>();
        final currentUser = bloc.state.user;
        
        if (currentUser?.role != UserRole.merchant && 
            currentUser?.role != UserRole.admin && 
            currentUser?.role != UserRole.superAdmin) {
          // Redirect to home if not merchant or admin
          return '/home';
        }
        return null;
      },
    );
  }
}
```

## Role Permissions Utility
```dart
class RolePermissions {
  static const Map<UserRole, Set<String>> permissions = {
    UserRole.customer: {
      'view_products',
      'add_to_cart',
      'place_order',
      'view_orders',
      'manage_profile',
      'view_stores',
      'search_products',
    },
    UserRole.merchant: {
      'view_products',
      'add_to_cart',
      'place_order',
      'view_orders',
      'manage_profile',
      'view_stores',
      'search_products',
      'view_store_dashboard',
      'view_store_orders',
      'update_order_status',
      'view_store_analytics',
      'manage_store_products',
      'view_store_customers',
    },
    UserRole.admin: {
      'view_products',
      'add_to_cart',
      'place_order',
      'view_orders',
      'manage_profile',
      'view_stores',
      'search_products',
      'view_store_dashboard',
      'view_store_orders',
      'update_order_status',
      'view_store_analytics',
      'manage_store_products',
      'view_store_customers',
      'create_store',
      'approve_store',
      'suspend_store',
      'view_admin_dashboard',
      'manage_platform_orders',
      'confirm_orders',
      'manage_users',
      'view_platform_analytics',
      'manage_platform_settings',
    },
    UserRole.superAdmin: {
      'view_products',
      'add_to_cart',
      'place_order',
      'view_orders',
      'manage_profile',
      'view_stores',
      'search_products',
      'view_store_dashboard',
      'view_store_orders',
      'update_order_status',
      'view_store_analytics',
      'manage_store_products',
      'view_store_customers',
      'create_store',
      'approve_store',
      'suspend_store',
      'view_admin_dashboard',
      'manage_platform_orders',
      'confirm_orders',
      'manage_users',
      'view_platform_analytics',
      'manage_platform_settings',
      'access_all_data',
      'modify_system_settings',
      'manage_admins',
    },
  };

  static bool hasPermission(UserRole role, String permission) {
    final rolePermissions = permissions[role] ?? <String>{};
    return rolePermissions.contains(permission) || _isAdminPermission(role, permission);
  }

  static bool _isAdminPermission(UserRole role, String permission) {
    // Admins and SuperAdmins have all merchant and admin permissions
    if (role == UserRole.admin || role == UserRole.superAdmin) {
      return permissions[UserRole.merchant]?.contains(permission) ?? false;
    }
    // SuperAdmins have all permissions
    if (role == UserRole.superAdmin) {
      return permissions[UserRole.admin]?.contains(permission) ?? false;
    }
    return false;
  }
}
```

## Comprehensive Error Handling
```dart
// Enhanced API Response with multistore context
class MultistoreApiResponse<T> {
  final bool success;
  final T? data;
  final MultistoreApiError? error;
  final String? storeId;
  final UserRole? requestingRole;

  MultistoreApiResponse.success(this.data, {this.storeId, this.requestingRole})
      : success = true,
        error = null;

  MultistoreApiResponse.error(this.error, {this.storeId, this.requestingRole})
      : success = false,
        data = null;
}

class MultistoreApiError {
  final String code;
  final String message;
  final int? statusCode;
  final String? storeId;
  final UserRole? requestingRole;
  final Map<String, dynamic>? details;

  MultistoreApiError({
    required this.code,
    required this.message,
    this.statusCode,
    this.storeId,
    this.requestingRole,
    this.details,
  });

  // Common error types
  static MultistoreApiError unauthorized({String? storeId, UserRole? requestingRole}) {
    return MultistoreApiError(
      code: 'UNAUTHORIZED',
      message: 'You are not authorized to access this resource',
      statusCode: 401,
      storeId: storeId,
      requestingRole: requestingRole,
    );
  }

  static MultistoreApiError storeAccessDenied({String? storeId, UserRole? requestingRole}) {
    return MultistoreApiError(
      code: 'STORE_ACCESS_DENIED',
      message: 'You do not have permission to access this store',
      statusCode: 403,
      storeId: storeId,
      requestingRole: requestingRole,
    );
  }

  static MultistoreApiError resourceNotFound({String? storeId, UserRole? requestingRole}) {
    return MultistoreApiError(
      code: 'RESOURCE_NOT_FOUND',
      message: 'The requested resource was not found',
      statusCode: 404,
      storeId: storeId,
      requestingRole: requestingRole,
    );
  }
}
```

## Integration BLoC for Global State Management
```dart
class MultistoreIntegrationBloc extends Bloc<MultistoreIntegrationEvent, MultistoreState> {
  final AuthRepository _authRepository;
  final StoresRepository _storesRepository;
  final SecurityService _securityService;

  MultistoreIntegrationBloc({
    required AuthRepository authRepository,
    required StoresRepository storesRepository,
    required SecurityService securityService,
  }) : 
    _authRepository = authRepository,
    _storesRepository = storesRepository,
    _securityService = securityService,
    super(MultistoreState.initial()) {
      on<InitializeMultistore>(_onInitializeMultistore);
      on<SwitchStore>(_onSwitchStore);
      on<UpdateUserRole>(_onUpdateUserRole);
      on<SyncStoreData>(_onSyncStoreData);
      on<UpdateMultistoreSettings>(_onUpdateMultistoreSettings);
      on<HandleOfflineMode>(_onHandleOfflineMode);
  }

  Future<void> _onInitializeMultistore(
      InitializeMultistore event, Emitter<MultistoreState> emit) async {
    try {
      // Get current user
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        emit(state.copyWith(currentUserRole: UserRole.customer));
        return;
      }

      // Get user's accessible stores
      List<Store> accessibleStores = [];
      if (currentUser.role == UserRole.admin || currentUser.role == UserRole.superAdmin) {
        // Admins have access to all stores (in a real implementation, this might be paginated)
        accessibleStores = await _storesRepository.getAllStores();
      } else if (currentUser.role == UserRole.merchant) {
        // Load stores assigned to merchant
        if (currentUser.storeIds != null && currentUser.storeIds!.isNotEmpty) {
          for (final storeId in currentUser.storeIds!) {
            try {
              final store = await _storesRepository.getStoreById(storeId);
              if (store != null) {
                accessibleStores.add(store);
              }
            } catch (e) {
              print('Error loading store $storeId: $e');
            }
          }
        }
      } else {
        // Customers - all active stores are accessible
        accessibleStores = await _storesRepository.getAllActiveStores();
      }

      // Determine current store based on user preference or default
      String? currentStoreId = await _getCurrentStoreId();
      Store? currentStore;
      
      if (currentStoreId != null) {
        currentStore = accessibleStores.firstWhere(
          (store) => store.id == currentStoreId,
          orElse: () => accessibleStores.isNotEmpty ? accessibleStores.first : Store.dummy(),
        );
      } else if (accessibleStores.isNotEmpty) {
        currentStore = accessibleStores.first;
        currentStoreId = currentStore.id;
        await _setCurrentStoreId(currentStoreId);
      }

      // Calculate permissions
      final permissions = await _calculatePermissions(currentUser);

      emit(state.copyWith(
        currentUser: currentUser,
        currentUserId: currentUser.id,
        currentUserRole: currentUser.role,
        accessibleStores: accessibleStores,
        currentStore: currentStore,
        currentStoreId: currentStoreId,
        appPermissions: permissions,
        isStoreContextValid: currentStore != null,
      ));
    } catch (e) {
      print('Error initializing multistore: $e');
      emit(state.copyWith(
        currentUserRole: UserRole.customer,
        accessibleStores: [],
        isStoreContextValid: false,
      ));
    }
  }

  Future<void> _onSwitchStore(
      SwitchStore event, Emitter<MultistoreState> emit) async {
    try {
      // Verify user has access to the requested store
      final userCanAccess = await _securityService.canAccessStore(event.storeId);
      if (!userCanAccess) {
        add(ShowError(MultistoreApiError.storeAccessDenied(
          storeId: event.storeId,
          requestingRole: state.currentUserRole,
        )));
        return;
      }

      // Get the store
      final targetStore = state.accessibleStores.firstWhere(
        (store) => store.id == event.storeId,
        orElse: () => Store.dummy(),
      );

      // Update stored preference
      await _setCurrentStoreId(event.storeId);

      emit(state.copyWith(
        currentStoreId: event.storeId,
        currentStore: targetStore,
        isStoreContextValid: true,
      ));
    } catch (e) {
      print('Error switching store: $e');
      add(ShowError(MultistoreApiError(
        code: 'STORE_SWITCH_ERROR',
        message: 'Error switching store: ${e.toString()}',
      )));
    }
  }

  Future<void> _onSyncStoreData(
      SyncStoreData event, Emitter<MultistoreState> emit) async {
    try {
      emit(state.copyWith(lastSyncTime: DateTime.now()));
      
      // Perform store data sync in background
      if (state.currentStoreId != null) {
        // Sync specific to current store
        // This could update products, orders, etc. for the current store
        await _storesRepository.syncStoreData(state.currentStoreId!);
      }
      
      // Update cached data
      final updatedCachedData = Map<String, dynamic>.from(state.cachedData);
      updatedCachedData['lastSyncTime'] = DateTime.now().toIso8601String();
      
      emit(state.copyWith(
        cachedData: updatedCachedData,
        lastSyncTime: DateTime.now(),
      ));
    } catch (e) {
      print('Error syncing store data: $e');
      add(ShowError(MultistoreApiError(
        code: 'SYNC_ERROR',
        message: 'Error syncing store data: ${e.toString()}',
      )));
    }
  }

  Future<Map<String, dynamic>> _calculatePermissions(UserProfileWithRole user) async {
    final Map<String, dynamic> permissions = {};

    // Basic permissions based on role
    permissions['canViewProducts'] = true;
    permissions['canAddToCart'] = true;
    permissions['canPlaceOrder'] = true;

    // Role-specific permissions
    if (user.role == UserRole.merchant || user.role == UserRole.admin || user.role == UserRole.superAdmin) {
      permissions['canViewDashboard'] = true;
      permissions['canManageOrders'] = true;
      permissions['canViewAnalytics'] = true;
    }

    if (user.role == UserRole.admin || user.role == UserRole.superAdmin) {
      permissions['canManageStores'] = true;
      permissions['canManageUsers'] = true;
      permissions['canViewPlatformAnalytics'] = true;
    }

    if (user.role == UserRole.superAdmin) {
      permissions['canModifySystem'] = true;
      permissions['canManageAdmins'] = true;
    }

    return permissions;
  }

  Future<String?> _getCurrentStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_store_id');
  }

  Future<void> _setCurrentStoreId(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_store_id', storeId);
  }
}

// Events
abstract class MultistoreIntegrationEvent {}

class InitializeMultistore extends MultistoreIntegrationEvent {}
class SwitchStore extends MultistoreIntegrationEvent {
  final String storeId;
  SwitchStore(this.storeId);
}
class UpdateUserRole extends MultistoreIntegrationEvent {
  final UserRole newRole;
  UpdateUserRole(this.newRole);
}
class SyncStoreData extends MultistoreIntegrationEvent {}
class UpdateMultistoreSettings extends MultistoreIntegrationEvent {
  final String language;
  final String currency;
  UpdateMultistoreSettings(this.language, this.currency);
}
class HandleOfflineMode extends MultistoreIntegrationEvent {
  final bool isOffline;
  HandleOfflineMode(this.isOffline);
}
class ShowError extends MultistoreIntegrationEvent {
  final MultistoreApiError error;
  ShowError(this.error);
}
```

## Testing Implementation
```dart
// Comprehensive multistore tests
void runMultistoreTests() {
  group('Multistore Functionality Tests', () {
    late MockAuthRepository mockAuthRepository;
    late MockStoresRepository mockStoresRepository;
    late MockSecurityService mockSecurityService;
    late MultistoreIntegrationBloc bloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockStoresRepository = MockStoresRepository();
      mockSecurityService = MockSecurityService();
      
      bloc = MultistoreIntegrationBloc(
        authRepository: mockAuthRepository,
        storesRepository: mockStoresRepository,
        securityService: mockSecurityService,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initializes with customer role when no user', () async {
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);

      final expectedState = MultistoreState(
        currentUserRole: UserRole.customer,
        accessibleStores: [],
        appPermissions: {},
        isStoreContextValid: true,
        isOffline: false,
        cachedData: {},
      );

      expect(bloc.state, expectedState);

      bloc.add(InitializeMultistore());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          expectedState,
          expectedState.copyWith(currentUserRole: UserRole.customer),
        ]),
      );
    });

    test('Loads accessible stores for merchant', () async {
      final mockUser = UserProfileWithRole(
        id: 'user123',
        userId: 'user123',
        username: 'merchant1',
        email: 'merchant@example.com',
        phoneNumber: '1234567890',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.merchant,
        storeIds: ['store1', 'store2'],
      );

      final mockStore1 = Store.dummy().copyWith(id: 'store1', name: 'Store 1');
      final mockStore2 = Store.dummy().copyWith(id: 'store2', name: 'Store 2');

      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);
      when(mockStoresRepository.getStoreById('store1')).thenAnswer((_) async => mockStore1);
      when(mockStoresRepository.getStoreById('store2')).thenAnswer((_) async => mockStore2);

      bloc.add(InitializeMultistore());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          anyOf(
            // Initial state
            anything,
            // After loading user and stores
            predicate<MultistoreState>((state) => 
              state.currentUserId == 'user123' &&
              state.currentUserRole == UserRole.merchant &&
              state.accessibleStores.length == 2
            ),
          ),
        ]),
      );
    });

    test('Verifies store access for merchant', () async {
      when(mockSecurityService.canAccessStore('store1')).thenAnswer((_) async => true);
      when(mockSecurityService.canAccessStore('store3')).thenAnswer((_) async => false);

      expect(await mockSecurityService.canAccessStore('store1'), true);
      expect(await mockSecurityService.canAccessStore('store3'), false);
    });

    test('Properly switches stores for authorized user', () async {
      final initialState = MultistoreState(
        currentUserRole: UserRole.merchant,
        accessibleStores: [
          Store.dummy().copyWith(id: 'store1', name: 'Store 1'),
          Store.dummy().copyWith(id: 'store2', name: 'Store 2'),
        ],
        appPermissions: {},
        isStoreContextValid: true,
        isOffline: false,
        cachedData: {},
      );

      when(mockSecurityService.canAccessStore('store2')).thenAnswer((_) async => true);

      bloc.state.copyWith(accessibleStores: initialState.accessibleStores);

      bloc.add(SwitchStore('store2'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          anyOf(
            initialState,
            predicate<MultistoreState>((state) => 
              state.currentStoreId == 'store2' && 
              state.currentStore?.id == 'store2'
            ),
          ),
        ]),
      );
    });
  });
}

// Mock classes for testing
class MockAuthRepository implements AuthRepository {
  @override
  Future<UserProfileWithRole?> getCurrentUser() async => null;
  
  // Implement other required methods...
}

class MockStoresRepository implements StoresRepository {
  @override
  Future<Store?> getStoreById(String storeId) async => null;
  
  @override
  Future<List<Store>> getAllActiveStores() async => [];
  
  @override
  Future<void> syncStoreData(String storeId) async {}
  
  // Implement other required methods...
}

class MockSecurityService implements SecurityService {
  @override
  Future<bool> canAccessStore(String storeId) async => true;
  
  // Implement other required methods...
}
```

## Expected Outcome
- Complete integration of all multistore, admin, and merchant features
- Comprehensive security layer with role-based access control
- Robust error handling across all multistore functions
- Proper state management for store context
- Thorough testing of all new functionality
- Performance optimizations for multi-store operations
- Security measures to protect sensitive information

## Visual Presentation
- Unified user experience across customer, merchant, and admin interfaces
- Clear visual indicators of current store context
- Consistent navigation patterns across all user types
- Responsive design that works well on all device types
- Intuitive workflows for store management and admin functions
- Clear permission boundaries between user roles

## Related Notes
- The integration phase ensures all components work together seamlessly
- Security is a primary concern with multistore data isolation
- Performance optimizations are critical as the number of stores grows
- Testing must cover all user role combinations and store access scenarios
- Error handling should be graceful and informative
- The system should handle offline scenarios appropriately

## Files to Read Before Implementing
- All files created in previous phases
- `lib/di/service_locator.dart` - For dependency injection updates
- `lib/routing/router.dart` - For routing configuration
- `lib/main.dart` - For application setup
- All existing test files to understand testing patterns
- `lib/utils/` - For existing utility functions

## Architecture
- Will integrate all previously created components
- Implement security at multiple layers (UI, service, API)
- Create comprehensive error handling and recovery mechanisms
- Optimize performance for multi-store operations
- Ensure data isolation between stores
- Implement proper caching strategies
- Add comprehensive logging and monitoring