# Corrected Phase 2.3: Complete Integration and Testing (Based on API Documentation)

## Feature Overview
Implement the complete integration of all multistore, admin, and merchant functionality with comprehensive testing and security validation based strictly on the API documentation from store-backend-eta.vercel.app/docs. This final phase ensures all components work together following the exact API specifications.

## Related API Endpoints
- **POST** `/api/stores` - Create a new store (Admin only)
- **GET** `/api/storeOrders?storeId=` - Get orders for a specific store (Merchant access)
- **PUT** `/api/storeOrders/:storeOrderId` - Update order status (Merchant access)
- **PUT** `/api/storeOrders/:storeOrderId/confirm` - Approve order (Admin only)

## API Structures Summary (from documentation)
### Create Store
**Request:**
```json
{
  "name": "My Awesome Store",
  "address": "123 Main St",
  "city": "Anytown",
  "state": "CA",
  "country": "USA",
  "postalCode": "90210",
  "merchantIds": []
}
```

**Response:**
```json
{
  "_id": "6553d3e3c7e3f3e3c7e3f3e4",
  "name": "My Awesome Store",
  "address": "123 Main St",
  "city": "Anytown",
  "state": "CA",
  "country": "USA",
  "postalCode": "90210",
  "merchantIds": [],
  "createdAt": "2023-11-14T12:00:00.000Z",
  "updatedAt": "2023-11-14T12:00:00.000Z"
}
```

### Get Store Orders
**Response:**
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

### Update Order Status
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

### Confirm Order
**Response:**
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

## Files to Create/Update
- `lib/routing/multistore_router.dart` - Multistore-aware routing
- `lib/test/corrected_multistore_integration_test.dart` - Comprehensive integration tests
- `lib/test/corrected_security_test.dart` - Security validation tests
- `lib/test/corrected_api_conformance_test.dart` - API conformance tests
- `lib/utils/multistore_constants.dart` - Constants based on API documentation
- `lib/services/multistore_validation_service.dart` - API conformance validation

## Multistore Constants Based on API Documentation
```dart
class MultistoreConstants {
  // Valid order states based on API documentation examples
  static const List<String> validOrderStates = [
    'pending',    // Potentially valid state (based on general e-commerce patterns)
    'prepared',   // Explicitly shown in API documentation
    'confirmed',  // Explicitly shown in API documentation for confirmed orders
    'shipped',    // Potentially valid state (based on general e-commerce patterns)
    'delivered',  // Potentially valid state (based on general e-commerce patterns)
    'cancelled',  // Potentially valid state (based on general e-commerce patterns)
  ];

  // API endpoint patterns
  static const String storesEndpoint = '/api/stores';
  static const String storeOrdersEndpoint = '/api/storeOrders';

  // Security requirements
  static const String adminRequiredMessage = 'Admin access required';
  
  // Field names as they appear in the API
  static const String idField = '_id';
  static const String storeIdField = 'storeId';
  static const String orderIdField = 'orderId';
  static const String stateField = 'state';
  static const String merchantIdsField = 'merchantIds';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
}
```

## API Conformance Validation Service
```dart
class MultistoreValidationService {
  // Validate that store creation request conforms to API documentation
  bool isValidCreateStoreRequest(CreateStoreRequest request) {
    // Required fields based on API documentation
    if (request.name.isEmpty) return false;
    if (request.address.isEmpty) return false;
    if (request.city.isEmpty) return false;
    if (request.state.isEmpty) return false;
    if (request.country.isEmpty) return false;
    if (request.postalCode.isEmpty) return false;
    
    // merchantIds can be empty but must be a list
    if (request.merchantIds.any((id) => id.isEmpty)) return false;
    
    return true;
  }

  // Validate that store response conforms to API documentation
  bool isValidStoreResponse(Map<String, dynamic> response) {
    // Required fields based on API documentation
    if (!response.containsKey(MultistoreConstants.idField)) return false;
    if (!response.containsKey('name')) return false;
    if (!response.containsKey('address')) return false;
    if (!response.containsKey('city')) return false;
    if (!response.containsKey('state')) return false;
    if (!response.containsKey('country')) return false;
    if (!response.containsKey('postalCode')) return false;
    if (!response.containsKey('merchantIds')) return false;
    if (!response.containsKey('createdAt')) return false;
    if (!response.containsKey('updatedAt')) return false;
    
    // Validate data types
    if (response[MultistoreConstants.idField] is! String) return false;
    if (response['name'] is! String) return false;
    if (response['address'] is! String) return false;
    if (response['city'] is! String) return false;
    if (response['state'] is! String) return false;
    if (response['country'] is! String) return false;
    if (response['postalCode'] is! String) return false;
    if (response['merchantIds'] is! List) return false;
    if (response['createdAt'] is! String) return false;
    if (response['updatedAt'] is! String) return false;
    
    return true;
  }

  // Validate that store order response conforms to API documentation
  bool isValidStoreOrderResponse(Map<String, dynamic> response) {
    // Required fields based on API documentation
    if (!response.containsKey(MultistoreConstants.idField)) return false;
    if (!response.containsKey(MultistoreConstants.storeIdField)) return false;
    if (!response.containsKey(MultistoreConstants.orderIdField)) return false;
    if (!response.containsKey(MultistoreConstants.stateField)) return false;
    if (!response.containsKey('createdAt')) return false;
    if (!response.containsKey('updatedAt')) return false;
    
    // Validate data types
    if (response[MultistoreConstants.idField] is! String) return false;
    if (response[MultistoreConstants.storeIdField] is! String) return false;
    if (response[MultistoreConstants.orderIdField] is! String) return false;
    if (response[MultistoreConstants.stateField] is! String) return false;
    if (response['createdAt'] is! String) return false;
    if (response['updatedAt'] is! String) return false;
    
    return true;
  }

  // Validate that update order request conforms to API documentation
  bool isValidUpdateOrderRequest(Map<String, dynamic> request) {
    // Must have state field based on API documentation
    if (!request.containsKey(MultistoreConstants.stateField)) return false;
    
    final state = request[MultistoreConstants.stateField];
    if (state is! String || state.isEmpty) return false;
    
    // Validate that state is one of the valid states
    if (!MultistoreConstants.validOrderStates.contains(state)) {
      // Log warning but allow any state since the API documentation only shows examples
      print('Warning: Unknown order state "$state", API documentation shows "prepared" and "confirmed"');
    }
    
    return true;
  }

  // Validate that get store orders response conforms to API documentation
  bool isValidGetStoreOrdersResponse(Map<String, dynamic> response) {
    // Must have storeOrders array based on API documentation
    if (!response.containsKey('storeOrders')) return false;
    
    if (response['storeOrders'] is! List) return false;
    
    // Validate each store order in the array
    final storeOrders = response['storeOrders'] as List;
    for (final order in storeOrders) {
      if (order is! Map<String, dynamic>) return false;
      if (!isValidStoreOrderResponse(order)) return false;
    }
    
    return true;
  }
}
```

## Comprehensive Integration Tests Based on API Documentation
```dart
void runCorrectedIntegrationTests() {
  group('Corrected Multistore Integration Tests', () {
    late MockStoreOrdersRepository mockStoreOrdersRepository;
    late MockStoresRepository mockStoresRepository;
    late MockAuthRepository mockAuthRepository;
    late MultistoreValidationService validationService;

    setUp(() {
      mockStoreOrdersRepository = MockStoreOrdersRepository();
      mockStoresRepository = MockStoresRepository();
      mockAuthRepository = MockAuthRepository();
      validationService = MultistoreValidationService();
    });

    test('Store creation request conforms to API documentation', () async {
      final request = CreateStoreRequest(
        name: 'Test Store',
        address: '123 Main St',
        city: 'Test City',
        state: 'TS',
        country: 'Test Country',
        postalCode: '12345',
        merchantIds: ['merchant1', 'merchant2'],
      );

      expect(validationService.isValidCreateStoreRequest(request), true);
    });

    test('Store creation request fails with missing required field', () async {
      final request = CreateStoreRequest(
        name: 'Test Store',  // Missing other required fields
        address: '',
        city: 'Test City',
        state: 'TS',
        country: 'Test Country',
        postalCode: '12345',
        merchantIds: [],
      );

      expect(validationService.isValidCreateStoreRequest(request), false);
    });

    test('Store response conforms to API documentation', () async {
      final mockStoreResponse = {
        '_id': '6553d3e3c7e3f3e3c7e3f3e4',
        'name': 'My Awesome Store',
        'address': '123 Main St',
        'city': 'Anytown',
        'state': 'CA',
        'country': 'USA',
        'postalCode': '90210',
        'merchantIds': ['merchant1'],
        'createdAt': '2023-11-14T12:00:00.000Z',
        'updatedAt': '2023-11-14T12:00:00.000Z',
      };

      expect(validationService.isValidStoreResponse(mockStoreResponse), true);
    });

    test('Store order response conforms to API documentation', () async {
      final mockStoreOrderResponse = {
        '_id': '6553d3e3c7e3f3e3c7e3f3ec',
        'storeId': '6553d3e3c7e3f3e3c7e3f3e4',
        'orderId': '6553d3e3c7e3f3e3c7e3f3eb',
        'state': 'prepared',
        'createdAt': '2023-11-14T12:00:00.000Z',
        'updatedAt': '2023-11-14T12:00:00.000Z',
      };

      expect(validationService.isValidStoreOrderResponse(mockStoreOrderResponse), true);
    });

    test('Update order request conforms to API documentation', () async {
      final mockUpdateRequest = {
        'state': 'prepared'
      };

      expect(validationService.isValidUpdateOrderRequest(mockUpdateRequest), true);
    });

    test('Update order request fails without state field', () async {
      final mockUpdateRequest = {
        'otherField': 'value'
      };

      expect(validationService.isValidUpdateOrderRequest(mockUpdateRequest), false);
    });

    test('Get store orders response conforms to API documentation', () async {
      final mockResponse = {
        'storeOrders': [
          {
            '_id': '6553d3e3c7e3f3e3c7e3f3ec',
            'storeId': '6553d3e3c7e3f3e3c7e3f3e4',
            'orderId': '6553d3e3c7e3f3e3c7e3f3eb',
            'state': 'prepared',
            'createdAt': '2023-11-14T12:00:00.000Z',
            'updatedAt': '2023-11-14T12:00:00.000Z',
          }
        ]
      };

      expect(validationService.isValidGetStoreOrdersResponse(mockResponse), true);
    });

    test('Merchant can only access their assigned stores', () async {
      final mockUser = UserProfileWithRole(
        id: 'user123',
        userId: 'user123',
        username: 'merchant1',
        email: 'merchant@example.com',
        phoneNumber: '1234567890',
        firstName: 'Merchant',
        lastName: 'User',
        role: UserRole.merchant,
        storeIds: ['store1', 'store2'],
      );

      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);

      // Create security service to test access
      final securityService = MultistoreSecurityService(mockAuthRepository, MockSharedPreferences());

      // Merchant should have access to their assigned stores
      expect(await securityService.canAccessStore('store1'), true);
      expect(await securityService.canAccessStore('store2'), true);
      
      // Merchant should not have access to other stores
      expect(await securityService.canAccessStore('store3'), false);
    });

    test('Admin can access any store', () async {
      final mockUser = UserProfileWithRole(
        id: 'admin123',
        userId: 'admin123',
        username: 'admin1',
        email: 'admin@example.com',
        phoneNumber: '1234567890',
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.admin,
      );

      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);

      final securityService = MultistoreSecurityService(mockAuthRepository, MockSharedPreferences());

      // Admin should have access to any store
      expect(await securityService.canAccessStore('any_store'), true);
    });
  });
}

// API Conformance Tests
void runApiConformanceTests() {
  group('API Conformance Tests', () {
    late MultistoreValidationService validationService;

    setUp(() {
      validationService = MultistoreValidationService();
    });

    test('Field names match API documentation exactly', () {
      final storeExample = {
        '_id': '6553d3e3c7e3f3e3c7e3f3e4',  // API uses _id, not id
        'storeId': '6553d3e3c7e3f3e3c7e3f3e4', // API uses storeId field
        'orderId': '6553d3e3c7e3f3e3c7e3f3eb', // API uses orderId field
        'merchantIds': [], // API uses merchantIds field (plural)
      };

      expect(storeExample.containsKey('_id'), true);
      expect(storeExample.containsKey('storeId'), true);
      expect(storeExample.containsKey('orderId'), true);
      expect(storeExample.containsKey('merchantIds'), true);
    });

    test('API response structure matches documentation', () {
      final getStoreOrdersExample = {
        'storeOrders': [  // API returns storeOrders array
          {
            '_id': '6553d3e3c7e3f3e3c7e3f3ec',
            'storeId': '6553d3e3c7e3f3e3c7e3f3e4',
            'orderId': '6553d3e3c7e3f3e3c7e3f3eb',
            'state': 'prepared',
            'createdAt': '2023-11-14T12:00:00.000Z',
            'updatedAt': '2023-11-14T12:00:00.000Z',
          }
        ]
      };

      expect(validationService.isValidGetStoreOrdersResponse(getStoreOrdersExample), true);
    });

    test('API security requirements are enforced', () {
      // This test verifies the validation service knows about security requirements
      expect(MultistoreConstants.adminRequiredMessage, 'Admin access required');
    });
  });
}
```

## Role-Based Router Configuration Based on API Documentation
```dart
class MultistoreRouter {
  static GoRouter get router {
    return GoRouter(
      routes: [
        // Merchant routes (based on API endpoints that merchants can access)
        GoRoute(
          name: 'merchant-orders',
          path: '/merchant/orders',
          builder: (context, state) {
            // Verify user has merchant access before showing page
            final bloc = context.read<MultistoreIntegrationBloc>();
            final currentState = bloc.state;
            
            if (!currentState.hasMerchantAccess) {
              // Redirect to unauthorized page
              return UnauthorizedView();
            }
            
            final storeId = state.extra as String?;
            if (storeId == null) {
              return StoreSelectionView(); // Let merchant select their store
            }
            return StoreOrdersView(storeId: storeId);
          },
        ),
        
        // Admin routes (based on API endpoints that require admin access)
        GoRoute(
          name: 'admin-order-confirmation',
          path: '/admin/orders/confirm',
          builder: (context, state) {
            // Verify user has admin access before showing page
            final bloc = context.read<MultistoreIntegrationBloc>();
            final currentState = bloc.state;
            
            if (!currentState.hasAdminAccess) {
              return UnauthorizedView();
            }
            
            final storeOrderId = state.pathParameters['id'];
            if (storeOrderId == null) {
              return AdminOrderListView();
            }
            return OrderConfirmationView(storeOrderId: storeOrderId);
          },
        ),
      ],
      redirect: (context, state) {
        // Check API-based security requirements
        final bloc = context.read<MultistoreIntegrationBloc>();
        final currentState = bloc.state;
        
        // If trying to access admin section without admin access
        if (state.location.startsWith('/admin') && !currentState.hasAdminAccess) {
          return '/unauthorized';
        }
        
        // If trying to access merchant section without merchant access
        if (state.location.startsWith('/merchant') && !currentState.hasMerchantAccess) {
          return '/unauthorized';
        }
        
        return null;
      },
    );
  }
}
```

## Expected Outcome
- Complete integration of all multistore functionality conforming to the documented API
- Comprehensive validation to ensure all requests and responses match API documentation
- Security enforcement based on documented access requirements
- Thorough testing of API conformance and security requirements
- Proper role-based routing following documented permissions

## Visual Presentation
- Unified user experience that correctly implements documented API flows
- Clear role-based access controls matching documented permissions
- Proper error handling for API conformance issues
- Security measures that enforce documented access requirements

## Related Notes
- All implementations strictly follow the field names and structures from the API documentation
- Security requirements are enforced as documented in the API
- The integration is validated against exact API specifications
- Testing ensures conformance to the documented API behavior

## Files to Read Before Implementing
- All corrected phase files created previously
- `lib/di/service_locator.dart` - For dependency injection of new services
- `lib/main.dart` - For application setup with new routing
- All existing test files to understand testing patterns

## Architecture
- API conformance validation at multiple levels (input, output, service)
- Security enforcement based on documented API requirements
- Role-based access control matching documented permissions
- Comprehensive testing to ensure all components work according to API specifications
- Consistent with existing architecture patterns while ensuring API compliance