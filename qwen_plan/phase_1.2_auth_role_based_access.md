# Phase 1.2: Enhanced Authentication System with Role-Based Access

## Feature Overview
Implement an enhanced authentication system that supports different user roles (admin, merchant, customer) with role-based access control. This phase will extend the current authentication system to support the different permissions required by the API endpoints for admin and merchant functions.

## Related API Endpoints
- **POST** `/api/register` - Register user (with `isAdmin` field)
- **POST** `/api/login` - Login user
- **POST** `/api/refresh` - Refresh authentication token
- **POST** `/api/logout` - Logout user
- **POST** `/api/check-tokens` - Validate tokens

## Current Dart Files
- `lib/models/auth/` - Current authentication models
- `lib/services/auth_api_service.dart` - Current authentication service
- `lib/repositories/auth_repository.dart` - Current auth repository
- `lib/bloc/auth/` - Current auth BLoC
- `lib/di/service_locator.dart` - Dependency injection configuration

## Files to Create/Update
- `lib/models/auth/auth_response_model.dart` - Enhanced auth response with role information
- `lib/models/auth/user_role_enum.dart` - User role enum
- `lib/models/auth/user_profile_with_role_model.dart` - Extended user profile with role
- `lib/services/auth_api_service.dart` - Update existing service
- `lib/repositories/auth_repository.dart` - Update existing repository
- `lib/bloc/auth/sign_in/signin_bloc.dart` - Update auth BLoC for roles

## Enhanced User Role Enum
```dart
enum UserRole {
  customer(0, 'customer'),
  merchant(1, 'merchant'),
  admin(2, 'admin'),
  superAdmin(3, 'super_admin');

  const UserRole(this.value, this.roleName);
  
  final int value;
  final String roleName;
  
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'merchant':
        return UserRole.merchant;
      case 'admin':
        return UserRole.admin;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.customer;
    }
  }
  
  static UserRole fromInt(int value) {
    switch (value) {
      case 0:
        return UserRole.customer;
      case 1:
        return UserRole.merchant;
      case 2:
        return UserRole.admin;
      case 3:
        return UserRole.superAdmin;
      default:
        return UserRole.customer;
    }
  }
}
```

## Enhanced User Profile Model
```dart
class UserProfileWithRole extends UserProfile {
  final UserRole role;
  final List<String>? storeIds;  // Stores the user has access to (merchants)
  final bool? isAdmin;           // Legacy admin flag from backend
  final DateTime? lastLoginAt;   // Last login timestamp
  final String? currentStoreId;  // Currently selected store (for merchants)

  UserProfileWithRole({
    required super.id,
    required super.userId,
    required super.username,
    required super.email,
    required super.phoneNumber,
    required super.firstName,
    required super.lastName,
    super.dateOfBirth,
    super.profilePictureUrl,
    super.createdAt,
    super.updatedAt,
    super.addresses,
    super.defaultAddress,
    super.preferredLanguage,
    super.preferredCurrency,
    super.newsletterSubscription,
    super.loyaltyPoints,
    super.isEmailVerified,
    super.isPhoneVerified,
    super.accountStatus,
    super.profileCompletionPercentage,
    super.securitySettings,
    required this.role,
    this.storeIds,
    this.isAdmin,
    this.lastLoginAt,
    this.currentStoreId,
  }) : super(
          id: id,
          userId: userId,
          username: username,
          email: email,
          phoneNumber: phoneNumber,
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dateOfBirth,
          profilePictureUrl: profilePictureUrl,
          createdAt: createdAt,
          updatedAt: updatedAt,
          addresses: addresses,
          defaultAddress: defaultAddress,
          preferredLanguage: preferredLanguage,
          preferredCurrency: preferredCurrency,
          newsletterSubscription: newsletterSubscription,
          loyaltyPoints: loyaltyPoints,
          isEmailVerified: isEmailVerified,
          isPhoneVerified: isPhoneVerified,
          accountStatus: accountStatus,
          profileCompletionPercentage: profileCompletionPercentage,
          securitySettings: securitySettings,
        );

  factory UserProfileWithRole.fromJson(Map<String, dynamic> json) {
    return UserProfileWithRole(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth'] as String) : null,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      addresses: json['addresses'] != null 
          ? List<Address>.from(json['addresses'].map((x) => Address.fromJson(x as Map<String, dynamic>))) 
          : <Address>[],
      defaultAddress: json['defaultAddress'] != null 
          ? Address.fromJson(json['defaultAddress'] as Map<String, dynamic>) 
          : null,
      preferredLanguage: json['preferredLanguage'] as String?,
      preferredCurrency: json['preferredCurrency'] as String?,
      newsletterSubscription: json['newsletterSubscription'] as bool?,
      loyaltyPoints: json['loyaltyPoints'] as int?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      isPhoneVerified: json['isPhoneVerified'] as bool?,
      accountStatus: json['accountStatus'] as String?,
      profileCompletionPercentage: json['profileCompletionPercentage'] as int?,
      securitySettings: json['securitySettings'] as Map<String, dynamic>?,
      role: UserRole.fromString(json['role'] as String? ?? 'customer'),
      storeIds: json['storeIds'] != null 
          ? List<String>.from(json['storeIds'] as List) 
          : null,
      isAdmin: json['isAdmin'] as bool?,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
      currentStoreId: json['currentStoreId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll({
      'role': role.roleName,
      'storeIds': storeIds,
      'isAdmin': isAdmin,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'currentStoreId': currentStoreId,
    });
    return json;
  }
}
```

## Registration Request with Role
```dart
class RegisterRequestWithRole extends RegisterRequest {
  final UserRole role;
  final bool? isAdmin; // For backward compatibility with backend

  RegisterRequestWithRole({
    required super.email,
    required super.password,
    required super.firstName,
    required super.lastName,
    required super.phoneNumber,
    super.username,
    this.role = UserRole.customer,
    this.isAdmin,
  }) : super(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          username: username,
        );

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll({
      'role': role.roleName,
      if (isAdmin != null) 'isAdmin': isAdmin,
    });
    return json;
  }
}
```

## Enhanced Auth API Service
```dart
class AuthApiService {
  final Dio _dio;
  final String _baseUrl;

  AuthApiService(this._dio, this._baseUrl);

  // Existing methods will be enhanced to handle role-based responses
  Future<ApiResponse<AuthResponseWithRole>> registerWithRole(RegisterRequestWithRole request) async {
    try {
      final response = await _dio.post(
        '${_baseUrl}${ApiEndpoints.register}',
        data: request.toJson(),
      );
      return ApiResponse.success(AuthResponseWithRole.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Unknown error');
    }
  }

  // Login that returns role information
  Future<ApiResponse<AuthResponseWithRole>> loginWithRole(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '${_baseUrl}${ApiEndpoints.login}',
        data: request.toJson(),
      );
      return ApiResponse.success(AuthResponseWithRole.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.error(e.message ?? 'Unknown error');
    }
  }

  // Check role-based permissions
  Future<bool> hasRolePermission(UserRole requiredRole) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return false;
    
    // Admins have permission for everything
    if (currentUser.role == UserRole.admin || currentUser.role == UserRole.superAdmin) {
      return true;
    }
    
    // Check if user's role meets or exceeds required role
    return currentUser.role.value >= requiredRole.value;
  }

  // Get current user with role
  Future<UserProfileWithRole?> getCurrentUser() async {
    // Implementation to retrieve current user with role from shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        final Map<String, dynamic> userData = json.decode(userJson);
        return UserProfileWithRole.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  // Switch currently selected store for merchants
  Future<bool> switchStore(String storeId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;
      
      // Verify user has access to this store
      if (currentUser.storeIds != null && 
          currentUser.storeIds!.contains(storeId)) {
        final updatedUser = currentUser.copyWith(currentStoreId: storeId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', json.encode(updatedUser.toJson()));
        return true;
      }
      return false;
    } catch (e) {
      print('Error switching store: $e');
      return false;
    }
  }
}
```

## Enhanced Auth Response Model
```dart
class AuthResponseWithRole {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserProfileWithRole user;

  AuthResponseWithRole({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseWithRole.fromJson(Map<String, dynamic> json) {
    return AuthResponseWithRole(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      user: UserProfileWithRole.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'user': user.toJson(),
    };
  }
}
```

## Role-Based Navigation Middleware
```dart
class RoleBasedNavigationGuard {
  static bool canAccessRoute(String route, UserRole userRole) {
    switch (route) {
      // Customer routes (accessible by all roles)
      case '/home':
      case '/products':
      case '/product-detail':
      case '/cart':
      case '/checkout':
      case '/orders':
      case '/profile':
        return true;
      
      // Merchant/Store owner routes
      case '/store-dashboard':
      case '/store-orders':
      case '/store-products':
      case '/store-analytics':
        return userRole == UserRole.merchant || 
               userRole == UserRole.admin || 
               userRole == UserRole.superAdmin;
      
      // Admin-only routes
      case '/admin-dashboard':
      case '/admin-stores':
      case '/admin-users':
      case '/admin-orders':
      case '/admin-reports':
        return userRole == UserRole.admin || userRole == UserRole.superAdmin;
      
      // Super admin only routes
      case '/super-admin-panel':
        return userRole == UserRole.superAdmin;
      
      default:
        // Default to allowing access, but this should be reviewed
        return true;
    }
  }
  
  static String getInitialRouteForRole(UserRole userRole) {
    switch (userRole) {
      case UserRole.customer:
        return '/home';
      case UserRole.merchant:
        return '/store-dashboard';
      case UserRole.admin:
        return '/admin-dashboard';
      case UserRole.superAdmin:
        return '/super-admin-panel';
    }
  }
}
```

## Expected Outcome
- Ability to register users with specific roles
- Login system that returns role information
- Role-based access control for different parts of the app
- Store switching capability for merchants managing multiple stores
- Enhanced user profile with role information

## Visual Presentation
- Role-based navigation will guide users to appropriate dashboards
- Merchant users will see store management options
- Admin users will have access to admin panels
- Super admin users will have full platform control

## Related Notes
- The backend API uses an `isAdmin` boolean field, but we'll implement a more flexible role system
- Merchants will be able to manage stores assigned to them via storeIds
- The authentication system must handle token refresh for different role levels
- We'll maintain backward compatibility with the existing `isAdmin` field while implementing our new role system

## Files to Read Before Implementing
- `lib/models/auth/` directory - All current auth models
- `lib/services/auth_api_service.dart` - Current auth service implementation
- `lib/bloc/auth/` directory - Current auth BLoC patterns
- `lib/routing/router.dart` - Current routing configuration
- `lib/di/service_locator.dart` - Current dependency injection setup

## Architecture
- Will follow the existing repository pattern for data abstraction
- BLoC pattern will be extended to handle role-based states
- Service layer will support enhanced authentication methods
- The implementation will maintain compatibility with existing authentication flows while adding role-based functionality