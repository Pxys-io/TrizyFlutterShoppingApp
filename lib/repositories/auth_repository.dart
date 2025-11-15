import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trizy_app/models/local/local_liked_product.dart';
import 'package:trizy_app/services/local/local_product_service.dart';
import '../di/locator.dart';
import '../models/auth/request/sign_in_request.dart';
import '../models/auth/request/sign_up_request.dart';
import '../models/auth/response/sign_in_response.dart';
import '../models/auth/response/sign_up_response.dart';
import '../models/local/local_cart_item.dart';
import '../models/user/user_model.dart';
import '../models/user/user_pref_model.dart';
import '../services/auth_api_service.dart';

class AuthRepository {
  final AuthApiService apiService;
  final LocalProductService localProductService = getIt<LocalProductService>();
  
  User? _currentUser;
  String? _currentStoreId;

  AuthRepository(this.apiService);

  // Getters for current state
  User? get currentUser => _currentUser;
  String? get currentStoreId => _currentStoreId;
  
  bool isAuthenticated() {
    return _currentUser != null;
  }
  
  bool isAdmin() {
    return _currentUser?.isAdmin == true;
  }

  Future<User> signUp(SignUpRequest request) async {
    try {
      final SignUpResponse response = await apiService.register(request);

      final user = User(
        id: response.id,
        email: response.email,
        firstName: response.userFirstName,
        lastName: response.userLastName,
        isAdmin: response.isAdmin ?? false, // Add isAdmin property
        emailVerified: response.emailVerified,
      );

      await _saveTokens(response.accessToken, response.refreshToken);

      await _saveUser(UserPreferencesModel(
        id: response.id,
        email: response.email,
        firstName: response.userFirstName,
        lastName: response.userLastName,
        isSubscriber: response.isSubscriber,
        isAdmin: response.isAdmin ?? false, // Store isAdmin in local preferences too
      ));

      _currentUser = user; // Update in-memory user
      return user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<User> signIn(SignInRequest request) async {
    try {
      final SignInResponse response = await apiService.signIn(request);

      final user = User(
        id: response.id,
        email: response.email,
        firstName: response.userFirstName,
        lastName: response.userLastName,
        isAdmin: response.isAdmin ?? false, // Add isAdmin property
        emailVerified: response.emailVerified,
        isSubscriber: response.isSubscriber,
      );

      await _saveTokens(response.accessToken, response.refreshToken);

      await _saveUser(UserPreferencesModel(
        id: response.id,
        email: response.email,
        firstName: response.userFirstName,
        lastName: response.userLastName,
        isSubscriber: response.isSubscriber,
        isAdmin: response.isAdmin ?? false, // Store isAdmin in local preferences too
      ));

      final List<String> severLikedProductIds = response.likedProductIds;
      final List<String> serverCartItemIds = response.cartItemIds;

      final List<LocalCartItem> localCartItems = serverCartItemIds.map((id) {
        return LocalCartItem(productId: id);
      }).toList();

      final List<LocalLikedProduct> localLikedProducts = severLikedProductIds.map((id) {
        return LocalLikedProduct(productId: id, likedAt: DateTime.now());
      }).toList();

      if(severLikedProductIds.isNotEmpty){
       await localProductService.clearLikesAndInsertAllLikes(localLikedProducts);
      }
      else{
        await localProductService.clearAllLikes();
      }

      if(serverCartItemIds.isNotEmpty){
        await localProductService.clearCartAndInsertAllCartItems(localCartItems);
      }
      else{
        await localProductService.clearCart();
      }

      _currentUser = user; // Update in-memory user
      return user;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Initialize the repository by loading user data from local storage
  Future<void> init() async {
    final userPrefs = await getUser();
    if (userPrefs != null) {
      _currentUser = User(
        id: userPrefs.id,
        email: userPrefs.email,
        firstName: userPrefs.firstName,
        lastName: userPrefs.lastName,
        isAdmin: userPrefs.isAdmin ?? false,
        emailVerified: userPrefs.emailVerified ?? false,
        isSubscriber: userPrefs.isSubscriber ?? false,
        hasActiveTrial: userPrefs.hasActiveTrial ?? false,
      );
    }
    
    // Load current store ID if any
    final prefs = await SharedPreferences.getInstance();
    _currentStoreId = prefs.getString('currentStoreId');
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<void> _saveUser(UserPreferencesModel user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('user', userJson);
  }

  Future<UserPreferencesModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson == null) return null;
    Map<String, dynamic> userMap = jsonDecode(userJson);
    return UserPreferencesModel.fromJson(userMap);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('currentStoreId'); // Also clear store ID
    
    _currentUser = null; // Clear in-memory user
    _currentStoreId = null; // Clear current store ID
  }
  
  // Methods for managing current store ID
  Future<void> setCurrentStoreId(String storeId) async {
    _currentStoreId = storeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentStoreId', storeId);
  }

  Future<void> clearCurrentStoreId() async {
    _currentStoreId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentStoreId');
  }
}