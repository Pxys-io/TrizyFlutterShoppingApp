import 'package:get_it/get_it.dart';
import '../models/stock/stock_model.dart';
import '../services/stock_api_service.dart';

class StockRepository {
  final StockApiService _stockApiService = GetIt.instance<StockApiService>();

  Future<Stock> createStock({
    required String storeId,
    required String productId,
    required int totalQuantity,
    required List<PricingTier> pricing,
  }) async {
    return _stockApiService.createStock(
      storeId: storeId,
      productId: productId,
      totalQuantity: totalQuantity,
      pricing: pricing,
    );
  }

  // Add other stock-related methods as needed
}