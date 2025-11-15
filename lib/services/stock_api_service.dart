import 'package:get_it/get_it.dart';
import '../models/stock/stock_model.dart';
import '../utils/api_endpoints.dart';
import '../utils/networking_manager.dart';

class StockApiService {
  final NetworkingManager _networkingManager = GetIt.instance<NetworkingManager>();

  Future<Stock> createStock({
    required String storeId,
    required String productId,
    required int totalQuantity,
    required List<PricingTier> pricing,
  }) async {
    try {
      final body = {
        'storeId': storeId,
        'productId': productId,
        'totalQuantity': totalQuantity,
        'pricing': pricing.map((item) => item.toJson()).toList(),
      };
      
      final response = await _networkingManager.post(
        endpoint: 'api/stock', // This endpoint requires auth according to API docs
        body: body,
        authenticated: true,
      );
      return Stock.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create stock: $e');
    }
  }

  // Add other stock-related methods as needed
}