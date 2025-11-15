import 'package:get_it/get_it.dart';
import '../models/store/store_model.dart';
import '../utils/networking_manager.dart';

class StoresApiService {
  final NetworkingManager _networkingManager = GetIt.instance<NetworkingManager>();

  Future<Store> createStore({
    required String name,
    required String address,
    required String city,
    required String state,
    required String country,
    required String postalCode,
    List<String>? merchantIds,
  }) async {
    try {
      final body = {
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        if (merchantIds != null) 'merchantIds': merchantIds,
      };
      
      final response = await _networkingManager.post(
        endpoint: 'api/stores', // This endpoint requires admin rights according to API docs
        body: body,
        addAuthToken: true,
      );
      return Store.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create store: $e');
    }
  }

  // Add other store-related methods as needed
}