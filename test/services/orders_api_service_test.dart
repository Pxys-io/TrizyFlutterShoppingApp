import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trizy_app/services/orders_api_service.dart';
import 'package:trizy_app/utils/networking_manager.dart';
import 'package:trizy_app/models/order/store_order.dart';

import 'orders_api_service_test.mocks.dart';

@GenerateMocks([NetworkingManager])
void main() {
  late OrdersApiService ordersApiService;
  late MockNetworkingManager mockNetworkingManager;

  setUp(() {
    mockNetworkingManager = MockNetworkingManager();
    // Ensure GetIt is reset before each test to avoid state leakage
    if (GetIt.instance.isRegistered<NetworkingManager>()) {
      GetIt.instance.unregister<NetworkingManager>();
    }
    GetIt.instance.registerSingleton<NetworkingManager>(mockNetworkingManager);
    ordersApiService = OrdersApiService();
  });

  tearDown(() {
    GetIt.instance.unregister<NetworkingManager>();
  });

  group('OrdersApiService', () {
    test('getStoreOrders returns a list of StoreOrder when response is a Map with "data" key', () async {
      // Arrange
      final mockResponse = {
        'data': [
          {'id': '1', 'storeId': 's1', 'productId': 'p1', 'quantity': 1, 'price': 10.0, 'state': 'pending'},
          {'id': '2', 'storeId': 's1', 'productId': 'p2', 'quantity': 2, 'price': 20.0, 'state': 'confirmed'},
        ]
      };

      when(mockNetworkingManager.get(
        endpoint: anyNamed('endpoint'),
        queryParams: anyNamed('queryParams'),
        urlParams: anyNamed('urlParams'),
        addAuthToken: anyNamed('addAuthToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await ordersApiService.getStoreOrders(storeId: 's1');

      // Assert
      expect(result, isA<List<StoreOrder>>());
      expect(result.length, 2);
      expect(result[0].id, '1');
      expect(result[1].id, '2');
      verify(mockNetworkingManager.get(
        endpoint: 'api/storeOrders?storeId=s1',
        addAuthToken: true,
      )).called(1);
    });

    test('getStoreOrders returns a list of StoreOrder when response is a Map with "orders" key', () async {
      // Arrange
      final mockResponse = {
        'orders': [
          {'id': '3', 'storeId': 's2', 'productId': 'p3', 'quantity': 1, 'price': 15.0, 'state': 'pending'},
        ]
      };

      when(mockNetworkingManager.get(
        endpoint: anyNamed('endpoint'),
        queryParams: anyNamed('queryParams'),
        urlParams: anyNamed('urlParams'),
        addAuthToken: anyNamed('addAuthToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act
      final result = await ordersApiService.getStoreOrders(storeId: 's2');

      // Assert
      expect(result, isA<List<StoreOrder>>());
      expect(result.length, 1);
      expect(result[0].id, '3');
      verify(mockNetworkingManager.get(
        endpoint: 'api/storeOrders?storeId=s2',
        addAuthToken: true,
      )).called(1);
    });

    test('getStoreOrders returns a list of StoreOrder when response is a List', () async {
      // Arrange
      final mockResponse = [
        {'id': '4', 'storeId': 's3', 'productId': 'p4', 'quantity': 1, 'price': 25.0, 'state': 'delivered'},
      ];


      // Act
      final result = await ordersApiService.getStoreOrders(storeId: 's3');

      // Assert
      expect(result, isA<List<StoreOrder>>());
      expect(result.length, 1);
      expect(result[0].id, '4');
      verify(mockNetworkingManager.get(
        endpoint: 'api/storeOrders?storeId=s3',
        addAuthToken: true,
      )).called(1);
    });

    test('getStoreOrders throws exception for unexpected response format', () async {
      // Arrange
      final mockResponse = {'unexpectedKey': 'someValue'};

      when(mockNetworkingManager.get(
        endpoint: anyNamed('endpoint'),
        queryParams: anyNamed('queryParams'),
        urlParams: anyNamed('urlParams'),
        addAuthToken: anyNamed('addAuthToken'),
      )).thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(
            () => ordersApiService.getStoreOrders(storeId: 's4'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Unexpected response format'))),
      );
    });
  });
}