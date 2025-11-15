import 'package:get_it/get_it.dart';
import '../models/store/store_model.dart';
import '../services/stores_api_service.dart';

class StoresRepository {
  final StoresApiService _storesApiService = GetIt.instance<StoresApiService>();

  Future<Store> createStore({
    required String name,
    required String address,
    required String city,
    required String state,
    required String country,
    required String postalCode,
    List<String>? merchantIds,
  }) async {
    return _storesApiService.createStore(
      name: name,
      address: address,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      merchantIds: merchantIds,
    );
  }

  // Add other store-related methods as needed
}