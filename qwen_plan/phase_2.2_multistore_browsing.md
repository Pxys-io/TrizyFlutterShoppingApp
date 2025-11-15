# Phase 2.2: Multistore Browsing and Selection for Customers

## Feature Overview
Implement functionality that allows customers to browse products from multiple stores, switch between stores, and understand which store they are purchasing from. This phase will enhance the customer-facing application to support the multistore functionality while maintaining a seamless shopping experience.

## Related API Endpoints
- **GET** `/api/products` - Products endpoint (may need store filtering capability)
- **GET** `/api/products/category/{categoryId}` - Category products (may need store filtering)
- **GET** `/api/products/search/` - Product search (may need store filtering)
- Potentially additional endpoints for store-specific product listings

## Current Dart Files
- `lib/views/product/` - Existing product browsing UI
- `lib/views/main/home_view.dart` - Main home screen
- `lib/bloc/products/` - Existing product BLoC
- `lib/models/product/product_model.dart` - Current product model
- `lib/services/products_api_service.dart` - Product API service
- `lib/repositories/products_repository.dart` - Product repository

## Files to Create/Update
- `lib/models/product/product_model.dart` - Update to include store information
- `lib/services/products_api_service.dart` - Update to support store filtering
- `lib/repositories/products_repository.dart` - Update to support store filtering
- `lib/views/store/store_selector_view.dart` - Store selection UI for customers
- `lib/bloc/store_selector/store_selector_bloc.dart` - Store selector BLoC
- `lib/bloc/store_selector/store_selector_event.dart` - Store selector events
- `lib/bloc/store_selector/store_selector_state.dart` - Store selector states
- `lib/views/product/products_by_store_view.dart` - Products by store UI
- `lib/views/main/store_home_view.dart` - Store-specific home view
- `lib/components/store/store_header_component.dart` - Store header UI component
- `lib/components/store/store_badge_component.dart` - Store badge indicator
- `lib/models/store/store_listing_model.dart` - Model for store listings
- `lib/services/stores_browsing_service.dart` - Service for store browsing

## Enhanced Product Model with Store Information
```dart
class ProductWithStore extends Product {
  final Store store;
  final String storeId;
  final String storeName;
  final String? storeLogoUrl;
  final double storeRating;
  final bool isStoreVerified;
  final String? storeDeliveryTime; // e.g. "3-5 days"
  final double? storeDeliveryFee;
  final List<String> storePaymentMethods;
  final bool storeIsActive;

  ProductWithStore({
    // Original Product fields
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.originalPrice,
    required super.categoryId,
    required super.categoryName,
    required super.images,
    required super.thumbnail,
    required super.sellerId,
    required super.isInWishlist,
    required super.isInCart,
    required super.quantityInCart,
    required super.rating,
    required super.numberOfReviews,
    required super.isAvailable,
    required super.isFeatured,
    required super.isBestSeller,
    required super.isNew,
    required super.discountPercentage,
    required super.salesCount,
    required super.createdAt,
    required super.updatedAt,
    required super.attributes,
    required super.variants,
    required super.tags,
    required super.currency,
    
    // New store-related fields
    required this.store,
    required this.storeId,
    required this.storeName,
    this.storeLogoUrl,
    required this.storeRating,
    required this.isStoreVerified,
    this.storeDeliveryTime,
    this.storeDeliveryFee,
    required this.storePaymentMethods,
    required this.storeIsActive,
  }) : super(
    id: id,
    name: name,
    description: description,
    price: price,
    originalPrice: originalPrice,
    categoryId: categoryId,
    categoryName: categoryName,
    images: images,
    thumbnail: thumbnail,
    sellerId: sellerId,
    isInWishlist: isInWishlist,
    isInCart: isInCart,
    quantityInCart: quantityInCart,
    rating: rating,
    numberOfReviews: numberOfReviews,
    isAvailable: isAvailable,
    isFeatured: isFeatured,
    isBestSeller: isBestSeller,
    isNew: isNew,
    discountPercentage: discountPercentage,
    salesCount: salesCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
    attributes: attributes,
    variants: variants,
    tags: tags,
    currency: currency,
  );

  factory ProductWithStore.fromJson(Map<String, dynamic> json) {
    return ProductWithStore(
      // Original Product fields
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      images: List<String>.from(json['images'] as List),
      thumbnail: json['thumbnail'] as String,
      sellerId: json['sellerId'] as String,
      isInWishlist: json['isInWishlist'] as bool? ?? false,
      isInCart: json['isInCart'] as bool? ?? false,
      quantityInCart: json['quantityInCart'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      numberOfReviews: json['numberOfReviews'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      discountPercentage: json['discountPercentage'] as int? ?? 0,
      salesCount: json['salesCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      attributes: json['attributes'] != null
          ? Map<String, dynamic>.from(json['attributes'] as Map)
          : <String, dynamic>{},
      variants: json['variants'] != null
          ? List<Map<String, dynamic>>.from(
              (json['variants'] as List).map((x) => Map<String, dynamic>.from(x as Map<String, dynamic>)))
          : <Map<String, dynamic>>[],
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : <String>[],
      currency: json['currency'] as String? ?? 'USD',
      
      // New store-related fields
      store: Store.fromJson(json['store'] as Map<String, dynamic>),
      storeId: json['storeId'] as String? ?? json['store']['id'] as String,
      storeName: json['storeName'] as String? ?? json['store']['name'] as String,
      storeLogoUrl: json['storeLogoUrl'] as String? ?? json['store']['storeLogoUrl'] as String?,
      storeRating: (json['storeRating'] as num?)?.toDouble() ?? (json['store']['rating'] as num?)?.toDouble() ?? 0.0,
      isStoreVerified: json['isStoreVerified'] as bool? ?? (json['store']['isVerified'] as bool?) ?? false,
      storeDeliveryTime: json['storeDeliveryTime'] as String?,
      storeDeliveryFee: (json['storeDeliveryFee'] as num?)?.toDouble(),
      storePaymentMethods: json['storePaymentMethods'] != null
          ? List<String>.from(json['storePaymentMethods'] as List)
          : (json['store']['paymentMethods'] as List?)?.cast<String>() ?? <String>[],
      storeIsActive: json['storeIsActive'] as bool? ?? (json['store']['isActive'] as bool?) ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll({
      'storeId': storeId,
      'storeName': storeName,
      'storeLogoUrl': storeLogoUrl,
      'storeRating': storeRating,
      'isStoreVerified': isStoreVerified,
      'storeDeliveryTime': storeDeliveryTime,
      'storeDeliveryFee': storeDeliveryFee,
      'storePaymentMethods': storePaymentMethods,
      'storeIsActive': storeIsActive,
      'store': store.toJson(),
    });
    return json;
  }
}
```

## Store Selector BLoC

### Events
```dart
abstract class StoreSelectorEvent {}

class LoadAvailableStores extends StoreSelectorEvent {
  final double? latitude;
  final double? longitude;
  final String? locationQuery;

  LoadAvailableStores({this.latitude, this.longitude, this.locationQuery});
}

class SelectStore extends StoreSelectorEvent {
  final String storeId;

  SelectStore(this.storeId);
}

class FilterStores extends StoreSelectorEvent {
  final StoresFilter filter;

  FilterStores(this.filter);
}

class RefreshStores extends StoreSelectorEvent {
  final double? latitude;
  final double? longitude;

  RefreshStores({this.latitude, this.longitude});
}
```

### States
```dart
abstract class StoreSelectorState {}

class StoreSelectorInitial extends StoreSelectorState {}

class StoreSelectorLoading extends StoreSelectorState {}

class StoreSelectorLoaded extends StoreSelectorState {
  final List<Store> availableStores;
  final Store? selectedStore;
  final StoresFilter? currentFilter;

  StoreSelectorLoaded({
    required this.availableStores,
    this.selectedStore,
    this.currentFilter,
  });
}

class StoreSelectorError extends StoreSelectorState {
  final String message;

  StoreSelectorError(this.message);
}

class StoreSelected extends StoreSelectorState {
  final Store selectedStore;

  StoreSelected(this.selectedStore);
}
```

### Store Filter Model
```dart
class StoresFilter {
  final String? name;
  final List<String>? categories;
  final bool? isVerified;
  final bool? isActive;
  final double? minRating;
  final String? sortBy;  // 'rating', 'deliveryTime', 'distance', 'popularity'
  final String? sortOrder;  // 'asc' or 'desc'
  final double? latitude;
  final double? longitude;
  final double? maxDistance;  // in kilometers
  final int? page;
  final int? limit;

  StoresFilter({
    this.name,
    this.categories,
    this.isVerified,
    this.isActive,
    this.minRating,
    this.sortBy = 'distance',
    this.sortOrder = 'asc',
    this.latitude,
    this.longitude,
    this.maxDistance,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (name != null) 'name': name,
      if (categories != null) 'categories': categories!.join(','),
      if (isVerified != null) 'isVerified': isVerified,
      if (isActive != null) 'isActive': isActive,
      if (minRating != null) 'minRating': minRating,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (maxDistance != null) 'maxDistance': maxDistance,
      'page': page,
      'limit': limit,
    }..removeWhere((key, value) => value == null);
  }
}
```

### BLoC Implementation
```dart
class StoreSelectorBloc extends Bloc<StoreSelectorEvent, StoreSelectorState> {
  final StoresRepository _storesRepository;

  StoreSelectorBloc(this._storesRepository) : super(StoreSelectorInitial()) {
    on<LoadAvailableStores>(_onLoadAvailableStores);
    on<SelectStore>(_onSelectStore);
    on<FilterStores>(_onFilterStores);
    on<RefreshStores>(_onRefreshStores);
  }

  Future<void> _onLoadAvailableStores(
      LoadAvailableStores event, Emitter<StoreSelectorState> emit) async {
    emit(StoreSelectorLoading());
    
    try {
      final StoresFilter filter = StoresFilter(
        latitude: event.latitude,
        longitude: event.longitude,
      );
      
      final stores = await _storesRepository.getAvailableStores(filter);
      final selectedStoreId = await _getSelectedStoreId();
      final selectedStore = selectedStoreId != null 
          ? stores.firstWhere((store) => store.id == selectedStoreId, orElse: () => stores.first)
          : stores.isNotEmpty ? stores.first : null;
          
      emit(StoreSelectorLoaded(
        availableStores: stores,
        selectedStore: selectedStore,
        currentFilter: filter,
      ));
    } catch (e) {
      emit(StoreSelectorError(e.toString()));
    }
  }

  Future<void> _onSelectStore(
      SelectStore event, Emitter<StoreSelectorState> emit) async {
    try {
      final state = this.state as StoreSelectorLoaded;
      final selectedStore = state.availableStores.firstWhere(
        (store) => store.id == event.storeId,
        orElse: () => state.availableStores.first,
      );
      
      await _saveSelectedStoreId(event.storeId);
      emit(StoreSelected(selectedStore));
    } catch (e) {
      emit(StoreSelectorError('Failed to select store: ${e.toString()}'));
    }
  }

  Future<void> _onFilterStores(
      FilterStores event, Emitter<StoreSelectorState> emit) async {
    emit(StoreSelectorLoading());
    
    try {
      final stores = await _storesRepository.getAvailableStores(event.filter);
      final selectedStoreId = await _getSelectedStoreId();
      final selectedStore = selectedStoreId != null && stores.any((s) => s.id == selectedStoreId)
          ? stores.firstWhere((store) => store.id == selectedStoreId)
          : stores.isNotEmpty ? stores.first : null;
          
      emit(StoreSelectorLoaded(
        availableStores: stores,
        selectedStore: selectedStore,
        currentFilter: event.filter,
      ));
    } catch (e) {
      emit(StoreSelectorError(e.toString()));
    }
  }

  Future<void> _onRefreshStores(
      RefreshStores event, Emitter<StoreSelectorState> emit) async {
    add(LoadAvailableStores(
      latitude: event.latitude,
      longitude: event.longitude,
    ));
  }

  Future<String?> _getSelectedStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_store_id');
  }

  Future<void> _saveSelectedStoreId(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_store_id', storeId);
  }
}
```

## Store-Specific Product Service Updates
```dart
class ProductsApiService {
  final Dio _dio;
  final String _baseUrl;

  ProductsApiService(this._dio, this._baseUrl);

  // Original methods...

  // Enhanced methods with store filtering
  Future<ApiResponse<List<ProductWithStore>>> getProductsByStore({
    required String storeId,
    int page = 1,
    int limit = 20,
    String? sortBy = 'createdAt',
    String? sortOrder = 'desc',
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParameters = {
        'storeId': storeId,
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (category != null) 'category': category,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
      };

      final response = await _dio.get(
        '${_baseUrl}${ApiEndpoints.products}',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
        ),
      );
      
      final products = (response.data['data'] as List)
          .map((json) => ProductWithStore.fromJson(json))
          .toList();
      return ApiResponse.success(products);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Unknown error');
    }
  }

  Future<ApiResponse<List<ProductWithStore>>> searchProductsByStore({
    String? query,
    String? storeId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParameters = {
        if (query != null) 'q': query,
        if (storeId != null) 'storeId': storeId,
        'page': page,
        'limit': limit,
      };

      final response = await _dio.get(
        '${_baseUrl}${ApiEndpoints.productSearch}',
        queryParameters: queryParameters,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAuthToken()}',
          },
        ),
      );
      
      final products = (response.data['data'] as List)
          .map((json) => ProductWithStore.fromJson(json))
          .toList();
      return ApiResponse.success(products);
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Unknown error');
    }
  }
}
```

## Store Browsing Service
```dart
class StoresBrowsingService {
  final StoresApiService _storesApiService;
  final ProductsApiService _productsApiService;
  final SharedPreferences _sharedPreferences;

  StoresBrowsingService(
    this._storesApiService, 
    this._productsApiService, 
    this._sharedPreferences,
  );

  // Get currently selected store for the user
  Future<Store?> getCurrentStore() async {
    final storeId = _sharedPreferences.getString('selected_store_id');
    if (storeId != null) {
      // Could fetch fresh store data from API, or use cached version
      // For now, we'll return null and let the UI handle it
      return null; // In a real implementation, fetch from API
    }
    return null;
  }

  // Set the store context for the user session
  Future<bool> setCurrentStore(String storeId) async {
    try {
      return await _sharedPreferences.setString('selected_store_id', storeId);
    } catch (e) {
      print('Error setting current store: $e');
      return false;
    }
  }

  // Get products from the currently selected store
  Future<ApiResponse<List<ProductWithStore>>> getProductsForCurrentStore({
    int page = 1,
    int limit = 20,
  }) async {
    final storeId = _sharedPreferences.getString('selected_store_id');
    if (storeId == null) {
      return ApiResponse.error('No store selected');
    }
    
    return await _productsApiService.getProductsByStore(
      storeId: storeId,
      page: page,
      limit: limit,
    );
  }

  // Search products within the currently selected store
  Future<ApiResponse<List<ProductWithStore>>> searchProductsInCurrentStore(String query) async {
    final storeId = _sharedPreferences.getString('selected_store_id');
    
    return await _productsApiService.searchProductsByStore(
      query: query,
      storeId: storeId,
    );
  }

  // Get nearby stores based on user's location
  Future<ApiResponse<List<Store>>> getNearbyStores({
    required double latitude,
    required double longitude,
    double maxDistance = 50, // 50km default
  }) async {
    // This would be implemented with a new backend endpoint
    // For now, returning all active stores as a placeholder
    return await _storesApiService.getAllStores();
  }
}
```

## Expected Outcome
- Customers can browse products from specific stores
- Store selection interface to switch between available stores
- Product listings that show which store they belong to
- Store-specific search functionality
- Location-based store recommendations
- Improved product discovery with store context

## Visual Presentation
- Store selector dropdown or modal on product pages
- Store badges on product cards showing the selling store
- Store-specific home pages with featured products
- Store filtering options in search and category views
- Clear visual indicators of which store is currently active
- Store profile sections showing store ratings and policies

## Related Notes
- Customers should be able to see which store they're purchasing from
- Store-specific policies (returns, shipping) should be clearly displayed
- The shopping cart should properly handle items from different stores
- Checkout process may need modifications to handle multi-store orders
- Search functionality should allow filtering by store
- Performance considerations for loading products across multiple stores

## Files to Read Before Implementing
- `lib/views/product/` - All product browsing related views
- `lib/models/product/product_model.dart` - Current product model
- `lib/bloc/products/` - Existing product BLoC implementation
- `lib/views/main/home_view.dart` - Current main home view
- `lib/components/` - Existing UI components that might be adapted
- `lib/theme/` - Current theme for consistent styling

## Architecture
- Will extend existing product models to include store information
- Repository pattern will be updated to support store-specific queries
- Service layer will handle the multi-store logic
- The UI will be enhanced to show store context without overwhelming users
- BLoC pattern will manage store selection state
- Caching strategy will be important for performance with multiple stores