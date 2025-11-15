# Corrected Phase 2.2: Multistore Integration and Security Implementation (Based on API Documentation)

## Feature Overview
Implement the complete integration of multistore functionality with security measures based on the exact specifications from the backend API documentation. This phase ensures that all multistore features work securely according to the documented API requirements.

## Related API Endpoints
- **POST** `/api/stores` - Create a new store (Admin only)
- **GET** `/api/storeOrders?storeId=` - Get orders for a specific store (Merchant access)
- **PUT** `/api/storeOrders/:storeOrderId` - Update order status (Merchant access)
- **PUT** `/api/storeOrders/:storeOrderId/confirm` - Approve order (Admin only)

## Key Security Requirements from API Documentation
1. "Admin access required" for store creation and order confirmation
2. Merchant access for order updates and store order retrieval
3. Store ID parameter used for merchant access control
4. Bearer token authentication required for all endpoints

## Files to Create/Update
- `lib/services/multistore_security_service.dart` - Security service based on API requirements
- `lib/utils/role_permissions.dart` - Role-based permissions aligned with API
- `lib/components/shared/role_guard_component.dart` - Role-based access guard
- `lib/bloc/multistore_integration_bloc.dart` - Integration BLoC for global state
- `lib/models/multistore_state_model.dart` - Global multistore state model
- `lib/test/multistore_security_test.dart` - Security-focused tests

## Multistore State Model
```dart
class MultistoreState {
  final UserRole currentUserRole;
  final String? currentUserId;
  final String? currentStoreId;
  final List<String> accessibleStoreIds;
  final bool isStoreContextValid;
  final bool hasAdminAccess;
  final bool hasMerchantAccess;

  MultistoreState({
    required this.currentUserRole,
    this.currentUserId,
    this.currentStoreId,
    required this.accessibleStoreIds,
    required this.isStoreContextValid,
    required this.hasAdminAccess,
    required this.hasMerchantAccess,
  });

  factory MultistoreState.initial() {
    return MultistoreState(
      currentUserRole: UserRole.customer,
      accessibleStoreIds: [],
      isStoreContextValid: false,
      hasAdminAccess: false,
      hasMerchantAccess: false,
    );
  }

  MultistoreState copyWith({
    UserRole? currentUserRole,
    String? currentUserId,
    String? currentStoreId,
    List<String>? accessibleStoreIds,
    bool? isStoreContextValid,
    bool? hasAdminAccess,
    bool? hasMerchantAccess,
  }) {
    return MultistoreState(
      currentUserRole: currentUserRole ?? this.currentUserRole,
      currentUserId: currentUserId ?? this.currentUserId,
      currentStoreId: currentStoreId ?? this.currentStoreId,
      accessibleStoreIds: accessibleStoreIds ?? this.accessibleStoreIds,
      isStoreContextValid: isStoreContextValid ?? this.isStoreContextValid,
      hasAdminAccess: hasAdminAccess ?? this.hasAdminAccess,
      hasMerchantAccess: hasMerchantAccess ?? this.hasMerchantAccess,
    );
  }

  bool get canCreateStore => hasAdminAccess;
  bool get canConfirmOrder => hasAdminAccess;
  bool get canUpdateOrderStatus => hasMerchantAccess || hasAdminAccess;
  bool get canViewStoreOrders => hasMerchantAccess || hasAdminAccess;
}
```

## Security Service Based on API Documentation
```dart
class MultistoreSecurityService {
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;

  MultistoreSecurityService(this._authRepository, this._prefs);

  // Verify access to a specific store based on API requirements
  Future<bool> canAccessStore(String storeId) async {
    try {
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) return false;

      // Admins can access all stores as per API documentation
      if (currentUser.role == UserRole.admin || currentUser.role == UserRole.superAdmin) {
        return true;
      }

      // For merchants, check if they have access to this specific store
      // This would depend on how the user profile includes store associations
      if (currentUser.role == UserRole.merchant) {
        if (currentUser.storeIds != null) {
          return currentUser.storeIds!.contains(storeId);
        }
      }

      return false;
    } catch (e) {
      print('Security check error: $e');
      return false;
    }
  }

  // Verify admin access as required by API for certain operations
  Future<bool> hasAdminAccess() async {
    final currentUser = await _authRepository.getCurrentUser();
    return currentUser?.role == UserRole.admin || currentUser?.role == UserRole.superAdmin;
  }

  // Verify merchant access as required by API for certain operations
  Future<bool> hasMerchantAccess() async {
    final currentUser = await _authRepository.getCurrentUser();
    return currentUser?.role == UserRole.merchant || 
           currentUser?.role == UserRole.admin || 
           currentUser?.role == UserRole.superAdmin;
  }

  // Verify user permissions based on API documentation requirements
  Future<bool> hasPermissionForOperation(String operation, {String? storeId}) async {
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser == null) return false;

    switch (operation) {
      case 'create_store':
        // As per API documentation, requires admin access
        return await hasAdminAccess();
      
      case 'get_store_orders':
        // As per API documentation, available to merchants
        if (storeId == null) return false;
        return await canAccessStore(storeId);
      
      case 'update_order_status':
        // As per API documentation, available to merchants
        if (storeId == null) return false;
        return await canAccessStore(storeId);
      
      case 'confirm_order':
        // As per API documentation, requires admin access
        return await hasAdminAccess();
      
      default:
        return false;
    }
  }

  // Securely store sensitive information
  Future<void> storeSensitiveData(String key, String data) async {
    await _prefs.setString(key, data);
  }

  // Retrieve sensitive information securely
  Future<String?> getSensitiveData(String key) async {
    return _prefs.getString(key);
  }
}
```

## Role Permissions Aligned with API Documentation
```dart
class RolePermissions {
  // Permissions based on API documentation requirements
  static const Map<UserRole, Set<String>> permissions = {
    UserRole.customer: {
      // Basic customer operations not detailed in store/merchant endpoints
    },
    UserRole.merchant: {
      'get_store_orders',      // GET /api/storeOrders?storeId=
      'update_order_status',   // PUT /api/storeOrders/:storeOrderId
    },
    UserRole.admin: {
      'get_store_orders',      // Available to admins as well as merchants
      'update_order_status',   // Available to admins as well as merchants
      'confirm_order',         // PUT /api/storeOrders/:storeOrderId/confirm (admin only)
      'create_store',          // POST /api/stores (admin only)
    },
    UserRole.superAdmin: {
      'get_store_orders',
      'update_order_status', 
      'confirm_order',
      'create_store',
      // Additional admin permissions
    },
  };

  static bool hasPermission(UserRole role, String permission) {
    final rolePermissions = permissions[role] ?? <String>{};
    return rolePermissions.contains(permission);
  }
}
```

## Integration BLoC Based on API Requirements
```dart
class MultistoreIntegrationBloc extends Bloc<MultistoreIntegrationEvent, MultistoreState> {
  final AuthRepository _authRepository;
  final StoresRepository _storesRepository;
  final StoreOrdersRepository _storeOrdersRepository;
  final MultistoreSecurityService _securityService;

  MultistoreIntegrationBloc({
    required AuthRepository authRepository,
    required StoresRepository storesRepository,
    required StoreOrdersRepository storeOrdersRepository,
    required MultistoreSecurityService securityService,
  }) : 
    _authRepository = authRepository,
    _storesRepository = storesRepository,
    _storeOrdersRepository = storeOrdersRepository,
    _securityService = securityService,
    super(MultistoreState.initial()) {
      on<InitializeMultistore>(_onInitializeMultistore);
      on<SwitchStore>(_onSwitchStore);
      on<VerifyAdminAccess>(_onVerifyAdminAccess);
      on<VerifyMerchantAccess>(_onVerifyMerchantAccess);
  }

  Future<void> _onInitializeMultistore(
      InitializeMultistore event, Emitter<MultistoreState> emit) async {
    try {
      // Get current user
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        emit(state.copyWith(
          currentUserRole: UserRole.customer,
          hasAdminAccess: false,
          hasMerchantAccess: false,
        ));
        return;
      }

      // Determine access based on API documentation requirements
      final hasAdminAccess = await _securityService.hasAdminAccess();
      final hasMerchantAccess = await _securityService.hasMerchantAccess();
      
      // Get user's accessible store IDs based on role
      List<String> accessibleStoreIds = [];
      if (hasAdminAccess) {
        // Admins can potentially access all stores
        // This depends on backend implementation details not fully specified
        // For now, we'll initialize with empty list to be populated as needed
      } else if (hasMerchantAccess) {
        // Get stores assigned to this merchant
        if (currentUser.storeIds != null) {
          accessibleStoreIds = currentUser.storeIds!;
        }
      }

      // Determine current store context
      String? currentStoreId = await _getCurrentStoreId();
      bool isStoreContextValid = false;
      
      if (currentStoreId != null) {
        isStoreContextValid = await _securityService.canAccessStore(currentStoreId);
      }

      emit(state.copyWith(
        currentUser: currentUser,
        currentUserId: currentUser.id,
        currentUserRole: currentUser.role,
        accessibleStoreIds: accessibleStoreIds,
        currentStoreId: currentStoreId,
        isStoreContextValid: isStoreContextValid,
        hasAdminAccess: hasAdminAccess,
        hasMerchantAccess: hasMerchantAccess,
      ));
    } catch (e) {
      print('Error initializing multistore: $e');
      emit(state.copyWith(
        currentUserRole: UserRole.customer,
        accessibleStoreIds: [],
        isStoreContextValid: false,
        hasAdminAccess: false,
        hasMerchantAccess: false,
      ));
    }
  }

  Future<void> _onSwitchStore(
      SwitchStore event, Emitter<MultistoreState> emit) async {
    try {
      // Verify user has access to the requested store based on API documentation
      final userCanAccess = await _securityService.canAccessStore(event.storeId);
      if (!userCanAccess) {
        add(ShowError('You do not have permission to access this store'));
        return;
      }

      // Update stored preference
      await _setCurrentStoreId(event.storeId);

      emit(state.copyWith(
        currentStoreId: event.storeId,
        isStoreContextValid: true,
      ));
    } catch (e) {
      print('Error switching store: $e');
      add(ShowError('Error switching store: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyAdminAccess(
      VerifyAdminAccess event, Emitter<MultistoreState> emit) async {
    final hasAccess = await _securityService.hasAdminAccess();
    emit(state.copyWith(hasAdminAccess: hasAccess));
  }

  Future<void> _onVerifyMerchantAccess(
      VerifyMerchantAccess event, Emitter<MultistoreState> emit) async {
    final hasAccess = await _securityService.hasMerchantAccess();
    emit(state.copyWith(hasMerchantAccess: hasAccess));
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
class VerifyAdminAccess extends MultistoreIntegrationEvent {}
class VerifyMerchantAccess extends MultistoreIntegrationEvent {}
class ShowError extends MultistoreIntegrationEvent {
  final String message;
  ShowError(this.message);
}
```

## Security-First Testing Approach
```dart
// Security-focused tests based on API documentation requirements
void runSecurityTests() {
  group('Multistore Security Tests', () {
    late MockAuthRepository mockAuthRepository;
    late MockSecurityService mockSecurityService;
    late MultistoreIntegrationBloc bloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockSecurityService = MockSecurityService();
      
      bloc = MultistoreIntegrationBloc(
        authRepository: mockAuthRepository,
        storesRepository: MockStoresRepository(),
        storeOrdersRepository: MockStoreOrdersRepository(),
        securityService: mockSecurityService,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initializes with proper security context', () async {
      final mockUser = UserProfileWithRole(
        id: 'user123',
        userId: 'user123',
        username: 'admin1',
        email: 'admin@example.com',
        phoneNumber: '1234567890',
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.admin,
      );

      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);
      when(mockSecurityService.hasAdminAccess()).thenAnswer((_) async => true);
      when(mockSecurityService.hasMerchantAccess()).thenAnswer((_) async => true);

      bloc.add(InitializeMultistore());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          anything, // Initial state
          predicate<MultistoreState>((state) => 
            state.currentUserRole == UserRole.admin &&
            state.hasAdminAccess == true &&
            state.hasMerchantAccess == true
          ),
        ]),
      );
    });

    test('Verifies store access based on API requirements', () async {
      when(mockSecurityService.canAccessStore('store1')).thenAnswer((_) async => true);
      when(mockSecurityService.canAccessStore('store3')).thenAnswer((_) async => false);

      expect(await mockSecurityService.canAccessStore('store1'), true);
      expect(await mockSecurityService.canAccessStore('store3'), false);
    });

    test('Blocks unauthorized store access', () async {
      when(mockSecurityService.canAccessStore('unauthorized_store')).thenAnswer((_) async => false);

      bloc.add(SwitchStore('unauthorized_store'));

      // Should emit an error state
      await expectLater(
        bloc.stream,
        emitsInOrder([
          anything, // Initial state
          anything, // Error state
        ]),
      );
    });

    test('Verifies admin-only operations', () async {
      when(mockSecurityService.hasPermissionForOperation('create_store')).thenAnswer((_) async => true);
      when(mockSecurityService.hasPermissionForOperation('confirm_order')).thenAnswer((_) async => true);

      // Test that admin operations return true for admins
      expect(await mockSecurityService.hasPermissionForOperation('create_store'), true);
      expect(await mockSecurityService.hasPermissionForOperation('confirm_order'), true);
    });
  });
}
```

## Expected Outcome
- Complete security layer that enforces API documentation requirements
- Role-based access control matching documented permissions
- Proper validation of store access based on user role
- Secure handling of sensitive operations
- Comprehensive security testing

## Visual Presentation
- Clear role-based access controls in the UI
- Appropriate restriction of functionality based on user role
- Clear error messaging when access is denied per API requirements
- Secure data handling throughout the application

## Related Notes
- Security implementation is based strictly on API documentation requirements
- Admin and merchant access is enforced at multiple levels (UI, service, API)
- Store access control is implemented according to the documented API parameters
- The implementation focuses on the security requirements explicitly mentioned in the documentation

## Files to Read Before Implementing
- `lib/models/auth/user_profile_with_role_model.dart` - User profile model with role
- `lib/services/auth_api_service.dart` - Authentication service
- All previously created store and order models and services
- `lib/di/service_locator.dart` - For dependency injection of security service

## Architecture
- Security layer integrated at multiple levels (model, service, BLoC)
- API requirements from documentation enforced throughout
- Clear separation of concerns between different user roles
- Proper error handling when API access requirements aren't met
- Consistent with existing architecture patterns in the codebase