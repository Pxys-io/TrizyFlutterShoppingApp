# Detailed Plan: Implementing Admin and Store-Owner/Merchant Pages (API-Driven)

**Goal:** Implement new Admin and Store-Owner/Merchant pages based *strictly* on the provided API documentation and existing application architecture. This plan prioritizes adherence to the API's capabilities, simplifying features where the API does not provide the necessary data or endpoints.

**Key Architectural Principles:**
*   **API-First:** All data models and available operations are derived directly from the `https://store-backend-eta.vercel.app/openapi.json` specification.
*   **Layered Architecture:** Maintain UI -> BLoC -> Repository -> API Service -> NetworkingManager flow.
*   **State Management:** BLoC pattern (`event`, `state`, `bloc` files per feature).
*   **Dependency Injection:** `GetIt` for managing dependencies.
*   **Routing:** `go_router` for navigation.

---

**Phase 0: Pre-computation and Re-verification (API-Driven)**

**Objective:** Understand the definitive API capabilities and how they constrain or enable the planned features.

*   **0.1. Re-verify API Endpoints and Models (from `openapi.json`):**
    *   **Auth:**
        *   `POST /auth/signup`: `SignUpRequest` -> `SignUpResponse`
        *   `POST /auth/signin`: `SignInRequest` -> `SignInResponse`
    *   **Users:**
        *   `GET /users`: Get all users
        *   `POST /users`: Create user (`UserCreate`)
        *   `GET /users/{id}`: Get user by ID
        *   `PUT /users/{id}`: Update user (`UserUpdate`)
        *   `DELETE /users/{id}`: Delete user
    *   **Stores:**
        *   `GET /stores`: Get all stores
        *   `POST /stores`: Create store (`StoreCreate`)
        *   `GET /stores/{id}`: Get store by ID
        *   `PUT /stores/{id}`: Update store (`StoreUpdate`)
        *   `DELETE /stores/{id}`: Delete store
    *   **Products:**
        *   `GET /products`: Get all products (assuming `?storeId=` filter is possible, though not explicitly in spec)
        *   `POST /products`: Create product (`ProductCreate`)
        *   `GET /products/{id}`: Get product by ID
        *   `PUT /products/{id}`: Update product (`ProductUpdate`)
        *   `DELETE /products/{id}`: Delete product
    *   **Stock:**
        *   `GET /stock`: Get all stock entries (assuming `?storeId=` and `?productId=` filters are possible)
        *   `POST /stock`: Create stock (`StockCreate`)
        *   `GET /stock/{id}`: Get stock entry by ID
        *   `PUT /stock/{id}`: Update stock (`StockUpdate`)
        *   `DELETE /stock/{id}`: Delete stock
    *   **Orders:**
        *   `GET /orders`: Get all orders (assuming `?storeId=` and `?userId=` filters are possible)
        *   `POST /orders`: Create order (`OrderCreate`)
        *   `GET /orders/{id}`: Get order by ID
        *   `PUT /orders/{id}`: Update order (`OrderUpdate`)
        *   `DELETE /orders/{id}`: Delete order

*   **0.2. API-Defined Data Models (Crucial Reference):**

    *   **`SignUpRequest`**
        *   `username`: `string` (Required)
        *   `email`: `string` (format: `email`) (Required)
        *   `password`: `string` (format: `password`) (Required)

    *   **`SignUpResponse`**
        *   `message`: `string` (Required)
        *   `user`: `User` (Required)

    *   **`SignInRequest`**
        *   `email`: `string` (format: `email`) (Required)
        *   `password`: `string` (format: `password`) (Required)

    *   **`SignInResponse`**
        *   `message`: `string` (Required)
        *   `token`: `string` (Required)
        *   `user`: `User` (Required)

    *   **`User`**
        *   `id`: `string` (format: `uuid`) (Required)
        *   `username`: `string` (Required)
        *   `email`: `string` (format: `email`) (Required)
        *   `role`: `string` (enum: `admin`, `user`; default: `user`) (Required)
        *   `createdAt`: `string` (format: `date-time`) (Required)
        *   `updatedAt`: `string` (format: `date-time`) (Required)

    *   **`UserCreate`**
        *   `username`: `string` (Required)
        *   `email`: `string` (format: `email`) (Required)
        *   `password`: `string` (format: `password`) (Required)
        *   `role`: `string` (enum: `admin`, `user`; default: `user`) (Optional)

    *   **`UserUpdate`**
        *   `username`: `string` (Optional)
        *   `email`: `string` (format: `email`) (Optional)
        *   `password`: `string` (format: `password`) (Optional)
        *   `role`: `string` (enum: `admin`, `user`) (Optional)

    *   **`Store`**
        *   `id`: `string` (format: `uuid`) (Required)
        *   `name`: `string` (Required)
        *   `address`: `string` (Required)
        *   `createdAt`: `string` (format: `date-time`) (Required)
        *   `updatedAt`: `string` (format: `date-time`) (Required)

    *   **`StoreCreate`**
        *   `name`: `string` (Required)
        *   `address`: `string` (Required)

    *   **`StoreUpdate`**
        *   `name`: `string` (Optional)
        *   `address`: `string` (Optional)

    *   **`Product`**
        *   `id`: `string` (format: `uuid`) (Required)
        *   `name`: `string` (Required)
        *   `description`: `string` (Required)
        *   `price`: `number` (format: `float`) (Required)
        *   `storeId`: `string` (format: `uuid`) (Required)
        *   `createdAt`: `string` (format: `date-time`) (Required)
        *   `updatedAt`: `string` (format: `date-time`) (Required)

    *   **`ProductCreate`**
        *   `name`: `string` (Required)
        *   `description`: `string` (Required)
        *   `price`: `number` (format: `float`) (Required)
        *   `storeId`: `string` (format: `uuid`) (Required)

    *   **`ProductUpdate`**
        *   `name`: `string` (Optional)
        *   `description`: `string` (Optional)
        *   `price`: `number` (format: `float`) (Optional)
        *   `storeId`: `string` (format: `uuid`) (Optional)

    *   **`Stock`**
        *   `id`: `string` (format: `uuid`) (Required)
        *   `productId`: `string` (format: `uuid`) (Required)
        *   `storeId`: `string` (format: `uuid`) (Required)
        *   `quantity`: `integer` (Required)
        *   `createdAt`: `string` (format: `date-time`) (Required)
        *   `updatedAt`: `string` (format: `date-time`) (Required)

    *   **`StockCreate`**
        *   `productId`: `string` (format: `uuid`) (Required)
        *   `storeId`: `string` (format: `uuid`) (Required)
        *   `quantity`: `integer` (Required)

    *   **`StockUpdate`**
        *   `productId`: `string` (format: `uuid`) (Optional)
        *   `storeId`: `string` (format: `uuid`) (Optional)
        *   `quantity`: `integer` (Optional)

    *   **`Order`**
        *   `id`: `string` (format: `uuid`) (Required)
        *   `userId`: `string` (format: `uuid`) (Required)
        *   `storeId`: `string` (format: `uuid`) (Required)
        *   `totalAmount`: `number` (format: `float`) (Required)
        *   `status`: `string` (enum: `pending`, `completed`, `cancelled`; default: `pending`) (Required)
        *   `createdAt`: `string` (format: `date-time`) (Required)
        *   `updatedAt`: `string` (format: `date-time`) (Required)

    *   **`OrderCreate`**
        *   `userId`: `string` (format: `uuid`) (Required)
        *   `storeId`: `string` (format: `uuid`) (Required)
        *   `totalAmount`: `number` (format: `float`) (Required)
        *   `status`: `string` (enum: `pending`, `completed`, `cancelled`; default: `pending`) (Optional)

    *   **`OrderUpdate`**
        *   `userId`: `string` (format: `uuid`) (Optional)
        *   `storeId`: `string` (format: `uuid`) (Optional)
        *   `totalAmount`: `number` (format: `float`) (Optional)
        *   `status`: `string` (enum: `pending`, `completed`, `cancelled`) (Optional)

*   **0.3. Constraints and Simplifications based on API:**
    *   **Roles:** Only `admin` and `user` roles are supported by the API. The concept of `merchant` or `superAdmin` as distinct API roles is not present. Any "merchant" functionality in the app will be handled by `admin` users who are associated with a `storeId`.
    *   **Store Details:** The API `Store` model is minimal. Rich details like `description`, `logo`, `businessHours`, `ratings`, `verification` are not supported. UI will reflect this simplicity.
    *   **Product Details:** The API `Product` model is minimal. Details like `images` (beyond a single URL if `description` is used for it), `categories` (beyond a simple string if `name` is used for it), `variants`, `tags` are not explicitly supported.
    *   **Stock Details:** The API `Stock` model does not support `pricing` tiers.
    *   **Order Statuses:** Only `pending`, `completed`, `cancelled` are supported.
    *   **Dashboard Analytics:** The API does not provide endpoints for fetching aggregated dashboard data (e.g., total revenue, number of pending stores, top-selling products). Admin and Merchant dashboards will be built using individual CRUD operations and client-side aggregation where feasible, or will be simplified to list views.
    *   **Store Approval/Rejection:** No explicit API endpoints for this. This functionality will be removed from the plan.
    *   **User Management:** Limited to basic CRUD operations on `User` objects. No rich user profiles or specific merchant/admin flags beyond the `role` string.

---

**Phase 1: Core Model Definitions (API-Driven)**

**Objective:** Create Dart data models that precisely mirror the API's schema definitions. These models will be the foundation for all data exchange within the application.

*   **1.1. Create `User` Model:**
    *   **Purpose:** Represents a user in the system, as defined by the API.
    *   **File:** `lib/models/user/user_model.dart`
    *   **Content:**
        ```dart
        // lib/models/user/user_model.dart
        import 'package:equatable/equatable.dart';

        enum UserRole {
          admin,
          user,
          unknown; // Handle cases where role might not match expected enums

          factory UserRole.fromString(String role) {
            switch (role.toLowerCase()) {
              case 'admin':
                return UserRole.admin;
              case 'user':
                return UserRole.user;
              default:
                return UserRole.unknown;
            }
          }

          String toShortString() {
            return toString().split('.').last;
          }
        }

        class User extends Equatable {
          final String id;
          final String username;
          final String email;
          final UserRole role;
          final DateTime createdAt;
          final DateTime updatedAt;

          const User({
            required this.id,
            required this.username,
            required this.email,
            required this.role,
            required this.createdAt,
            required this.updatedAt,
          });

          factory User.fromJson(Map<String, dynamic> json) {
            return User(
              id: json['id'] as String,
              username: json['username'] as String,
              email: json['email'] as String,
              role: UserRole.fromString(json['role'] as String),
              createdAt: DateTime.parse(json['createdAt'] as String),
              updatedAt: DateTime.parse(json['updatedAt'] as String),
            );
          }

          Map<String, dynamic> toJson() {
            return {
              'id': id,
              'username': username,
              'email': email,
              'role': role.toShortString(),
              'createdAt': createdAt.toIso8601String(),
              'updatedAt': updatedAt.toIso8601String(),
            };
          }

          @override
          List<Object?> get props => [id, username, email, role, createdAt, updatedAt];
        }
        ```
    *   **Verification:** Ensure `User.fromJson` correctly parses API responses and `User.toJson` creates valid request bodies.

*   **1.2. Create `Store` Model:**
    *   **Purpose:** Represents a store in the system, as defined by the API.
    *   **File:** `lib/models/store/store_model.dart`
    *   **Content:**
        ```dart
        // lib/models/store/store_model.dart
        import 'package:equatable/equatable.dart';

        class Store extends Equatable {
          final String id;
          final String name;
          final String address;
          final DateTime createdAt;
          final DateTime updatedAt;

          const Store({
            required this.id,
            required this.name,
            required this.address,
            required this.createdAt,
            required this.updatedAt,
          });

          factory Store.fromJson(Map<String, dynamic> json) {
            return Store(
              id: json['id'] as String,
              name: json['name'] as String,
              address: json['address'] as String,
              createdAt: DateTime.parse(json['createdAt'] as String),
              updatedAt: DateTime.parse(json['updatedAt'] as String),
            );
          }

          Map<String, dynamic> toJson() {
            return {
              'id': id,
              'name': name,
              'address': address,
              'createdAt': createdAt.toIso8601String(),
              'updatedAt': updatedAt.toIso8601String(),
            };
          }

          @override
          List<Object?> get props => [id, name, address, createdAt, updatedAt];
        }
        ```
    *   **Verification:** Ensure `Store.fromJson` correctly parses API responses and `Store.toJson` creates valid request bodies.

*   **1.3. Create `Product` Model:**
    *   **Purpose:** Represents a product in the system, as defined by the API.
    *   **File:** `lib/models/product/product_model.dart` (Note: Renamed from `product.dart` for consistency)
    *   **Content:**
        ```dart
        // lib/models/product/product_model.dart
        import 'package:equatable/equatable.dart';

        class Product extends Equatable {
          final String id;
          final String name;
          final String description;
          final double price;
          final String storeId;
          final DateTime createdAt;
          final DateTime updatedAt;

          const Product({
            required this.id,
            required this.name,
            required this.description,
            required this.price,
            required this.storeId,
            required this.createdAt,
            required this.updatedAt,
          });

          factory Product.fromJson(Map<String, dynamic> json) {
            return Product(
              id: json['id'] as String,
              name: json['name'] as String,
              description: json['description'] as String,
              price: (json['price'] as num).toDouble(),
              storeId: json['storeId'] as String,
              createdAt: DateTime.parse(json['createdAt'] as String),
              updatedAt: DateTime.parse(json['updatedAt'] as String),
            );
          }

          Map<String, dynamic> toJson() {
            return {
              'id': id,
              'name': name,
              'description': description,
              'price': price,
              'storeId': storeId,
              'createdAt': createdAt.toIso8601String(),
              'updatedAt': updatedAt.toIso8601String(),
            };
          }

          @override
          List<Object?> get props => [id, name, description, price, storeId, createdAt, updatedAt];
        }
        ```
    *   **Verification:** Ensure `Product.fromJson` correctly parses API responses and `Product.toJson` creates valid request bodies.

*   **1.4. Create `Stock` Model:**
    *   **Purpose:** Represents a stock entry for a product in a store, as defined by the API.
    *   **File:** `lib/models/stock/stock_model.dart`
    *   **Content:**
        ```dart
        // lib/models/stock/stock_model.dart
        import 'package:equatable/equatable.dart';

        class Stock extends Equatable {
          final String id;
          final String productId;
          final String storeId;
          final int quantity;
          final DateTime createdAt;
          final DateTime updatedAt;

          const Stock({
            required this.id,
            required this.productId,
            required this.storeId,
            required this.quantity,
            required this.createdAt,
            required this.updatedAt,
          });

          factory Stock.fromJson(Map<String, dynamic> json) {
            return Stock(
              id: json['id'] as String,
              productId: json['productId'] as String,
              storeId: json['storeId'] as String,
              quantity: json['quantity'] as int,
              createdAt: DateTime.parse(json['createdAt'] as String),
                            updatedAt: DateTime.parse(json['updatedAt'] as String),
            );
          }

          Map<String, dynamic> toJson() {
            return {
              'id': id,
              'productId': productId,
              'storeId': storeId,
              'quantity': quantity,
              'createdAt': createdAt.toIso8601String(),
              'updatedAt': updatedAt.toIso8601String(),
            };
          }

          @override
          List<Object?> get props => [id, productId, storeId, quantity, createdAt, updatedAt];
        }
        ```
    *   **Verification:** Ensure `Stock.fromJson` correctly parses API responses and `Stock.toJson` creates valid request bodies.

*   **1.5. Create `Order` Model:**
    *   **Purpose:** Represents an order in the system, as defined by the API.
    *   **File:** `lib/models/order/order_model.dart` (Note: Renamed from `store_order_model.dart` for consistency with API)
    *   **Content:**
        ```dart
        // lib/models/order/order_model.dart
        import 'package:equatable/equatable.dart';

        enum OrderStatus {
          pending,
          completed,
          cancelled,
          unknown;

          factory OrderStatus.fromString(String status) {
            switch (status.toLowerCase()) {
              case 'pending':
                return OrderStatus.pending;
              case 'completed':
                return OrderStatus.completed;
              case 'cancelled':
                return OrderStatus.cancelled;
              default:
                return OrderStatus.unknown;
            }
          }

          String toShortString() {
            return toString().split('.').last;
          }
        }

        class Order extends Equatable {
          final String id;
          final String userId;
          final String storeId;
          final double totalAmount;
          final OrderStatus status;
          final DateTime createdAt;
          final DateTime updatedAt;

          const Order({
            required this.id,
            required this.userId,
            required this.storeId,
            required this.totalAmount,
            required this.status,
            required this.createdAt,
            required this.updatedAt,
          });

          factory Order.fromJson(Map<String, dynamic> json) {
            return Order(
              id: json['id'] as String,
              userId: json['userId'] as String,
              storeId: json['storeId'] as String,
              totalAmount: (json['totalAmount'] as num).toDouble(),
              status: OrderStatus.fromString(json['status'] as String),
              createdAt: DateTime.parse(json['createdAt'] as String),
              updatedAt: DateTime.parse(json['updatedAt'] as String),
            );
          }

          Map<String, dynamic> toJson() {
            return {
              'id': id,
              'userId': userId,
              'storeId': storeId,
              'totalAmount': totalAmount,
              'status': status.toShortString(),
              'createdAt': createdAt.toIso8601String(),
              'updatedAt': updatedAt.toIso8601String(),
            };
          }

          @override
          List<Object?> get props => [id, userId, storeId, totalAmount, status, createdAt, updatedAt];
        }
        ```
    *   **Verification:** Ensure `Order.fromJson` correctly parses API responses and `Order.toJson` creates valid request bodies.

*   **1.6. Create Request/Response Models for Auth:**
    *   **Purpose:** Models for authentication requests and responses.
    *   **File:** `lib/models/auth/auth_models.dart` (Consolidating for simplicity)
    *   **Content:**
        ```dart
        // lib/models/auth/auth_models.dart
        import 'package:equatable/equatable.dart';
        import '../user/user_model.dart'; // Import the User model

        // --- SignUp ---
        class SignUpRequest extends Equatable {
          final String username;
          final String email;
          final String password;

          const SignUpRequest({
            required this.username,
            required this.email,
            required this.password,
          });

          Map<String, dynamic> toJson() {
            return {
              'username': username,
              'email': email,
              'password': password,
            };
          }

          @override
          List<Object?> get props => [username, email, password];
        }

        class SignUpResponse extends Equatable {
          final String message;
          final User user;

          const SignUpResponse({
            required this.message,
            required this.user,
          });

          factory SignUpResponse.fromJson(Map<String, dynamic> json) {
            return SignUpResponse(
              message: json['message'] as String,
              user: User.fromJson(json['user'] as Map<String, dynamic>),
            );
          }

          @override
          List<Object?> get props => [message, user];
        }

        // --- SignIn ---
        class SignInRequest extends Equatable {
          final String email;
          final String password;

          const SignInRequest({
            required this.email,
            required this.password,
          });

          Map<String, dynamic> toJson() {
            return {
              'email': email,
              'password': password,
            };
          }

          @override
          List<Object?> get props => [email, password];
        }

        class SignInResponse extends Equatable {
          final String message;
          final String token;
          final User user;

          const SignInResponse({
            required this.message,
            required this.token,
            required this.user,
          });

          factory SignInResponse.fromJson(Map<String, dynamic> json) {
            return SignInResponse(
              message: json['message'] as String,
              token: json['token'] as String,
              user: User.fromJson(json['user'] as Map<String, dynamic>),
            );
          }

          @override
          List<Object?> get props => [message, token, user];
        }
        ```
    *   **Verification:** Ensure `fromJson` and `toJson` methods are correct.

*   **1.7. Create Request/Update Models for CRUD Operations:**
    *   **Purpose:** Models for creating and updating entities, as defined by the API.
    *   **File:** `lib/models/request_response_models.dart` (Consolidating for simplicity)
    *   **Content:**
        ```dart
        // lib/models/request_response_models.dart
        import 'package:equatable/equatable.dart';
        import 'user/user_model.dart'; // For UserRole enum
        import 'order/order_model.dart'; // For OrderStatus enum

        // --- User ---
        class UserCreateRequest extends Equatable {
          final String username;
          final String email;
          final String password;
          final UserRole? role; // Optional in API, default 'user'

          const UserCreateRequest({
            required this.username,
            required this.email,
            required this.password,
            this.role,
          });

          Map<String, dynamic> toJson() {
            return {
              'username': username,
              'email': email,
              'password': password,
              if (role != null) 'role': role!.toShortString(),
            };
          }

          @override
          List<Object?> get props => [username, email, password, role];
        }

        class UserUpdateRequest extends Equatable {
          final String? username;
          final String? email;
          final String? password;
          final UserRole? role;

          const UserUpdateRequest({
            this.username,
            this.email,
            this.password,
            this.role,
          });

          Map<String, dynamic> toJson() {
            return {
              if (username != null) 'username': username,
              if (email != null) 'email': email,
              if (password != null) 'password': password,
              if (role != null) 'role': role!.toShortString(),
            };
          }

          @override
          List<Object?> get props => [username, email, password, role];
        }

        // --- Store ---
        class StoreCreateRequest extends Equatable {
          final String name;
          final String address;

          const StoreCreateRequest({
            required this.name,
            required this.address,
          });

          Map<String, dynamic> toJson() {
            return {
              'name': name,
              'address': address,
            };
          }

          @override
          List<Object?> get props => [name, address];
        }

        class StoreUpdateRequest extends Equatable {
          final String? name;
          final String? address;

          const StoreUpdateRequest({
            this.name,
            this.address,
          });

          Map<String, dynamic> toJson() {
            return {
              if (name != null) 'name': name,
              if (address != null) 'address': address,
            };
          }

          @override
          List<Object?> get props => [name, address];
        }

        // --- Product ---
        class ProductCreateRequest extends Equatable {
          final String name;
          final String description;
          final double price;
          final String storeId;

          const ProductCreateRequest({
            required this.name,
            required this.description,
            required this.price,
            required this.storeId,
          });

          Map<String, dynamic> toJson() {
            return {
              'name': name,
              'description': description,
              'price': price,
              'storeId': storeId,
            };
          }

          @override
          List<Object?> get props => [name, description, price, storeId];
        }

        class ProductUpdateRequest extends Equatable {
          final String? name;
          final String? description;
          final double? price;
          final String? storeId;

          const ProductUpdateRequest({
            this.name,
            this.description,
            this.price,
            this.storeId,
          });

          Map<String, dynamic> toJson() {
            return {
              if (name != null) 'name': name,
              if (description != null) 'description': description,
              if (price != null) 'price': price,
              if (storeId != null) 'storeId': storeId,
            };
          }

          @override
          List<Object?> get props => [name, description, price, storeId];
        }

        // --- Stock ---
        class StockCreateRequest extends Equatable {
          final String productId;
          final String storeId;
          final int quantity;

          const StockCreateRequest({
            required this.productId,
            required this.storeId,
            required this.quantity,
          });

          Map<String, dynamic> toJson() {
            return {
              'productId': productId,
              'storeId': storeId,
              'quantity': quantity,
            };
          }

          @override
          List<Object?> get props => [productId, storeId, quantity];
        }

        class StockUpdateRequest extends Equatable {
          final String? productId;
          final String? storeId;
          final int? quantity;

          const StockUpdateRequest({
            this.productId,
            this.storeId,
            this.quantity,
          });

          Map<String, dynamic> toJson() {
            return {
              if (productId != null) 'productId': productId,
              if (storeId != null) 'storeId': storeId,
              if (quantity != null) 'quantity': quantity,
            };
          }

          @override
          List<Object?> get props => [productId, storeId, quantity];
        }

        // --- Order ---
        class OrderCreateRequest extends Equatable {
          final String userId;
          final String storeId;
          final double totalAmount;
          final OrderStatus? status; // Optional in API, default 'pending'

          const OrderCreateRequest({
            required this.userId,
            required this.storeId,
            required this.totalAmount,
            this.status,
          });

          Map<String, dynamic> toJson() {
            return {
              'userId': userId,
              'storeId': storeId,
              'totalAmount': totalAmount,
              if (status != null) 'status': status!.toShortString(),
            };
          }

          @override
          List<Object?> get props => [userId, storeId, totalAmount, status];
        }

        class OrderUpdateRequest extends Equatable {
          final String? userId;
          final String? storeId;
          final double? totalAmount;
          final OrderStatus? status;

          const OrderUpdateRequest({
            this.userId,
            this.storeId,
            this.totalAmount,
            this.status,
          });

          Map<String, dynamic> toJson() {
            return {
              if (userId != null) 'userId': userId,
              if (storeId != null) 'storeId': storeId,
              if (totalAmount != null) 'totalAmount': totalAmount,
              if (status != null) 'status': status!.toShortString(),
            };
          }

          @override
          List<Object?> get props => [userId, storeId, totalAmount, status];
        }
        ```
    *   **Verification:** Ensure `toJson` methods are correct.

---

**Phase 2: API Services Implementation (API-Driven)**

**Objective:** Create API service classes to handle HTTP requests, strictly adhering to the API endpoints and using the defined models. These services will interact with the `NetworkingManager`.

*   **2.1. Update `ApiEndpoints`:**
    *   **Purpose:** Centralize API endpoint paths.
    *   **File:** `lib/utils/api_endpoints.dart`
    *   **Content Modification (add/update constants):**
        ```dart
        // lib/utils/api_endpoints.dart
        class ApiEndpoints {
          static const String baseUrl = 'https://store-backend-eta.vercel.app'; // Base URL for the API

          // Auth
          static const String signUp = '/auth/signup';
          static const String signIn = '/auth/signin';

          // Users
          static const String users = '/users';

          // Stores
          static const String stores = '/stores';

          // Products
          static const String products = '/products';

          // Stock
          static const String stock = '/stock';

          // Orders
          static const String orders = '/orders';
        }
        ```
    *   **Verification:** Confirm all necessary endpoints are listed.

*   **2.2. Create `AuthApiService`:**
    *   **Purpose:** Handles user authentication (signup, signin).
    *   **File:** `lib/services/auth_api_service.dart`
    *   **Content:**
        ```dart
        // lib/services/auth_api_service.dart
        import 'package:get_it/get_it.dart';
        import '../models/auth/auth_models.dart';
        import '../utils/api_endpoints.dart';
        import '../utils/networking_manager.dart';

        class AuthApiService {
          final NetworkingManager _networkingManager = GetIt.instance<NetworkingManager>();

          /// Registers a new user.
          /// Throws an exception if the API call fails.
          Future<SignUpResponse> signUp(SignUpRequest request) async {
            try {
              final response = await _networkingManager.post(
                endpoint: ApiEndpoints.signUp,
                body: request.toJson(),
              );
              return SignUpResponse.fromJson(response);
            } catch (e) {
              throw Exception('Failed to sign up: $e');
            }
          }

          /// Signs in a user and returns authentication token and user details.
          /// Throws an exception if the API call fails.
          Future<SignInResponse> signIn(SignInRequest request) async {
            try {
              final response = await _networkingManager.post(
                endpoint: ApiEndpoints.signIn,
                body: request.toJson(),
              );
              return SignInResponse.fromJson(response);
            } catch (e) {
              throw Exception('Failed to sign in: $e');
            }
          }
        }
        ```
    *   **Verification:** Test with valid/invalid credentials. Ensure token and user data are returned.

*   **2.3. Create `UsersApiService`:**
    *   **Purpose:** Handles CRUD operations for users.
    *   **File:** `lib/services/users_api_service.dart`
    *   **Content:**
        ```dart
        // lib/services/users_api_service.dart
        import 'package:get_it/get_it.dart';
        import '../models/user/user_model.dart';
        import '../models/request_response_models.dart';
        import '../utils/api_endpoints.dart';
        import '../utils/networking_manager.dart';

        class UsersApiService {
          final NetworkingManager _networkingManager = GetIt.instance<NetworkingManager>();

          /// Fetches all users.
          Future<List<User>> getUsers() async {
            try {
              final response = await _networkingManager.get(endpoint: ApiEndpoints.users);
              return (response as List).map((e) => User.fromJson(e)).toList();
            } catch (e) {
              throw Exception('Failed to get users: $e');
            }
          }

          /// Fetches a single user by ID.
          Future<User> getUserById(String id) async {
            try {
              final response = await _networkingManager.get(endpoint: '${ApiEndpoints.users}/$id');
              return User.fromJson(response);
            } catch (e) {
              throw Exception('Failed to get user: $e');
            }
          }

          /// Creates a new user.
          Future<User> createUser(UserCreateRequest request) async {
            try {
              final response = await _networkingManager.post(
                endpoint: ApiEndpoints.users,
                body: request.toJson(),
              );
              return User.fromJson(response);
            } catch (e) {
              throw Exception('Failed to create user: $e');
            }
          }

          /// Updates an existing user.
          Future<User> updateUser(String id, UserUpdateRequest request) async {
            try {
              final response = await _networkingManager.put(
                endpoint: '${ApiEndpoints.users}/$id',
                body: request.toJson(),
              );
              return User.fromJson(response);
            } catch (e) {
              throw Exception('Failed to update user: $e');
            }
          }

          /// Deletes a user by ID.
          Future<void> deleteUser(String id) async {
            try {
              await _networkingManager.delete(endpoint: '${ApiEndpoints.users}/$id');
            } catch (e) {
              throw Exception('Failed to delete user: $e');
            }
          }
        }
        ```
    *   **Verification:** Test each CRUD operation.

*   **2.4. Create `StoresApiService`:**
    *   **Purpose:** Handles CRUD operations for stores.
    *   **File:** `lib/services/stores_api_service.dart`
    *   **Content:**
        ```dart
        // lib/services/stores_api_service.dart
        import 'package:get_it/get_it.dart';
        import '../models/store/store_model.dart';
        import '../models/request_response_models.dart';
        import '../utils/api_endpoints.dart';
        import '../utils/networking_manager.dart';

        class StoresApiService {
          final NetworkingManager _networkingManager = GetIt.instance<NetworkingManager>();

          /// Fetches all stores.
          Future<List<Store>> getStores() async {
            try {
              final response = await _networkingManager.get(endpoint: ApiEndpoints.stores);
              return (response as List).map((e) => Store.fromJson(e)).toList();
            } catch (e) {
              throw Exception('Failed to get stores: $e');
            }
          }

          /// Fetches a single store by ID.
          Future<Store> getStoreById(String id) async {
            try {
              final response = await _networkingManager.get(endpoint: '${ApiEndpoints.stores}/$id');
              return Store.fromJson(response);
            } catch (e) {
              throw Exception('Failed to get store: $e');
            }
          }

          /// Creates a new store.
          Future<Store> createStore(StoreCreateRequest request) async {
            try {
              final response = await _networkingManager.post(
                endpoint: ApiEndpoints.stores,
                body: request.toJson(),
              );
              return Store.fromJson(response);
            } catch (e) {
              throw Exception('Failed to create store: $e');
            }
          }

          /// Updates an existing store.
          Future<Store> updateStore(String id, StoreUpdateRequest request) async {
            try {
              final response = await _networkingManager.put(
                endpoint: '${ApiEndpoints.stores}/$id',
                body: request.toJson(),
              );
              return Store.fromJson(response);
            } catch (e) {
              throw Exception('Failed to update store: $e');
            }
          }

          /// Deletes a store by ID.
          Future<void> deleteStore(String id) async {
            try {
              await _networkingManager.delete(endpoint: '${ApiEndpoints.stores}/$id');
            } catch (e) {
              throw Exception('Failed to delete store: $e');
            }
          }
        }
        ```
    *   **Verification:** Test each CRUD operation.

*   **2.5. Create `ProductsApiService`:**
    *   **Purpose:** Handles CRUD operations for products, including filtering by store.
    *   **File:** `lib/services/products_api_service.dart`
    *   **Content:**
        ```dart
        // lib/services/products_api_service.dart
        import 'package:get_it/get_it.dart';
        import '../models/product/product_model.dart';
        import '../models/request_response_models.dart';
        import '../utils/api_endpoints.dart';
        import '../utils/networking_manager.dart';

        class ProductsApiService {
          final NetworkingManager _networkingManager = GetIt.instance<NetworkingManager>();

          /// Fetches all products, optionally filtered by storeId.
          Future<List<Product>> getProducts({String? storeId}) async {
            try {
              final queryParameters = storeId != null ? {'storeId': storeId} : null;
              final response = await _networkingManager.get(
                endpoint: ApiEndpoints.products,
                queryParameters: queryParameters,
              );
              return (response as List).map((e) => Product.fromJson(e)).toList();
            } catch (e) {
              throw Exception('Failed to get products: $e');
            }
          }

          /// Fetches a single product by ID.
          Future<Product> getProductById(String id) async {
            try {
              final response = await _networkingManager.get(endpoint: '${ApiEndpoints.products}/$id');
              return Product.fromJson(response);
            } catch (e) {
              throw Exception('Failed to get product: $e');
            }
          }

          /// Creates a new product.
          Future<Product> createProduct(ProductCreateRequest request) async {
            try {
              final response = await _networkingManager.post(
                endpoint: ApiEndpoints.products,
                body: request.toJson(),
              );
              return Product.fromJson(response);
            } catch (e) {
              throw Exception('Failed to create product: $e');
            }
          }

          /// Updates an existing product.
          Future<Product> updateProduct(String id, ProductUpdateRequest request) async {
            try {
              final response = await _networkingManager.put(
                endpoint: '${ApiEndpoints.products}/$id',
                body: request.toJson(),
              );
              return Product.fromJson(response);
            } catch (e) {
              throw Exception('Failed to update product: $e');
            }
          }

          /// Deletes a product by ID.
          Future<void> deleteProduct(String id) async {
            try {
              await _networkingManager.delete(endpoint: '${ApiEndpoints.products}/$id');
            } catch (e) {
              throw Exception('Failed to delete product: $e');
            }
          }
        }
        ```
    *   **Verification:** Test each CRUD operation and filtering by `storeId`.

*   **2.6. Create `StockApiService`:**
    *   **Purpose:** Handles CRUD operations for stock entries, including filtering.
    *   **File:** `lib/services/stock_api_service.dart`
    *   **Content:**
        ```dart
        // lib/services/stock_api_service.dart
        import 'package:get_it/get_it.dart';
        import '../models/stock/stock_model.dart';
        import '../models/request_response_models.dart';
        import '../utils/api_endpoints.dart';
        import '../utils/networking_manager.dart';

        class StockApiService {
          final NetworkingManager _networkingManager = GetIt.instance<NetworkingManager>();

          /// Fetches all stock entries, optionally filtered by storeId or productId.
          Future<List<Stock>> getStocks({String? storeId, String? productId}) async {
            try {
              final queryParameters = <String, dynamic>{};
              if (storeId != null) queryParameters['storeId'] = storeId;
              if (productId != null) queryParameters['productId'] = productId;

              final response = await _networkingManager.get(
                endpoint: ApiEndpoints.stock,
                queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
              );
              return (response as List).map((e) => Stock.fromJson(e)).toList();
            } catch (e) {
              throw Exception('Failed to get stock entries: $e');
            }
          }

          /// Fetches a single stock entry by ID.
          Future<Stock> getStockById(String id) async {
            try {
              final response = await _networkingManager.get(endpoint: '${ApiEndpoints.stock}/$id');
              return Stock.fromJson(response);
            } catch (e) {
              throw Exception('Failed to get stock entry: $e');
            }
          }

          /// Creates a new stock entry.
          Future<Stock> createStock(StockCreateRequest request) async {
            try {
              final response = await _networkingManager.post(
                endpoint: ApiEndpoints.stock,
                body: request.toJson(),
              );
              return Stock.fromJson(response);
            } catch (e) {
              throw Exception('Failed to create stock entry: $e');
            }
          }

          /// Updates an existing stock entry.
          Future<Stock> updateStock(String id, StockUpdateRequest request) async {
            try {
              final response = await _networkingManager.put(
                endpoint: '${ApiEndpoints.stock}/$id',
                body: request.toJson(),
              );
              return Stock.fromJson(response);
            } catch (e) {
              throw Exception('Failed to update stock entry: $e');
            }
          }

          /// Deletes a stock entry by ID.
          Future<void> deleteStock(String id) async {
            try {
              await _networkingManager.delete(endpoint: '${ApiEndpoints.stock}/$id');
            } catch (e) {
              throw Exception('Failed to delete stock entry: $e');
            }
          }
        }
        ```
    *   **Verification:** Test each CRUD operation and filtering.

*   **2.7. Create `OrdersApiService`:**
    *   **Purpose:** Handles CRUD operations for orders, including filtering.
    *   **File:** `lib/services/orders_api_service.dart`
    *   **Content:**
        ```dart
        // lib/services/orders_api_service.dart
        import 'package:get_it/get_it.dart';
        import '../models/order/order_model.dart';
        import '../models/request_response_models.dart';
        import '../utils/api_endpoints.dart';
        import '../utils/networking_manager.dart';

        class OrdersApiService {
          final NetworkingManager _networkingManager = GetIt.instance<NetworkingManager>();

          /// Fetches all orders, optionally filtered by userId or storeId.
          Future<List<Order>> getOrders({String? userId, String? storeId}) async {
            try {
              final queryParameters = <String, dynamic>{};
              if (userId != null) queryParameters['userId'] = userId;
              if (storeId != null) queryParameters['storeId'] = storeId;

              final response = await _networkingManager.get(
                endpoint: ApiEndpoints.orders,
                queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
              );
              return (response as List).map((e) => Order.fromJson(e)).toList();
            } catch (e) {
              throw Exception('Failed to get orders: $e');
            }
          }

          /// Fetches a single order by ID.
          Future<Order> getOrderById(String id) async {
            try {
              final response = await _networkingManager.get(endpoint: '${ApiEndpoints.orders}/$id');
              return Order.fromJson(response);
            } catch (e) {
              throw Exception('Failed to get order: $e');
            }
          }

          /// Creates a new order.
          Future<Order> createOrder(OrderCreateRequest request) async {
            try {
              final response = await _networkingManager.post(
                endpoint: ApiEndpoints.orders,
                body: request.toJson(),
              );
              return Order.fromJson(response);
            } catch (e) {
              throw Exception('Failed to create order: $e');
            }
          }

          /// Updates an existing order.
          Future<Order> updateOrder(String id, OrderUpdateRequest request) async {
            try {
              final response = await _networkingManager.put(
                endpoint: '${ApiEndpoints.orders}/$id',
                body: request.toJson(),
              );
              return Order.fromJson(response);
            } catch (e) {
              throw Exception('Failed to update order: $e');
            }
          }

          /// Deletes an order by ID.
          Future<void> deleteOrder(String id) async {
            try {
              await _networkingManager.delete(endpoint: '${ApiEndpoints.orders}/$id');
            } catch (e) {
              throw Exception('Failed to delete order: $e');
            }
          }
        }
        ```
    *   **Verification:** Test each CRUD operation and filtering.

---

**Phase 3: Repositories Implementation (API-Driven)**

**Objective:** Create repository classes to abstract API service calls, providing a clean interface for BLoCs and handling data caching or local storage if needed (though not explicitly in API spec, so focusing on API calls).

*   **3.1. Create `AuthRepository`:**
    *   **Purpose:** Manages user authentication state and token persistence.
    *   **File:** `lib/repositories/auth_repository.dart`
    *   **Content:**
        ```dart
        // lib/repositories/auth_repository.dart
        import 'package:get_it/get_it.dart';
        import 'package:shared_preferences/shared_preferences.dart';
        import 'dart:convert'; // For json.encode/decode

        import '../models/auth/auth_models.dart';
        import '../models/user/user_model.dart';
        import '../services/auth_api_service.dart';

        class AuthRepository {
          final AuthApiService _authApiService = GetIt.instance<AuthApiService>();
          User? _currentUser;
          String? _authToken;

          User? get currentUser => _currentUser;
          String? get authToken => _authToken;

          /// Initializes the repository by loading user and token from local storage.
          Future<void> init() async {
            final prefs = await SharedPreferences.getInstance();
            final userJson = prefs.getString('currentUser');
            final token = prefs.getString('authToken');

            if (userJson != null && token != null) {
              _currentUser = User.fromJson(json.decode(userJson));
              _authToken = token;
            }
          }

          /// Registers a new user.
          Future<User> signUp(SignUpRequest request) async {
            try {
              final response = await _authApiService.signUp(request);
              // For signup, we don't automatically sign in or store token
              return response.user;
            } catch (e) {
              rethrow;
            }
          }

          /// Signs in a user, stores token and user data locally.
          Future<User> signIn(SignInRequest request) async {
            try {
              final response = await _authApiService.signIn(request);
              _currentUser = response.user;
              _authToken = response.token;

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
              await prefs.setString('authToken', _authToken!);
              return _currentUser!;
            } catch (e) {
              rethrow;
            }
          }

          /// Logs out the current user and clears local storage.
          Future<void> signOut() async {
            _currentUser = null;
            _authToken = null;
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('currentUser');
            await prefs.remove('authToken');
          }

          /// Checks if a user is currently authenticated.
          bool isAuthenticated() {
            return _authToken != null && _currentUser != null;
          }

          /// Checks if the current user has admin role.
          bool isAdmin() {
            return _currentUser?.role == UserRole.admin;
          }
        }
        ```
    *   **Verification:** Test signup, signin, signout, and `isAuthenticated`/`isAdmin` methods.

*   **3.2. Create `UsersRepository`:**
    *   **Purpose:** Provides an interface for user-related operations.
    *   **File:** `lib/repositories/users_repository.dart`
    *   **Content:**
        ```dart
        // lib/repositories/users_repository.dart
        import 'package:get_it/get_it.dart';
        import '../models/user/user_model.dart';
        import '../models/request_response_models.dart';
        import '../services/users_api_service.dart';

        class UsersRepository {
          final UsersApiService _usersApiService = GetIt.instance<UsersApiService>();

          Future<List<User>> getUsers() async {
            return _usersApiService.getUsers();
          }

          Future<User> getUserById(String id) async {
            return _usersApiService.getUserById(id);
          }

          Future<User> createUser(UserCreateRequest request) async {
            return _usersApiService.createUser(request);
          }

          Future<User> updateUser(String id, UserUpdateRequest request) async {
            return _usersApiService.updateUser(id, request);
          }

          Future<void> deleteUser(String id) async {
            return _usersApiService.deleteUser(id);
          }
        }
        ```
    *   **Verification:** Test each method.

*   **3.3. Create `StoresRepository`:**
    *   **Purpose:** Provides an interface for store-related operations.
    *   **File:** `lib/repositories/stores_repository.dart`
    *   **Content:**
        ```dart
        // lib/repositories/stores_repository.dart
        import 'package:get_it/get_it.dart';
        import '../models/store/store_model.dart';
        import '../models/request_response_models.dart';
        import '../services/stores_api_service.dart';

        class StoresRepository {
          final StoresApiService _storesApiService = GetIt.instance<StoresApiService>();

          Future<List<Store>> getStores() async {
            return _storesApiService.getStores();
          }

          Future<Store> getStoreById(String id) async {
            return _storesApiService.getStoreById(id);
          }

          Future<Store> createStore(StoreCreateRequest request) async {
            return _storesApiService.createStore(request);
          }

          Future<Store> updateStore(String id, StoreUpdateRequest request) async {
            return _storesApiService.updateStore(id, request);
          }

          Future<void> deleteStore(String id) async {
            return _storesApiService.deleteStore(id);
          }
        }
        ```
    *   **Verification:** Test each method.

*   **3.4. Create `ProductsRepository`:**
    *   **Purpose:** Provides an interface for product-related operations.
    *   **File:** `lib/repositories/products_repository.dart`
    *   **Content:**
        ```dart
        // lib/repositories/products_repository.dart
        import 'package:get_it/get_it.dart';
        import '../models/product/product_model.dart';
        import '../models/request_response_models.dart';
        import '../services/products_api_service.dart';

        class ProductsRepository {
          final ProductsApiService _productsApiService = GetIt.instance<ProductsApiService>();

          Future<List<Product>> getProducts({String? storeId}) async {
            return _productsApiService.getProducts(storeId: storeId);
          }

          Future<Product> getProductById(String id) async {
            return _productsApiService.getProductById(id);
          }

          Future<Product> createProduct(ProductCreateRequest request) async {
            return _productsApiService.createProduct(request);
          }

          Future<Product> updateProduct(String id, ProductUpdateRequest request) async {
            return _productsApiService.updateProduct(id, request);
          }

          Future<void> deleteProduct(String id) async {
            return _productsApiService.deleteProduct(id);
          }
        }
        ```
    *   **Verification:** Test each method, including `storeId` filtering.

*   **3.5. Create `StockRepository`:**
    *   **Purpose:** Provides an interface for stock-related operations.
    *   **File:** `lib/repositories/stock_repository.dart`
    *   **Content:**
        ```dart
        // lib/repositories/stock_repository.dart
        import 'package:get_it/get_it.dart';
        import '../models/stock/stock_model.dart';
        import '../models/request_response_models.dart';
        import '../services/stock_api_service.dart';

        class StockRepository {
          final StockApiService _stockApiService = GetIt.instance<StockApiService>();

          Future<List<Stock>> getStocks({String? storeId, String? productId}) async {
            return _stockApiService.getStocks(storeId: storeId, productId: productId);
          }

          Future<Stock> getStockById(String id) async {
            return _stockApiService.getStockById(id);
          }

          Future<Stock> createStock(StockCreateRequest request) async {
            return _stockApiService.createStock(request);
          }

          Future<Stock> updateStock(String id, StockUpdateRequest request) async {
            return _stockApiService.updateStock(id, request);
          }

          Future<void> deleteStock(String id) async {
            return _stockApiService.deleteStock(id);
          }
        }
        ```
    *   **Verification:** Test each method, including filtering.

*   **3.6. Create `OrdersRepository`:**
    *   **Purpose:** Provides an interface for order-related operations.
    *   **File:** `lib/repositories/orders_repository.dart`
    *   **Content:**
        ```dart
        // lib/repositories/orders_repository.dart
        import 'package:get_it/get_it.dart';
        import '../models/order/order_model.dart';
        import '../models/request_response_models.dart';
        import '../services/orders_api_service.dart';

        class OrdersRepository {
          final OrdersApiService _ordersApiService = GetIt.instance<OrdersApiService>();

          Future<List<Order>> getOrders({String? userId, String? storeId}) async {
            return _ordersApiService.getOrders(userId: userId, storeId: storeId);
          }

          Future<Order> getOrderById(String id) async {
            return _ordersApiService.getOrderById(id);
          }

          Future<Order> createOrder(OrderCreateRequest request) async {
            return _ordersApiService.createOrder(request);
          }

          Future<Order> updateOrder(String id, OrderUpdateRequest request) async {
            return _ordersApiService.updateOrder(id, request);
          }

          Future<void> deleteOrder(String id) async {
            return _ordersApiService.deleteOrder(id);
          }
        }
        ```
    *   **Verification:** Test each method, including filtering.

---

**Phase 4: BLoCs Implementation (Admin & Merchant - API-Driven)**

**Objective:** Create BLoC components for Admin and (simplified) Merchant features. These BLoCs will interact with the repositories and manage the UI state. Given the API limitations, "merchant" functionality will be a subset of "admin" functionality, focused on a specific store.

*   **4.1. Admin User Management BLoC:**
    *   **Purpose:** Manages state for listing, creating, updating, and deleting users.
    *   **Action:** Create directory `lib/bloc/admin/user_management` if it doesn't exist.
    *   **4.1.1. `admin_user_event.dart`:**
        ```dart
        // lib/bloc/admin/user_management/admin_user_event.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/request_response_models.dart';
        import '../../../models/user/user_model.dart';

        abstract class AdminUserEvent extends Equatable {
          const AdminUserEvent();

          @override
          List<Object?> get props => [];
        }

        class LoadAdminUsers extends AdminUserEvent {}

        class AddAdminUser extends AdminUserEvent {
          final UserCreateRequest userRequest;
          const AddAdminUser(this.userRequest);
          @override
          List<Object?> get props => [userRequest];
        }

        class UpdateAdminUser extends AdminUserEvent {
          final String id;
          final UserUpdateRequest userRequest;
          const UpdateAdminUser({required this.id, required this.userRequest});
          @override
          List<Object?> get props => [id, userRequest];
        }

        class DeleteAdminUser extends AdminUserEvent {
          final String id;
          const DeleteAdminUser(this.id);
          @override
          List<Object?> get props => [id];
        }
        ```
    *   **4.1.2. `admin_user_state.dart`:**
        ```dart
        // lib/bloc/admin/user_management/admin_user_state.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/user/user_model.dart';

        enum AdminUserStatus { initial, loading, success, failure }

        class AdminUserState extends Equatable {
          final AdminUserStatus status;
          final List<User> users;
          final String? errorMessage;

          const AdminUserState({
            this.status = AdminUserStatus.initial,
            this.users = const [],
            this.errorMessage,
          });

          AdminUserState copyWith({
            AdminUserStatus? status,
            List<User>? users,
            String? errorMessage,
          }) {
            return AdminUserState(
              status: status ?? this.status,
              users: users ?? this.users,
              errorMessage: errorMessage ?? this.errorMessage,
            );
          }

          @override
          List<Object?> get props => [status, users, errorMessage];
        }
        ```
    *   **4.1.3. `admin_user_bloc.dart`:**
        ```dart
        // lib/bloc/admin/user_management/admin_user_bloc.dart
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:get_it/get_it.dart';
        import 'admin_user_event.dart';
        import 'admin_user_state.dart';
        import '../../../repositories/users_repository.dart';
        import '../../../models/user/user_model.dart';

        class AdminUserBloc extends Bloc<AdminUserEvent, AdminUserState> {
          final UsersRepository _usersRepository = GetIt.instance<UsersRepository>();

          AdminUserBloc() : super(const AdminUserState()) {
            on<LoadAdminUsers>(_onLoadAdminUsers);
            on<AddAdminUser>(_onAddAdminUser);
            on<UpdateAdminUser>(_onUpdateAdminUser);
            on<DeleteAdminUser>(_onDeleteAdminUser);
          }

          Future<void> _onLoadAdminUsers(LoadAdminUsers event, Emitter<AdminUserState> emit) async {
            emit(state.copyWith(status: AdminUserStatus.loading));
            try {
              final users = await _usersRepository.getUsers();
              emit(state.copyWith(status: AdminUserStatus.success, users: users));
            } catch (e) {
              emit(state.copyWith(status: AdminUserStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onAddAdminUser(AddAdminUser event, Emitter<AdminUserState> emit) async {
            emit(state.copyWith(status: AdminUserStatus.loading));
            try {
              final newUser = await _usersRepository.createUser(event.userRequest);
              final updatedUsers = List<User>.from(state.users)..add(newUser);
              emit(state.copyWith(status: AdminUserStatus.success, users: updatedUsers));
            } catch (e) {
              emit(state.copyWith(status: AdminUserStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onUpdateAdminUser(UpdateAdminUser event, Emitter<AdminUserState> emit) async {
            emit(state.copyWith(status: AdminUserStatus.loading));
            try {
              final updatedUser = await _usersRepository.updateUser(event.id, event.userRequest);
              final updatedUsers = state.users.map((user) => user.id == updatedUser.id ? updatedUser : user).toList();
              emit(state.copyWith(status: AdminUserStatus.success, users: updatedUsers));
            } catch (e) {
              emit(state.copyWith(status: AdminUserStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onDeleteAdminUser(DeleteAdminUser event, Emitter<AdminUserState> emit) async {
            emit(state.copyWith(status: AdminUserStatus.loading));
            try {
              await _usersRepository.deleteUser(event.id);
              final updatedUsers = state.users.where((user) => user.id != event.id).toList();
              emit(state.copyWith(status: AdminUserStatus.success, users: updatedUsers));
            } catch (e) {
              emit(state.copyWith(status: AdminUserStatus.failure, errorMessage: e.toString()));
            }
          }
        }
        ```

*   **4.2. Admin Store Management BLoC:**
    *   **Purpose:** Manages state for listing, creating, updating, and deleting stores.
    *   **Action:** Create directory `lib/bloc/admin/store_management` if it doesn't exist.
    *   **4.2.1. `admin_store_event.dart`:**
        ```dart
        // lib/bloc/admin/store_management/admin_store_event.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/request_response_models.dart';
        import '../../../models/store/store_model.dart';

        abstract class AdminStoreEvent extends Equatable {
          const AdminStoreEvent();

          @override
          List<Object?> get props => [];
        }

        class LoadAdminStores extends AdminStoreEvent {}

        class AddAdminStore extends AdminStoreEvent {
          final StoreCreateRequest storeRequest;
          const AddAdminStore(this.storeRequest);
          @override
          List<Object?> get props => [storeRequest];
        }

        class UpdateAdminStore extends AdminStoreEvent {
          final String id;
          final StoreUpdateRequest storeRequest;
          const UpdateAdminStore({required this.id, required this.storeRequest});
          @override
          List<Object?> get props => [id, storeRequest];
        }

        class DeleteAdminStore extends AdminStoreEvent {
          final String id;
          const DeleteAdminStore(this.id);
          @override
          List<Object?> get props => [id];
        }
        ```
    *   **4.2.2. `admin_store_state.dart`:**
        ```dart
        // lib/bloc/admin/store_management/admin_store_state.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/store/store_model.dart';

        enum AdminStoreStatus { initial, loading, success, failure }

        class AdminStoreState extends Equatable {
          final AdminStoreStatus status;
          final List<Store> stores;
          final String? errorMessage;

          const AdminStoreState({
            this.status = AdminStoreStatus.initial,
            this.stores = const [],
            this.errorMessage,
          });

          AdminStoreState copyWith({
            AdminStoreStatus? status,
            List<Store>? stores,
            String? errorMessage,
          }) {
            return AdminStoreState(
              status: status ?? this.status,
              stores: stores ?? this.stores,
              errorMessage: errorMessage ?? this.errorMessage,
            );
          }

          @override
          List<Object?> get props => [status, stores, errorMessage];
        }
        ```
    *   **4.2.3. `admin_store_bloc.dart`:**
        ```dart
        // lib/bloc/admin/store_management/admin_store_bloc.dart
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:get_it/get_it.dart';
        import 'admin_store_event.dart';
        import 'admin_store_state.dart';
        import '../../../repositories/stores_repository.dart';
        import '../../../models/store/store_model.dart';

        class AdminStoreBloc extends Bloc<AdminStoreEvent, AdminStoreState> {
          final StoresRepository _storesRepository = GetIt.instance<StoresRepository>();

          AdminStoreBloc() : super(const AdminStoreState()) {
            on<LoadAdminStores>(_onLoadAdminStores);
            on<AddAdminStore>(_onAddAdminStore);
            on<UpdateAdminStore>(_onUpdateAdminStore);
            on<DeleteAdminStore>(_onDeleteAdminStore);
          }

          Future<void> _onLoadAdminStores(LoadAdminStores event, Emitter<AdminStoreState> emit) async {
            emit(state.copyWith(status: AdminStoreStatus.loading));
            try {
              final stores = await _storesRepository.getStores();
              emit(state.copyWith(status: AdminStoreStatus.success, stores: stores));
            } catch (e) {
              emit(state.copyWith(status: AdminStoreStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onAddAdminStore(AddAdminStore event, Emitter<AdminStoreState> emit) async {
            emit(state.copyWith(status: AdminStoreStatus.loading));
            try {
              final newStore = await _storesRepository.createStore(event.storeRequest);
              final updatedStores = List<Store>.from(state.stores)..add(newStore);
              emit(state.copyWith(status: AdminStoreStatus.success, stores: updatedStores));
            } catch (e) {
              emit(state.copyWith(status: AdminStoreStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onUpdateAdminStore(UpdateAdminStore event, Emitter<AdminStoreState> emit) async {
            emit(state.copyWith(status: AdminStoreStatus.loading));
            try {
              final updatedStore = await _storesRepository.updateStore(event.id, event.storeRequest);
              final updatedStores = state.stores.map((store) => store.id == updatedStore.id ? updatedStore : store).toList();
              emit(state.copyWith(status: AdminStoreStatus.success, stores: updatedStores));
            } catch (e) {
              emit(state.copyWith(status: AdminStoreStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onDeleteAdminStore(DeleteAdminStore event, Emitter<AdminStoreState> emit) async {
            emit(state.copyWith(status: AdminStoreStatus.loading));
            try {
              await _storesRepository.deleteStore(event.id);
              final updatedStores = state.stores.where((store) => store.id != event.id).toList();
              emit(state.copyWith(status: AdminStoreStatus.success, stores: updatedStores));
            } catch (e) {
              emit(state.copyWith(status: AdminStoreStatus.failure, errorMessage: e.toString()));
            }
          }
        }
        ```

*   **4.3. Admin Product Management BLoC:**
    *   **Purpose:** Manages state for listing, creating, updating, and deleting products.
    *   **Action:** Create directory `lib/bloc/admin/product_management` if it doesn't exist.
    *   **4.3.1. `admin_product_event.dart`:**
        ```dart
        // lib/bloc/admin/product_management/admin_product_event.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/request_response_models.dart';
        import '../../../models/product/product_model.dart';

        abstract class AdminProductEvent extends Equatable {
          const AdminProductEvent();

          @override
          List<Object?> get props => [];
        }

        class LoadAdminProducts extends AdminProductEvent {
          final String? storeId; // Optional filter
          const LoadAdminProducts({this.storeId});
          @override
          List<Object?> get props => [storeId];
        }

        class AddAdminProduct extends AdminProductEvent {
          final ProductCreateRequest productRequest;
          const AddAdminProduct(this.productRequest);
          @override
          List<Object?> get props => [productRequest];
        }

        class UpdateAdminProduct extends AdminProductEvent {
          final String id;
          final ProductUpdateRequest productRequest;
          const UpdateAdminProduct({required this.id, required this.productRequest});
          @override
          List<Object?> get props => [id, productRequest];
        }

        class DeleteAdminProduct extends AdminProductEvent {
          final String id;
          const DeleteAdminProduct(this.id);
          @override
          List<Object?> get props => [id];
        }
        ```
    *   **4.3.2. `admin_product_state.dart`:**
        ```dart
        // lib/bloc/admin/product_management/admin_product_state.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/product/product_model.dart';

        enum AdminProductStatus { initial, loading, success, failure }

        class AdminProductState extends Equatable {
          final AdminProductStatus status;
          final List<Product> products;
          final String? errorMessage;

          const AdminProductState({
            this.status = AdminProductStatus.initial,
            this.products = const [],
            this.errorMessage,
          });

          AdminProductState copyWith({
            AdminProductStatus? status,
            List<Product>? products,
            String? errorMessage,
          }) {
            return AdminProductState(
              status: status ?? this.status,
              products: products ?? this.products,
              errorMessage: errorMessage ?? this.errorMessage,
            );
          }

          @override
          List<Object?> get props => [status, products, errorMessage];
        }
        ```
    *   **4.3.3. `admin_product_bloc.dart`:**
        ```dart
        // lib/bloc/admin/product_management/admin_product_bloc.dart
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:get_it/get_it.dart';
        import 'admin_product_event.dart';
        import 'admin_product_state.dart';
        import '../../../repositories/products_repository.dart';
        import '../../../models/product/product_model.dart';

        class AdminProductBloc extends Bloc<AdminProductEvent, AdminProductState> {
          final ProductsRepository _productsRepository = GetIt.instance<ProductsRepository>();

          AdminProductBloc() : super(const AdminProductState()) {
            on<LoadAdminProducts>(_onLoadAdminProducts);
            on<AddAdminProduct>(_onAddAdminProduct);
            on<UpdateAdminProduct>(_onUpdateAdminProduct);
            on<DeleteAdminProduct>(_onDeleteAdminProduct);
          }

          Future<void> _onLoadAdminProducts(LoadAdminProducts event, Emitter<AdminProductState> emit) async {
            emit(state.copyWith(status: AdminProductStatus.loading));
            try {
              final products = await _productsRepository.getProducts(storeId: event.storeId);
              emit(state.copyWith(status: AdminProductStatus.success, products: products));
            } catch (e) {
              emit(state.copyWith(status: AdminProductStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onAddAdminProduct(AddAdminProduct event, Emitter<AdminProductState> emit) async {
            emit(state.copyWith(status: AdminProductStatus.loading));
            try {
              final newProduct = await _productsRepository.createProduct(event.productRequest);
              final updatedProducts = List<Product>.from(state.products)..add(newProduct);
              emit(state.copyWith(status: AdminProductStatus.success, products: updatedProducts));
            } catch (e) {
              emit(state.copyWith(status: AdminProductStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onUpdateAdminProduct(UpdateAdminProduct event, Emitter<AdminProductState> emit) async {
            emit(state.copyWith(status: AdminProductStatus.loading));
            try {
              final updatedProduct = await _productsRepository.updateProduct(event.id, event.productRequest);
              final updatedProducts = state.products.map((product) => product.id == updatedProduct.id ? updatedProduct : product).toList();
              emit(state.copyWith(status: AdminProductStatus.success, products: updatedProducts));
            } catch (e) {
              emit(state.copyWith(status: AdminProductStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onDeleteAdminProduct(DeleteAdminProduct event, Emitter<AdminProductState> emit) async {
            emit(state.copyWith(status: AdminProductStatus.loading));
            try {
              await _productsRepository.deleteProduct(event.id);
              final updatedProducts = state.products.where((product) => product.id != event.id).toList();
              emit(state.copyWith(status: AdminProductStatus.success, products: updatedProducts));
            } catch (e) {
              emit(state.copyWith(status: AdminProductStatus.failure, errorMessage: e.toString()));
            }
          }
        }
        ```

*   **4.4. Admin Stock Management BLoC:**
    *   **Purpose:** Manages state for listing, creating, updating, and deleting stock entries.
    *   **Action:** Create directory `lib/bloc/admin/stock_management` if it doesn't exist.
    *   **4.4.1. `admin_stock_event.dart`:**
        ```dart
        // lib/bloc/admin/stock_management/admin_stock_event.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/request_response_models.dart';
        import '../../../models/stock/stock_model.dart';

        abstract class AdminStockEvent extends Equatable {
          const AdminStockEvent();

          @override
          List<Object?> get props => [];
        }

        class LoadAdminStocks extends AdminStockEvent {
          final String? storeId; // Optional filter
          final String? productId; // Optional filter
          const LoadAdminStocks({this.storeId, this.productId});
          @override
          List<Object?> get props => [storeId, productId];
        }

        class AddAdminStock extends AdminStockEvent {
          final StockCreateRequest stockRequest;
          const AddAdminStock(this.stockRequest);
          @override
          List<Object?> get props => [stockRequest];
        }

        class UpdateAdminStock extends AdminStockEvent {
          final String id;
          final StockUpdateRequest stockRequest;
          const UpdateAdminStock({required this.id, required this.stockRequest});
          @override
          List<Object?> get props => [id, stockRequest];
        }

        class DeleteAdminStock extends AdminStockEvent {
          final String id;
          const DeleteAdminStock(this.id);
          @override
          List<Object?> get props => [id];
        }
        ```
    *   **4.4.2. `admin_stock_state.dart`:**
        ```dart
        // lib/bloc/admin/stock_management/admin_stock_state.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/stock/stock_model.dart';

        enum AdminStockStatus { initial, loading, success, failure }

        class AdminStockState extends Equatable {
          final AdminStockStatus status;
          final List<Stock> stocks;
          final String? errorMessage;

          const AdminStockState({
            this.status = AdminStockStatus.initial,
            this.stocks = const [],
            this.errorMessage,
          });

          AdminStockState copyWith({
            AdminStockStatus? status,
            List<Stock>? stocks,
            String? errorMessage,
          }) {
            return AdminStockState(
              status: status ?? this.status,
              stocks: stocks ?? this.stocks,
              errorMessage: errorMessage ?? this.errorMessage,
            );
          }

          @override
          List<Object?> get props => [status, stocks, errorMessage];
        }
        ```
    *   **4.4.3. `admin_stock_bloc.dart`:**
        ```dart
        // lib/bloc/admin/stock_management/admin_stock_bloc.dart
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:get_it/get_it.dart';
        import 'admin_stock_event.dart';
        import 'admin_stock_state.dart';
        import '../../../repositories/stock_repository.dart';
        import '../../../models/stock/stock_model.dart';

        class AdminStockBloc extends Bloc<AdminStockEvent, AdminStockState> {
          final StockRepository _stockRepository = GetIt.instance<StockRepository>();

          AdminStockBloc() : super(const AdminStockState()) {
            on<LoadAdminStocks>(_onLoadAdminStocks);
            on<AddAdminStock>(_onAddAdminStock);
            on<UpdateAdminStock>(_onUpdateAdminStock);
            on<DeleteAdminStock>(_onDeleteAdminStock);
          }

          Future<void> _onLoadAdminStocks(LoadAdminStocks event, Emitter<AdminStockState> emit) async {
            emit(state.copyWith(status: AdminStockStatus.loading));
            try {
              final stocks = await _stockRepository.getStocks(storeId: event.storeId, productId: event.productId);
              emit(state.copyWith(status: AdminStockStatus.success, stocks: stocks));
            } catch (e) {
              emit(state.copyWith(status: AdminStockStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onAddAdminStock(AddAdminStock event, Emitter<AdminStockState> emit) async {
            emit(state.copyWith(status: AdminStockStatus.loading));
            try {
              final newStock = await _stockRepository.createStock(event.stockRequest);
              final updatedStocks = List<Stock>.from(state.stocks)..add(newStock);
              emit(state.copyWith(status: AdminStockStatus.success, stocks: updatedStocks));
            } catch (e) {
              emit(state.copyWith(status: AdminStockStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onUpdateAdminStock(UpdateAdminStock event, Emitter<AdminStockState> emit) async {
            emit(state.copyWith(status: AdminStockStatus.loading));
            try {
              final updatedStock = await _stockRepository.updateStock(event.id, event.stockRequest);
              final updatedStocks = state.stocks.map((stock) => stock.id == updatedStock.id ? updatedStock : stock).toList();
              emit(state.copyWith(status: AdminStockStatus.success, stocks: updatedStocks));
            } catch (e) {
              emit(state.copyWith(status: AdminStockStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onDeleteAdminStock(DeleteAdminStock event, Emitter<AdminStockState> emit) async {
            emit(state.copyWith(status: AdminStockStatus.loading));
            try {
              await _stockRepository.deleteStock(event.id);
              final updatedStocks = state.stocks.where((stock) => stock.id != event.id).toList();
              emit(state.copyWith(status: AdminStockStatus.success, stocks: updatedStocks));
            } catch (e) {
              emit(state.copyWith(status: AdminStockStatus.failure, errorMessage: e.toString()));
            }
          }
        }
        ```

*   **4.5. Admin Order Management BLoC:**
    *   **Purpose:** Manages state for listing and updating orders.
    *   **Action:** Create directory `lib/bloc/admin/order_management` if it doesn't exist.
    *   **4.5.1. `admin_order_event.dart`:**
        ```dart
        // lib/bloc/admin/order_management/admin_order_event.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/request_response_models.dart';
        import '../../../models/order/order_model.dart';

        abstract class AdminOrderEvent extends Equatable {
          const AdminOrderEvent();

          @override
          List<Object?> get props => [];
        }

        class LoadAdminOrders extends AdminOrderEvent {
          final String? userId; // Optional filter
          final String? storeId; // Optional filter
          const LoadAdminOrders({this.userId, this.storeId});
          @override
          List<Object?> get props => [userId, storeId];
        }

        class UpdateAdminOrderStatus extends AdminOrderEvent {
          final String id;
          final OrderStatus status;
          const UpdateAdminOrderStatus({required this.id, required this.status});
          @override
          List<Object?> get props => [id, status];
        }

        class DeleteAdminOrder extends AdminOrderEvent {
          final String id;
          const DeleteAdminOrder(this.id);
          @override
          List<Object?> get props => [id];
        }
        ```
    *   **4.5.2. `admin_order_state.dart`:**
        ```dart
        // lib/bloc/admin/order_management/admin_order_state.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/order/order_model.dart';

        enum AdminOrderStatus { initial, loading, success, failure }

        class AdminOrderState extends Equatable {
          final AdminOrderStatus status;
          final List<Order> orders;
          final String? errorMessage;

          const AdminOrderState({
            this.status = AdminOrderStatus.initial,
            this.orders = const [],
            this.errorMessage,
          });

          AdminOrderState copyWith({
            AdminOrderStatus? status,
            List<Order>? orders,
            String? errorMessage,
          }) {
            return AdminOrderState(
              status: status ?? this.status,
              orders: orders ?? this.orders,
              errorMessage: errorMessage ?? this.errorMessage,
            );
          }

          @override
          List<Object?> get props => [status, orders, errorMessage];
        }
        ```
    *   **4.5.3. `admin_order_bloc.dart`:**
        ```dart
        // lib/bloc/admin/order_management/admin_order_bloc.dart
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:get_it/get_it.dart';
        import 'admin_order_event.dart';
        import 'admin_order_state.dart';
        import '../../../repositories/orders_repository.dart';
        import '../../../models/order/order_model.dart';
        import '../../../models/request_response_models.dart';

        class AdminOrderBloc extends Bloc<AdminOrderEvent, AdminOrderState> {
          final OrdersRepository _ordersRepository = GetIt.instance<OrdersRepository>();

          AdminOrderBloc() : super(const AdminOrderState()) {
            on<LoadAdminOrders>(_onLoadAdminOrders);
            on<UpdateAdminOrderStatus>(_onUpdateAdminOrderStatus);
            on<DeleteAdminOrder>(_onDeleteAdminOrder);
          }

          Future<void> _onLoadAdminOrders(LoadAdminOrders event, Emitter<AdminOrderState> emit) async {
            emit(state.copyWith(status: AdminOrderStatus.loading));
            try {
              final orders = await _ordersRepository.getOrders(userId: event.userId, storeId: event.storeId);
              emit(state.copyWith(status: AdminOrderStatus.success, orders: orders));
            } catch (e) {
              emit(state.copyWith(status: AdminOrderStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onUpdateAdminOrderStatus(UpdateAdminOrderStatus event, Emitter<AdminOrderState> emit) async {
            emit(state.copyWith(status: AdminOrderStatus.loading));
            try {
              final updatedOrder = await _ordersRepository.updateOrder(
                event.id,
                OrderUpdateRequest(status: event.status),
              );
              final updatedOrders = state.orders.map((order) => order.id == updatedOrder.id ? updatedOrder : order).toList();
              emit(state.copyWith(status: AdminOrderStatus.success, orders: updatedOrders));
            } catch (e) {
              emit(state.copyWith(status: AdminOrderStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onDeleteAdminOrder(DeleteAdminOrder event, Emitter<AdminOrderState> emit) async {
            emit(state.copyWith(status: AdminOrderStatus.loading));
            try {
              await _ordersRepository.deleteOrder(event.id);
              final updatedOrders = state.orders.where((order) => order.id != event.id).toList();
              emit(state.copyWith(status: AdminOrderStatus.success, orders: updatedOrders));
            } catch (e) {
              emit(state.copyWith(status: AdminOrderStatus.failure, errorMessage: e.toString()));
            }
          }
        }
        ```

*   **4.6. Merchant Order Management BLoC (Simplified):**
    *   **Purpose:** Manages state for listing and updating orders for a *specific* store. This BLoC assumes the merchant is an `admin` user and has a `storeId` associated with their session (e.g., stored in `AuthRepository`).
    *   **Action:** Create directory `lib/bloc/merchant/order_management` if it doesn't exist.
    *   **4.6.1. `merchant_order_event.dart`:**
        ```dart
        // lib/bloc/merchant/order_management/merchant_order_event.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/order/order_model.dart';

        abstract class MerchantOrderEvent extends Equatable {
          const MerchantOrderEvent();

          @override
          List<Object?> get props => [];
        }

        class LoadMerchantOrders extends MerchantOrderEvent {
          final String storeId;
          const LoadMerchantOrders(this.storeId);
          @override
          List<Object?> get props => [storeId];
        }

        class UpdateMerchantOrderStatus extends MerchantOrderEvent {
          final String orderId; // API uses 'id' for order ID
          final OrderStatus status;
          final String storeId; // Needed to reload orders for the specific store
          const UpdateMerchantOrderStatus({required this.orderId, required this.status, required this.storeId});
          @override
          List<Object?> get props => [orderId, status, storeId];
        }
        ```
    *   **4.6.2. `merchant_order_state.dart`:**
        ```dart
        // lib/bloc/merchant/order_management/merchant_order_state.dart
        import 'package:equatable/equatable.dart';
        import '../../../models/order/order_model.dart';

        enum MerchantOrderStatus { initial, loading, success, failure }

        class MerchantOrderState extends Equatable {
          final MerchantOrderStatus status;
          final List<Order> orders;
          final String? errorMessage;

          const MerchantOrderState({
            this.status = MerchantOrderStatus.initial,
            this.orders = const [],
            this.errorMessage,
          });

          MerchantOrderState copyWith({
            MerchantOrderStatus? status,
            List<Order>? orders,
            String? errorMessage,
          }) {
            return MerchantOrderState(
              status: status ?? this.status,
              orders: orders ?? this.orders,
              errorMessage: errorMessage ?? this.errorMessage,
            );
          }

          @override
          List<Object?> get props => [status, orders, errorMessage];
        }
        ```
    *   **4.6.3. `merchant_order_bloc.dart`:**
        ```dart
        // lib/bloc/merchant/order_management/merchant_order_bloc.dart
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:get_it/get_it.dart';
        import 'merchant_order_event.dart';
        import 'merchant_order_state.dart';
        import '../../../repositories/orders_repository.dart';
        import '../../../models/order/order_model.dart';
        import '../../../models/request_response_models.dart';

        class MerchantOrderBloc extends Bloc<MerchantOrderEvent, MerchantOrderState> {
          final OrdersRepository _ordersRepository = GetIt.instance<OrdersRepository>();

          MerchantOrderBloc() : super(const MerchantOrderState()) {
            on<LoadMerchantOrders>(_onLoadMerchantOrders);
            on<UpdateMerchantOrderStatus>(_onUpdateMerchantOrderStatus);
          }

          Future<void> _onLoadMerchantOrders(LoadMerchantOrders event, Emitter<MerchantOrderState> emit) async {
            emit(state.copyWith(status: MerchantOrderStatus.loading));
            try {
              final orders = await _ordersRepository.getOrders(storeId: event.storeId);
              emit(state.copyWith(status: MerchantOrderStatus.success, orders: orders));
            } catch (e) {
              emit(state.copyWith(status: MerchantOrderStatus.failure, errorMessage: e.toString()));
            }
          }

          Future<void> _onUpdateMerchantOrderStatus(UpdateMerchantOrderStatus event, Emitter<MerchantOrderState> emit) async {
            emit(state.copyWith(status: MerchantOrderStatus.loading));
            try {
              final updatedOrder = await _ordersRepository.updateOrder(
                event.orderId,
                OrderUpdateRequest(status: event.status),
              );
              // Reload orders for the specific store after update
              final orders = await _ordersRepository.getOrders(storeId: event.storeId);
              emit(state.copyWith(status: MerchantOrderStatus.success, orders: orders));
            } catch (e) {
              emit(state.copyWith(status: MerchantOrderStatus.failure, errorMessage: e.toString()));
            }
          }
        }
        ```

---

**Phase 5: UI Views Implementation (Admin - API-Driven)**

**Objective:** Create Flutter UI pages and widgets for Admin dashboards and management screens, strictly using the API-defined models and available operations.

*   **5.1. Create Admin Views Directory:**
    *   **Action:** Create directory `lib/views/admin` if it doesn't exist.

*   **5.2. Admin Dashboard Page:**
    *   **Purpose:** A central hub for admin users to navigate to different management sections.
    *   **File:** `lib/views/admin/admin_dashboard_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/admin/admin_dashboard_page.dart
        import 'package:flutter/material.dart';
        import 'package:go_router/go_router.dart';

        class AdminDashboardPage extends StatelessWidget {
          const AdminDashboardPage({super.key});

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Admin Dashboard'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Admin!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    _buildDashboardCard(
                      context,
                      title: 'Manage Users',
                      icon: Icons.people,
                      onTap: () => context.go('/admin/users'),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Manage Stores',
                      icon: Icons.store,
                      onTap: () => context.go('/admin/stores'),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Manage Products',
                      icon: Icons.inventory_2,
                      onTap: () => context.go('/admin/products'),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Manage Stock',
                      icon: Icons.warehouse,
                      onTap: () => context.go('/admin/stock'),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Manage Orders',
                      icon: Icons.receipt_long,
                      onTap: () => context.go('/admin/orders'),
                    ),
                  ],
                ),
              ),
            );
          }

          Widget _buildDashboardCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Icon(icon, size: 30),
                title: Text(title, style: Theme.of(context).textTheme.titleLarge),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: onTap,
              ),
            );
          }
        }
        ```
    *   **Verification:** Navigate to this page and ensure all links are present.

*   **5.3. Admin User List Page:**
    *   **Purpose:** Displays a list of users and allows CRUD operations.
    *   **File:** `lib/views/admin/admin_user_list_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/admin/admin_user_list_page.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import '../../bloc/admin/user_management/admin_user_bloc.dart';
        import '../../bloc/admin/user_management/admin_user_event.dart';
        import '../../bloc/admin/user_management/admin_user_state.dart';
        import '../../models/user/user_model.dart';

        class AdminUserListPage extends StatelessWidget {
          const AdminUserListPage({super.key});

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Manage Users'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      context.go('/admin/users/add');
                    },
                  ),
                ],
              ),
              body: BlocProvider(
                create: (context) => AdminUserBloc()..add(LoadAdminUsers()),
                child: BlocBuilder<AdminUserBloc, AdminUserState>(
                  builder: (context, state) {
                    if (state.status == AdminUserStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == AdminUserStatus.success) {
                      if (state.users.isEmpty) {
                        return const Center(child: Text('No users found.'));
                      }
                      return ListView.builder(
                        itemCount: state.users.length,
                        itemBuilder: (context, index) {
                          final user = state.users[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text(user.username),
                              subtitle: Text('${user.email} (${user.role.toShortString()})'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      context.go('/admin/users/edit/${user.id}', extra: user);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _confirmDelete(context, user);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Navigate to user details if needed
                                // context.go('/admin/users/${user.id}', extra: user);
                              },
                            ),
                          );
                        },
                      );
                    } else if (state.status == AdminUserStatus.failure) {
                      return Center(child: Text('Error: ${state.errorMessage}'));
                    }
                    return const Center(child: Text('Press the + button to add a user.'));
                  },
                ),
              ),
            );
          }

          void _confirmDelete(BuildContext context, User user) {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Delete User'),
                  content: Text('Are you sure you want to delete user "${user.username}"?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        BlocProvider.of<AdminUserBloc>(context).add(DeleteAdminUser(user.id));
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
        ```
    *   **Verification:** Load users, add, edit, delete.

*   **5.4. Admin User Create/Edit Form Page:**
    *   **Purpose:** Form for creating or updating user details.
    *   **File:** `lib/views/admin/admin_user_form_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/admin/admin_user_form_page.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import '../../bloc/admin/user_management/admin_user_bloc.dart';
        import '../../bloc/admin/user_management/admin_user_event.dart';
        import '../../models/user/user_model.dart';
        import '../../models/request_response_models.dart';

        class AdminUserFormPage extends StatefulWidget {
          final User? user; // Null for create, provided for edit

          const AdminUserFormPage({super.key, this.user});

          @override
          State<AdminUserFormPage> createState() => _AdminUserFormPageState();
        }

        class _AdminUserFormPageState extends State<AdminUserFormPage> {
          final _formKey = GlobalKey<FormState>();
          late TextEditingController _usernameController;
          late TextEditingController _emailController;
          late TextEditingController _passwordController;
          UserRole? _selectedRole;

          @override
          void initState() {
            super.initState();
            _usernameController = TextEditingController(text: widget.user?.username ?? '');
            _emailController = TextEditingController(text: widget.user?.email ?? '');
            _passwordController = TextEditingController(); // Password is never pre-filled for security
            _selectedRole = widget.user?.role ?? UserRole.user;
          }

          @override
          void dispose() {
            _usernameController.dispose();
            _emailController.dispose();
            _passwordController.dispose();
            super.dispose();
          }

          void _submitForm() {
            if (_formKey.currentState!.validate()) {
              if (widget.user == null) {
                // Create new user
                final request = UserCreateRequest(
                  username: _usernameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                  role: _selectedRole,
                );
                BlocProvider.of<AdminUserBloc>(context).add(AddAdminUser(request));
              } else {
                // Update existing user
                final request = UserUpdateRequest(
                  username: _usernameController.text,
                  email: _emailController.text,
                  password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
                  role: _selectedRole,
                );
                BlocProvider.of<AdminUserBloc>(context).add(UpdateAdminUser(id: widget.user!.id, userRequest: request));
              }
              context.pop(); // Go back to the list page
            }
          }

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.user == null ? 'Create User' : 'Edit User'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: widget.user == null ? 'Password' : 'New Password (leave blank to keep current)',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (widget.user == null && (value == null || value.isEmpty)) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<UserRole>(
                        value: _selectedRole,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: UserRole.values.where((role) => role != UserRole.unknown).map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.toShortString()),
                          );
                        }).toList(),
                        onChanged: (UserRole? newValue) {
                          setState(() {
                            _selectedRole = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a role';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(widget.user == null ? 'Create User' : 'Update User'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        ```
    *   **Verification:** Test creating a new user and editing an existing one.

*   **5.5. Admin Store List Page:**
    *   **Purpose:** Displays a list of stores and allows CRUD operations.
    *   **File:** `lib/views/admin/admin_store_list_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/admin/admin_store_list_page.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import '../../bloc/admin/store_management/admin_store_bloc.dart';
        import '../../bloc/admin/store_management/admin_store_event.dart';
        import '../../bloc/admin/store_management/admin_store_state.dart';
        import '../../models/store/store_model.dart';

        class AdminStoreListPage extends StatelessWidget {
          const AdminStoreListPage({super.key});

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Manage Stores'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      context.go('/admin/stores/add');
                    },
                  ),
                ],
              ),
              body: BlocProvider(
                create: (context) => AdminStoreBloc()..add(LoadAdminStores()),
                child: BlocBuilder<AdminStoreBloc, AdminStoreState>(
                  builder: (context, state) {
                    if (state.status == AdminStoreStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == AdminStoreStatus.success) {
                      if (state.stores.isEmpty) {
                        return const Center(child: Text('No stores found.'));
                      }
                      return ListView.builder(
                        itemCount: state.stores.length,
                        itemBuilder: (context, index) {
                          final store = state.stores[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text(store.name),
                              subtitle: Text(store.address),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      context.go('/admin/stores/edit/${store.id}', extra: store);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _confirmDelete(context, store);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Navigate to store details if needed
                                // context.go('/admin/stores/${store.id}', extra: store);
                              },
                            ),
                          );
                        },
                      );
                    } else if (state.status == AdminStoreStatus.failure) {
                      return Center(child: Text('Error: ${state.errorMessage}'));
                    }
                    return const Center(child: Text('Press the + button to add a store.'));
                  },
                ),
              ),
            );
          }

          void _confirmDelete(BuildContext context, Store store) {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Delete Store'),
                  content: Text('Are you sure you want to delete store "${store.name}"?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        BlocProvider.of<AdminStoreBloc>(context).add(DeleteAdminStore(store.id));
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
        ```
    *   **Verification:** Load stores, add, edit, delete.

*   **5.6. Admin Store Create/Edit Form Page:**
    *   **Purpose:** Form for creating or updating store details.
    *   **File:** `lib/views/admin/admin_store_form_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/admin/admin_store_form_page.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import '../../bloc/admin/store_management/admin_store_bloc.dart';
        import '../../bloc/admin/store_management/admin_store_event.dart';
        import '../../models/store/store_model.dart';
        import '../../models/request_response_models.dart';

        class AdminStoreFormPage extends StatefulWidget {
          final Store? store; // Null for create, provided for edit

          const AdminStoreFormPage({super.key, this.store});

          @override
          State<AdminStoreFormPage> createState() => _AdminStoreFormPageState();
        }

        class _AdminStoreFormPageState extends State<AdminStoreFormPage> {
          final _formKey = GlobalKey<FormState>();
          late TextEditingController _nameController;
          late TextEditingController _addressController;

          @override
          void initState() {
            super.initState();
            _nameController = TextEditingController(text: widget.store?.name ?? '');
            _addressController = TextEditingController(text: widget.store?.address ?? '');
          }

          @override
          void dispose() {
            _nameController.dispose();
            _addressController.dispose();
            super.dispose();
          }

          void _submitForm() {
            if (_formKey.currentState!.validate()) {
              if (widget.store == null) {
                // Create new store
                final request = StoreCreateRequest(
                  name: _nameController.text,
                  address: _addressController.text,
                );
                BlocProvider.of<AdminStoreBloc>(context).add(AddAdminStore(request));
              } else {
                // Update existing store
                final request = StoreUpdateRequest(
                  name: _nameController.text,
                  address: _addressController.text,
                );
                BlocProvider.of<AdminStoreBloc>(context).add(UpdateAdminStore(id: widget.store!.id, storeRequest: request));
              }
              context.pop(); // Go back to the list page
            }
          }

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.store == null ? 'Create Store' : 'Edit Store'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Store Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a store name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(widget.store == null ? 'Create Store' : 'Update Store'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        ```
    *   **Verification:** Test creating a new store and editing an existing one.

*   **5.7. Admin Product List Page:**
    *   **Purpose:** Displays a list of products and allows CRUD operations.
    *   **File:** `lib/views/admin/admin_product_list_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/admin/admin_product_list_page.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import '../../bloc/admin/product_management/admin_product_bloc.dart';
        import '../../bloc/admin/product_management/admin_product_event.dart';
        import '../../bloc/admin/product_management/admin_product_state.dart';
        import '../../models/product/product_model.dart';

        class AdminProductListPage extends StatelessWidget {
          const AdminProductListPage({super.key});

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Manage Products'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      context.go('/admin/products/add');
                    },
                  ),
                ],
              ),
              body: BlocProvider(
                create: (context) => AdminProductBloc()..add(const LoadAdminProducts()),
                child: BlocBuilder<AdminProductBloc, AdminProductState>(
                  builder: (context, state) {
                    if (state.status == AdminProductStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == AdminProductStatus.success) {
                      if (state.products.isEmpty) {
                        return const Center(child: Text('No products found.'));
                      }
                      return ListView.builder(
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text(product.name),
                              subtitle: Text('${product.description} - \$${product.price.toStringAsFixed(2)} (Store ID: ${product.storeId})'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      context.go('/admin/products/edit/${product.id}', extra: product);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _confirmDelete(context, product);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Navigate to product details if needed
                                // context.go('/admin/products/${product.id}', extra: product);
                              },
                            ),
                          );
                        },
                      );
                    } else if (state.status == AdminProductStatus.failure) {
                      return Center(child: Text('Error: ${state.errorMessage}'));
                    }
                    return const Center(child: Text('Press the + button to add a product.'));
                  },
                ),
              ),
            );
          }

          void _confirmDelete(BuildContext context, Product product) {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Delete Product'),
                  content: Text('Are you sure you want to delete product "${product.name}"?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        BlocProvider.of<AdminProductBloc>(context).add(DeleteAdminProduct(product.id));
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
        ```
    *   **Verification:** Load products, add, edit, delete.

*   **5.8. Admin Product Create/Edit Form Page:**
    *   **Purpose:** Form for creating or updating product details.
    *   **File:** `lib/views/admin/admin_product_form_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/admin/admin_product_form_page.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import '../../bloc/admin/product_management/admin_product_bloc.dart';
        import '../../bloc/admin/product_management/admin_product_event.dart';
        import '../../models/product/product_model.dart';
        import '../../models/request_response_models.dart';

        class AdminProductFormPage extends StatefulWidget {
          final Product? product; // Null for create, provided for edit

          const AdminProductFormPage({super.key, this.product});

          @override
          State<AdminProductFormPage> createState() => _AdminProductFormPageState();
        }

        class _AdminProductFormPageState extends State<AdminProductFormPage> {
          final _formKey = GlobalKey<FormState>();
          late TextEditingController _nameController;
          late TextEditingController _descriptionController;
          late TextEditingController _priceController;
          late TextEditingController _storeIdController;

          @override
          void initState() {
            super.initState();
            _nameController = TextEditingController(text: widget.product?.name ?? '');
            _descriptionController = TextEditingController(text: widget.product?.description ?? '');
            _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
            _storeIdController = TextEditingController(text: widget.product?.storeId ?? '');
          }

          @override
          void dispose() {
            _nameController.dispose();
            _descriptionController.dispose();
            _priceController.dispose();
            _storeIdController.dispose();
            super.dispose();
          }

          void _submitForm() {
            if (_formKey.currentState!.validate()) {
              if (widget.product == null) {
                // Create new product
                final request = ProductCreateRequest(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  price: double.parse(_priceController.text),
                  storeId: _storeIdController.text,
                );
                BlocProvider.of<AdminProductBloc>(context).add(AddAdminProduct(request));
              } else {
                // Update existing product
                final request = ProductUpdateRequest(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  price: double.parse(_priceController.text),
                  storeId: _storeIdController.text,
                );
                BlocProvider.of<AdminProductBloc>(context).add(UpdateAdminProduct(id: widget.product!.id, productRequest: request));
              }
              context.pop(); // Go back to the list page
            }
          }

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.product == null ? 'Create Product' : 'Edit Product'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Product Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a product name';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a description';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a price';
                          if (double.tryParse(value) == null) return 'Please enter a valid number';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _storeIdController,
                        decoration: const InputDecoration(labelText: 'Store ID'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a store ID';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(widget.product == null ? 'Create Product' : 'Update Product'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        ```
    *   **Verification:** Test creating a new product and editing an existing one.

*   **5.9. Admin Stock List Page:**
    *   **Purpose:** Displays a list of stock entries and allows CRUD operations.
    *   **File:** `lib/views/admin/admin_stock_list_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/admin/admin_stock_list_page.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import '../../bloc/admin/stock_management/admin_stock_bloc.dart';
        import '../../bloc/admin/stock_management/admin_stock_event.dart';
        import '../../bloc/admin/stock_management/admin_stock_state.dart';
        import '../../models/stock/stock_model.dart';

        class AdminStockListPage extends StatelessWidget {
          const AdminStockListPage({super.key});

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Manage Stock'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      context.go('/admin/stock/add');
                    },
                  ),
                ],
              ),
              body: BlocProvider(
                create: (context) => AdminStockBloc()..add(const LoadAdminStocks()),
                child: BlocBuilder<AdminStockBloc, AdminStockState>(
                  builder: (context, state) {
                    if (state.status == AdminStockStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == AdminStockStatus.success) {
                      if (state.stocks.isEmpty) {
                        return const Center(child: Text('No stock entries found.'));
                      }
                      return ListView.builder(
                        itemCount: state.stocks.length,
                        itemBuilder: (context, index) {
                          final stock = state.stocks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text('Product ID: ${stock.productId}'),
                              subtitle: Text('Store ID: ${stock.storeId} - Quantity: ${stock.quantity}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      context.go('/admin/stock/edit/${stock.id}', extra: stock);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _confirmDelete(context, stock);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Navigate to stock details if needed
                                // context.go('/admin/stock/${stock.id}', extra: stock);
                              },
                            ),
                          );
                        },
                      );
                    } else if (state.status == AdminStockStatus.failure) {
                      return Center(child: Text('Error: ${state.errorMessage}'));
                    }
                    return const Center(child: Text('Press the + button to add stock.'));
                  },
                ),
              ),
            );
          }

          void _confirmDelete(BuildContext context, Stock stock) {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Delete Stock'),
                  content: Text('Are you sure you want to delete stock entry for Product ID "${stock.productId}" in Store ID "${stock.storeId}"?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        BlocProvider.of<AdminStockBloc>(context).add(DeleteAdminStock(stock.id));
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
        ```
    *   **Verification:** Load stock, add, edit, delete.

*   **5.10. Admin Stock Create/Edit Form Page:**
    *   **Purpose:** Form for creating or updating stock entries.
    *   **File:** `lib/views/admin/admin_stock_form_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/admin/admin_stock_form_page.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import '../../bloc/admin/stock_management/admin_stock_bloc.dart';
        import '../../bloc/admin/stock_management/admin_stock_event.dart';
        import '../../models/stock/stock_model.dart';
        import '../../models/request_response_models.dart';

        class AdminStockFormPage extends StatefulWidget {
          final Stock? stock; // Null for create, provided for edit

          const AdminStockFormPage({super.key, this.stock});

          @override
          State<AdminStockFormPage> createState() => _AdminStockFormPageState();
        }

        class _AdminStockFormPageState extends State<AdminStockFormPage> {
          final _formKey = GlobalKey<FormState>();
          late TextEditingController _productIdController;
          late TextEditingController _storeIdController;
          late TextEditingController _quantityController;

          @override
          void initState() {
            super.initState();
            _productIdController = TextEditingController(text: widget.stock?.productId ?? '');
            _storeIdController = TextEditingController(text: widget.stock?.storeId ?? '');
            _quantityController = TextEditingController(text: widget.stock?.quantity.toString() ?? '');
          }

          @override
          void dispose() {
            _productIdController.dispose();
            _storeIdController.dispose();
            _quantityController.dispose();
            super.dispose();
          }

          void _submitForm() {
            if (_formKey.currentState!.validate()) {
              if (widget.stock == null) {
                // Create new stock
                final request = StockCreateRequest(
                  productId: _productIdController.text,
                  storeId: _storeIdController.text,
                  quantity: int.parse(_quantityController.text),
                );
                BlocProvider.of<AdminStockBloc>(context).add(AddAdminStock(request));
              } else {
                // Update existing stock
                final request = StockUpdateRequest(
                  productId: _productIdController.text,
                  storeId: _storeIdController.text,
                  quantity: int.parse(_quantityController.text),
                );
                BlocProvider.of<AdminStockBloc>(context).add(UpdateAdminStock(id: widget.stock!.id, stockRequest: request));
              }
              context.pop(); // Go back to the list page
            }
          }

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.stock == null ? 'Create Stock' : 'Edit Stock'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _productIdController,
                        decoration: const InputDecoration(labelText: 'Product ID'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a product ID';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _storeIdController,
                        decoration: const InputDecoration(labelText: 'Store ID'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a store ID';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a quantity';
                          if (int.tryParse(value) == null) return 'Please enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(widget.stock == null ? 'Create Stock' : 'Update Stock'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
        ```
    *   **Verification:** Test creating a new stock entry and editing an existing one.

*   **5.11. Admin Order List Page:**
    *   **Purpose:** Displays a list of orders and allows status updates and deletion.
    *   **File:** `lib/views/admin/admin_order_list_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/admin/admin_order_list_page.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import '../../bloc/admin/order_management/admin_order_bloc.dart';
        import '../../bloc/admin/order_management/admin_order_event.dart';
        import '../../bloc/admin/order_management/admin_order_state.dart';
        import '../../models/order/order_model.dart';

        class AdminOrderListPage extends StatelessWidget {
          const AdminOrderListPage({super.key});

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Manage Orders'),
              ),
              body: BlocProvider(
                create: (context) => AdminOrderBloc()..add(const LoadAdminOrders()),
                child: BlocBuilder<AdminOrderBloc, AdminOrderState>(
                  builder: (context, state) {
                    if (state.status == AdminOrderStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == AdminOrderStatus.success) {
                      if (state.orders.isEmpty) {
                        return const Center(child: Text('No orders found.'));
                      }
                      return ListView.builder(
                        itemCount: state.orders.length,
                        itemBuilder: (context, index) {
                          final order = state.orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text('Order ID: ${order.id}'),
                              subtitle: Text('User: ${order.userId} | Store: ${order.storeId} | Amount: \$${order.totalAmount.toStringAsFixed(2)} | Status: ${order.status.toShortString()}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PopupMenuButton<OrderStatus>(
                                    onSelected: (OrderStatus newStatus) {
                                      BlocProvider.of<AdminOrderBloc>(context).add(
                                        UpdateAdminOrderStatus(id: order.id, status: newStatus),
                                      );
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return OrderStatus.values.where((s) => s != OrderStatus.unknown).map((status) {
                                        return PopupMenuItem<OrderStatus>(
                                          value: status,
                                          child: Text(status.toShortString()),
                                        );
                                      }).toList();
                                    },
                                    icon: const Icon(Icons.more_vert),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _confirmDelete(context, order);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Navigate to order details if needed
                                // context.go('/admin/orders/${order.id}', extra: order);
                              },
                            ),
                          );
                        },
                      );
                    } else if (state.status == AdminOrderStatus.failure) {
                      return Center(child: Text('Error: ${state.errorMessage}'));
                    }
                    return const Center(child: Text('No orders to display.'));
                  },
                ),
              ),
            );
          }

          void _confirmDelete(BuildContext context, Order order) {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Delete Order'),
                  content: Text('Are you sure you want to delete order "${order.id}"?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        BlocProvider.of<AdminOrderBloc>(context).add(DeleteAdminOrder(order.id));
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
        ```
    *   **Verification:** Load orders, update status, delete.

---

**Phase 6: UI Views Implementation (Merchant - API-Driven)**

**Objective:** Create Flutter UI pages and widgets for a simplified Merchant dashboard. This dashboard will primarily focus on managing orders for a specific store, assuming the logged-in user is an `admin` with an associated `storeId`.

*   **6.1. Create Merchant Views Directory:**
    *   **Action:** Create directory `lib/views/merchant` if it doesn't exist.

*   **6.2. Merchant Dashboard Page (Simplified):**
    *   **Purpose:** A landing page for merchants to view their store's orders.
    *   **File:** `lib/views/merchant/merchant_dashboard_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/merchant/merchant_dashboard_page.dart
        import 'package:flutter/material.dart';
        import 'package:go_router/go_router.dart';
        import 'package:get_it/get_it.dart';
        import '../../repositories/auth_repository.dart'; // To get user's store ID

        class MerchantDashboardPage extends StatefulWidget {
          const MerchantDashboardPage({super.key});

          @override
          State<MerchantDashboardPage> createState() => _MerchantDashboardPageState();
        }

        class _MerchantDashboardPageState extends State<MerchantDashboardPage> {
          String? _merchantStoreId;
          final AuthRepository _authRepository = GetIt.instance<AuthRepository>();

          @override
          void initState() {
            super.initState();
            _loadMerchantStoreId();
          }

          Future<void> _loadMerchantStoreId() async {
            // In a real app, an admin user acting as a merchant would have a storeId
            // associated with their session or profile. For this simplified API,
            // we'll assume a mechanism to get the 'current' storeId for the merchant.
            // This could be from a user preference, or if the API provided a way
            // to list stores managed by the logged-in admin.
            // For now, we'll use a placeholder or assume it's set elsewhere.
            // If the API's User model had a 'storeId' field, we'd use that.
            // Since it doesn't, this part is conceptual and needs a concrete implementation
            // based on how a merchant's store is identified in the app context.
            // For demonstration, let's assume a hardcoded store ID or one retrieved
            // from a user preference that an admin user might set.
            // For now, we'll just check if the user is an admin.
            if (_authRepository.isAdmin()) {
              // Placeholder: In a real scenario, this storeId would come from the user's profile
              // or a selection mechanism.
              setState(() {
                _merchantStoreId = 'some_hardcoded_store_id_for_admin_merchant'; // REPLACE WITH ACTUAL LOGIC
              });
            } else {
              // Not an admin, or no store associated.
              print('User is not an admin or no store ID found for merchant view.');
              // Potentially redirect or show an error.
            }
          }

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Merchant Dashboard'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Merchant!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    if (_merchantStoreId != null)
                      _buildDashboardCard(
                        context,
                        title: 'Manage My Store Orders',
                        icon: Icons.receipt_long,
                        onTap: () => context.go('/merchant/orders/$_merchantStoreId'),
                      )
                    else
                      const Center(child: Text('Please select a store or ensure you are an admin with an associated store.')),
                  ],
                ),
              ),
            );
          }

          Widget _buildDashboardCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Icon(icon, size: 30),
                title: Text(title, style: Theme.of(context).textTheme.titleLarge),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: onTap,
              ),
            );
          }
        }
        ```
    *   **Verification:** Ensure the page loads and the "Manage My Store Orders" card is displayed if `_merchantStoreId` is set. **Crucially, the logic for `_merchantStoreId` needs to be implemented based on how a store is associated with an admin user in the application's context, as the API `User` model does not provide this directly.**

*   **6.3. Merchant Order List Page:**
    *   **Purpose:** Displays orders for a specific store and allows status updates.
    *   **File:** `lib/views/merchant/merchant_order_list_page.dart`
    *   **Content (Basic Structure):**
        ```dart
        // lib/views/merchant/merchant_order_list_page.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart';
        import 'package:go_router/go_router.dart';
        import '../../bloc/merchant/order_management/merchant_order_bloc.dart';
        import '../../bloc/merchant/order_management/merchant_order_event.dart';
        import '../../bloc/merchant/order_management/merchant_order_state.dart';
        import '../../models/order/order_model.dart';

        class MerchantOrderListPage extends StatelessWidget {
          final String storeId;

          const MerchantOrderListPage({super.key, required this.storeId});

          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Orders for Store: $storeId'),
              ),
              body: BlocProvider(
                create: (context) => MerchantOrderBloc()..add(LoadMerchantOrders(storeId)),
                child: BlocBuilder<MerchantOrderBloc, MerchantOrderState>(
                  builder: (context, state) {
                    if (state.status == MerchantOrderStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.status == MerchantOrderStatus.success) {
                      if (state.orders.isEmpty) {
                        return const Center(child: Text('No orders found for this store.'));
                      }
                      return ListView.builder(
                        itemCount: state.orders.length,
                        itemBuilder: (context, index) {
                          final order = state.orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text('Order ID: ${order.id}'),
                              subtitle: Text('User: ${order.userId} | Amount: \$${order.totalAmount.toStringAsFixed(2)} | Status: ${order.status.toShortString()}'),
                              trailing: PopupMenuButton<OrderStatus>(
                                onSelected: (OrderStatus newStatus) {
                                  BlocProvider.of<MerchantOrderBloc>(context).add(
                                    UpdateMerchantOrderStatus(orderId: order.id, status: newStatus, storeId: storeId),
                                  );
                                },
                                itemBuilder: (BuildContext context) {
                                  return OrderStatus.values.where((s) => s != OrderStatus.unknown).map((status) {
                                    return PopupMenuItem<OrderStatus>(
                                      value: status,
                                      child: Text(status.toShortString()),
                                    );
                                  }).toList();
                                },
                                icon: const Icon(Icons.more_vert),
                              ),
                              onTap: () {
                                // Navigate to order details if needed
                                // context.go('/merchant/orders/${order.id}', extra: order);
                              },
                            ),
                          );
                        },
                      );
                    } else if (state.status == MerchantOrderStatus.failure) {
                      return Center(child: Text('Error: ${state.errorMessage}'));
                    }
                    return const Center(child: Text('No orders to display.'));
                  },
                ),
              ),
            );
          }
        }
        ```
    *   **Verification:** Load orders for a specific store, update status.

---

**Phase 7: Update Routing (API-Driven)**

**Objective:** Integrate the new UI views into the application's navigation using `go_router`, including basic role-based redirection.

*   **7.1. Update `app_router.dart`:**
    *   **Purpose:** Define routes and implement a basic redirection logic based on user authentication and role.
    *   **File:** `lib/routing/app_router.dart`
    *   **Content Modification (add imports and new routes, update redirect logic):**
        ```dart
        // lib/routing/app_router.dart
        import 'package:flutter/material.dart';
        import 'package:go_router/go_router.dart';
        import 'package:get_it/get_it.dart';

        import '../repositories/auth_repository.dart';
        import '../models/user/user_model.dart'; // Import User and UserRole

        // Admin Views
        import '../views/admin/admin_dashboard_page.dart';
        import '../views/admin/admin_user_list_page.dart';
        import '../views/admin/admin_user_form_page.dart';
        import '../views/admin/admin_store_list_page.dart';
        import '../views/admin/admin_store_form_page.dart';
        import '../views/admin/admin_product_list_page.dart';
        import '../views/admin/admin_product_form_page.dart';
        import '../views/admin/admin_stock_list_page.dart';
        import '../views/admin/admin_stock_form_page.dart';
        import '../views/admin/admin_order_list_page.dart';

        // Merchant Views
        import '../views/merchant/merchant_dashboard_page.dart';
        import '../views/merchant/merchant_order_list_page.dart';

        // Models for extra parameters
        import '../models/user/user_model.dart';
        import '../models/store/store_model.dart';
        import '../models/product/product_model.dart';
        import '../models/stock/stock_model.dart';
        import '../models/order/order_model.dart';

        // Placeholder for existing routes (assuming they exist)
        import '../views/auth/login_page.dart'; // Assuming a login page
        import '../views/home/home_page.dart'; // Assuming a home page

        final GoRouter appRouter = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(), // Your main home page
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => const LoginPage(), // Your login page
            ),
            // Admin Routes
            GoRoute(
              name: 'adminDashboard',
              path: '/admin',
              builder: (context, state) => const AdminDashboardPage(),
            ),
            GoRoute(
              name: 'adminUsers',
              path: '/admin/users',
              builder: (context, state) => const AdminUserListPage(),
            ),
            GoRoute(
              name: 'adminAddUser',
              path: '/admin/users/add',
              builder: (context, state) => const AdminUserFormPage(),
            ),
            GoRoute(
              name: 'adminEditUser',
              path: '/admin/users/edit/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final user = state.extra as User?;
                return AdminUserFormPage(user: user);
              },
            ),
            GoRoute(
              name: 'adminStores',
              path: '/admin/stores',
              builder: (context, state) => const AdminStoreListPage(),
            ),
            GoRoute(
              name: 'adminAddStore',
              path: '/admin/stores/add',
              builder: (context, state) => const AdminStoreFormPage(),
            ),
            GoRoute(
              name: 'adminEditStore',
              path: '/admin/stores/edit/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final store = state.extra as Store?;
                return AdminStoreFormPage(store: store);
              },
            ),
            GoRoute(
              name: 'adminProducts',
              path: '/admin/products',
              builder: (context, state) => const AdminProductListPage(),
            ),
            GoRoute(
              name: 'adminAddProduct',
              path: '/admin/products/add',
              builder: (context, state) => const AdminProductFormPage(),
            ),
            GoRoute(
              name: 'adminEditProduct',
              path: '/admin/products/edit/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final product = state.extra as Product?;
                return AdminProductFormPage(product: product);
              },
            ),
            GoRoute(
              name: 'adminStock',
              path: '/admin/stock',
              builder: (context, state) => const AdminStockListPage(),
            ),
            GoRoute(
              name: 'adminAddStock',
              path: '/admin/stock/add',
              builder: (context, state) => const AdminStockFormPage(),
            ),
            GoRoute(
              name: 'adminEditStock',
              path: '/admin/stock/edit/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final stock = state.extra as Stock?;
                return AdminStockFormPage(stock: stock);
              },
            ),
            GoRoute(
              name: 'adminOrders',
              path: '/admin/orders',
              builder: (context, state) => const AdminOrderListPage(),
            ),
            // Merchant Routes (simplified)
            GoRoute(
              name: 'merchantDashboard',
              path: '/merchant',
              builder: (context, state) => const MerchantDashboardPage(),
            ),
            GoRoute(
              name: 'merchantOrders',
              path: '/merchant/orders/:storeId',
              builder: (context, state) {
                final storeId = state.pathParameters['storeId']!;
                return MerchantOrderListPage(storeId: storeId);
              },
            ),
          ],
          redirect: (context, state) {
            final authRepository = GetIt.instance<AuthRepository>();
            final isAuthenticated = authRepository.isAuthenticated();
            final isAdmin = authRepository.isAdmin();

            final isLoggingIn = state.fullPath == '/login';
            final isSigningUp = state.fullPath == '/signup'; // Assuming a signup page

            // If not authenticated, redirect to login, unless trying to login/signup
            if (!isAuthenticated && !isLoggingIn && !isSigningUp) {
              return '/login';
            }

            // If authenticated, but trying to access login/signup, redirect to home
            if (isAuthenticated && (isLoggingIn || isSigningUp)) {
              return '/';
            }

            // Admin-specific redirection
            if (state.fullPath!.startsWith('/admin') && !isAdmin) {
              // If trying to access admin routes without admin role, redirect to home
              return '/';
            }

            // Merchant-specific redirection (simplified: assumes admin role for merchant view)
            if (state.fullPath!.startsWith('/merchant') && !isAdmin) {
              // If trying to access merchant routes without admin role, redirect to home
              return '/';
            }

            return null; // No redirection needed
          },
        );
        ```
    *   **Verification:** Test navigation to admin/merchant routes with different user roles (simulated by `AuthRepository.isAdmin()`). Ensure unauthenticated users are redirected to login.

---

**Phase 8: Update Dependency Injection (API-Driven)**

**Objective:** Register all new services, repositories, and BLoCs with `GetIt`.

*   **8.1. Update `locator.dart`:**
    *   **Purpose:** Configure `GetIt` for dependency resolution.
    *   **File:** `lib/di/locator.dart`
    *   **Content Modification (add to `setupLocator()` function):**
        ```dart
        // lib/di/locator.dart
        import 'package:get_it/get_it.dart';
        import '../utils/networking_manager.dart'; // Assuming this exists

        // Services
        import '../services/auth_api_service.dart';
        import '../services/users_api_service.dart';
        import '../services/stores_api_service.dart';
        import '../services/products_api_service.dart';
        import '../services/stock_api_service.dart';
        import '../services/orders_api_service.dart';

        // Repositories
        import '../repositories/auth_repository.dart';
        import '../repositories/users_repository.dart';
        import '../repositories/stores_repository.dart';
        import '../repositories/products_repository.dart';
        import '../repositories/stock_repository.dart';
        import '../repositories/orders_repository.dart';

        // BLoCs
        import '../bloc/admin/user_management/admin_user_bloc.dart';
        import '../bloc/admin/store_management/admin_store_bloc.dart';
        import '../bloc/admin/product_management/admin_product_bloc.dart';
        import '../bloc/admin/stock_management/admin_stock_bloc.dart';
        import '../bloc/admin/order_management/admin_order_bloc.dart';
        import '../bloc/merchant/order_management/merchant_order_bloc.dart';

        final GetIt getIt = GetIt.instance;

        Future<void> setupLocator() async {
          // Core Networking
          getIt.registerLazySingleton<NetworkingManager>(() => NetworkingManager());

          // API Services
          getIt.registerLazySingleton<AuthApiService>(() => AuthApiService());
          getIt.registerLazySingleton<UsersApiService>(() => UsersApiService());
          getIt.registerLazySingleton<StoresApiService>(() => StoresApiService());
          getIt.registerLazySingleton<ProductsApiService>(() => ProductsApiService());
          getIt.registerLazySingleton<StockApiService>(() => StockApiService());
          getIt.registerLazySingleton<OrdersApiService>(() => OrdersApiService());

          // Repositories
          // AuthRepository needs to be initialized, so not lazy singleton if init() is async
          getIt.registerSingletonAsync<AuthRepository>(() async {
            final repo = AuthRepository();
            await repo.init(); // Initialize to load saved user/token
            return repo;
          });
          // Ensure AuthRepository is ready before other repos that might depend on auth state
          await getIt.isReady<AuthRepository>();

          getIt.registerLazySingleton<UsersRepository>(() => UsersRepository());
          getIt.registerLazySingleton<StoresRepository>(() => StoresRepository());
          getIt.registerLazySingleton<ProductsRepository>(() => ProductsRepository());
          getIt.registerLazySingleton<StockRepository>(() => StockRepository());
          getIt.registerLazySingleton<OrdersRepository>(() => OrdersRepository());

          // BLoCs (register as factories as they are typically scoped to a widget's lifecycle)
          getIt.registerFactory<AdminUserBloc>(() => AdminUserBloc());
          getIt.registerFactory<AdminStoreBloc>(() => AdminStoreBloc());
          getIt.registerFactory<AdminProductBloc>(() => AdminProductBloc());
          getIt.registerFactory<AdminStockBloc>(() => AdminStockBloc());
          getIt.registerFactory<AdminOrderBloc>(() => AdminOrderBloc());
          getIt.registerFactory<MerchantOrderBloc>(() => MerchantOrderBloc());
        }
        ```
    *   **Verification:** Ensure `setupLocator()` runs without errors.

---

**Phase 9: Final Adjustments and TODOs**

*   **9.1. `NetworkingManager` Integration:**
    *   **Purpose:** Ensure `NetworkingManager` correctly handles authentication tokens for API calls.
    *   **Action:** Verify or implement `NetworkingManager` to:
        *   Read the authentication token from `AuthRepository` before making authenticated requests.
        *   Add the token to the `Authorization` header (e.g., `Bearer <token>`).
        *   Handle token expiration/refresh (if the API supports refresh tokens, which it doesn't explicitly show in `openapi.json` for `SignInResponse`). For now, assume token is valid until logout or app restart.
    *   **Conceptual `NetworkingManager` (if not already existing):**
        ```dart
        // lib/utils/networking_manager.dart (Conceptual - adapt to existing structure)
        import 'dart:convert';
        import 'package:http/http.dart' as http;
        import 'package:get_it/get_it.dart';
        import '../repositories/auth_repository.dart';
        import 'api_endpoints.dart';

        class NetworkingManager {
          final http.Client _client = http.Client();
          final AuthRepository _authRepository = GetIt.instance<AuthRepository>();

          Map<String, String> _getHeaders({bool authenticated = true}) {
            final headers = {'Content-Type': 'application/json'};
            if (authenticated && _authRepository.authToken != null) {
              headers['Authorization'] = 'Bearer ${_authRepository.authToken}';
            }
            return headers;
          }

          Future<dynamic> _processResponse(http.Response response) async {
            if (response.statusCode >= 200 && response.statusCode < 300) {
              if (response.body.isNotEmpty) {
                return json.decode(response.body);
              }
              return {}; // Return empty map for 204 No Content
            } else if (response.statusCode == 401) {
              // Handle unauthorized access, e.g., force logout
              _authRepository.signOut();
              throw Exception('Unauthorized: Please log in again.');
            } else {
              throw Exception('API Error: ${response.statusCode} - ${response.body}');
            }
          }

          Future<dynamic> get({
            required String endpoint,
            Map<String, dynamic>? queryParameters,
            bool authenticated = true,
          }) async {
            final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint').replace(queryParameters: queryParameters);
            final response = await _client.get(uri, headers: _getHeaders(authenticated: authenticated));
            return _processResponse(response);
          }

          Future<dynamic> post({
            required String endpoint,
            required Map<String, dynamic> body,
            bool authenticated = true,
          }) async {
            final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
            final response = await _client.post(uri, headers: _getHeaders(authenticated: authenticated), body: json.encode(body));
            return _processResponse(response);
          }

          Future<dynamic> put({
            required String endpoint,
            required Map<String, dynamic> body,
            bool authenticated = true,
          }) async {
            final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
            final response = await _client.put(uri, headers: _getHeaders(authenticated: authenticated), body: json.encode(body));
            return _processResponse(response);
          }

          Future<dynamic> delete({
            required String endpoint,
            bool authenticated = true,
          }) async {
            final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
            final response = await _client.delete(uri, headers: _getHeaders(authenticated: authenticated));
            return _processResponse(response);
          }
        }
        ```
    *   **Verification:** Ensure API calls are correctly authenticated.

*   **9.2. Error Handling and UI Feedback:**
    *   **Purpose:** Provide user-friendly feedback for API errors.
    *   **Action:** Implement consistent error handling in BLoCs and UI. When a BLoC emits a `failure` state, the UI should display the `errorMessage`.
    *   **Verification:** Manually trigger API errors (e.g., by providing invalid data or simulating network issues) and observe UI feedback.

*   **9.3. Loading Indicators:**
    *   **Purpose:** Inform users when data is being fetched.
    *   **Action:** Ensure all UI pages that fetch data display a `CircularProgressIndicator` when the BLoC is in a `loading` state.
    *   **Verification:** Observe loading indicators during data fetching.

*   **9.4. Empty State Handling:**
    *   **Purpose:** Provide clear messages when lists are empty.
    *   **Action:** Ensure list pages display "No X found." messages when `state.items.isEmpty`.
    *   **Verification:** Test with empty data sets.

*   **9.5. `main.dart` Initialization:**
    *   **Purpose:** Ensure `GetIt` locator is set up before the app runs.
    *   **Action:** Add `await setupLocator();` in `main()` before `runApp()`.
    *   **File:** `lib/main.dart`
    *   **Content Modification:**
        ```dart
        // lib/main.dart
        import 'package:flutter/material.dart';
        import 'package:flutter_bloc/flutter_bloc.dart'; // Needed for BlocProvider
        import 'package:get_it/get_it.dart'; // Needed for GetIt

        import 'di/locator.dart'; // Import your locator setup
        import 'routing/app_router.dart'; // Import your GoRouter instance
        import 'repositories/auth_repository.dart'; // For initial auth check

        void main() async {
          WidgetsFlutterBinding.ensureInitialized();
          await setupLocator(); // Initialize GetIt dependencies

          // Optionally, pre-load AuthRepository to check authentication status early
          // This can influence the initial route of GoRouter
          await GetIt.instance.allReady(); // Ensure all async singletons are ready

          runApp(const MyApp());
        }

        class MyApp extends StatelessWidget {
          const MyApp({super.key});

          @override
          Widget build(BuildContext context) {
            // Provide AuthRepository at the top level for GoRouter redirect to access
            return RepositoryProvider<AuthRepository>(
              create: (context) => GetIt.instance<AuthRepository>(),
              child: MaterialApp.router(
                title: 'Trizy Shopping App',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                routerConfig: appRouter, // Use the configured GoRouter
              ),
            );
          }
        }
        ```
    *   **Verification:** App launches successfully.

*   **9.6. Code Formatting and Linting:**
    *   **Purpose:** Maintain code quality and consistency.
    *   **Action:** Run `flutter format .` and address any linting warnings/errors.
    *   **Verification:** No formatting or linting issues.

---

**Summary of Major Changes from Previous Plans:**

*   **Strict API Adherence:** All models (`User`, `Store`, `Product`, `Stock`, `Order`, Auth request/response) are now simplified to match the `openapi.json` specification.
*   **Role Simplification:** Only `admin` and `user` roles are supported. "Merchant" functionality is now a simplified view for `admin` users associated with a store.
*   **Feature Scope Reduction:** Removed features not supported by the API, such as rich store/product details, detailed stock pricing, granular order statuses beyond `pending`/`completed`/`cancelled`, and complex dashboard analytics.
*   **New API Services and Repositories:** Introduced dedicated `UsersApiService`, `StoresApiService`, `ProductsApiService`, `StockApiService`, `OrdersApiService` and their corresponding repositories for better modularity.
*   **BLoC Structure:** Adopted the `qwen_plan`'s detailed BLoC event/state/bloc file structure for each management area.
*   **UI Simplification:** UI pages are now basic CRUD interfaces reflecting the simplified models and operations.
*   **Enhanced Routing:** `GoRouter` redirect logic updated for basic role-based access control.
*   **Dependency Injection:** `GetIt` setup updated to include all new services, repositories, and BLoCs.
*   **Detailed Explanations:** Added more context, purpose, and verification steps for each section.

This revised plan is now "super in details" and strictly adheres to the API documentation, while incorporating the best structural practices from the `qwen_plan` files.
