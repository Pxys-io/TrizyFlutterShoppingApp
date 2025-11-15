# New Feature Implementation Plan: Admin and Store-Owner/Merchant Pages

This document outlines the plan for implementing new pages for Admin and Store-Owner/Merchant roles, leveraging the updated API endpoints. The implementation will follow the existing application architecture, focusing on creating new UI components, integrating with the API, and managing state.

## API Endpoints Overview

Based on the provided API documentation, the following endpoints are relevant for the new roles:

### Admin Endpoints

*   **Create Store:**
    *   **HTTP Method:** `POST`
    *   **URL Path:** `/api/stores`
    *   **Headers:** `Authorization: Bearer <admin_access_token>`, `Content-Type: application/json`
    *   **Request Body:** `{ "name": "Store Name", "address": "123 Main St", ... }`
    *   **Expected Result:** `201 Created` with the new store object.
*   **Create Product:**
    *   **HTTP Method:** `POST`
    *   **URL Path:** `/api/products`
    *   **Headers:** `Authorization: Bearer <admin_access_token>`, `Content-Type: application/json`
    *   **Request Body:** `{ "title": "Product Title", "description": "...", "price": 99.99, "imageURLs": [], "category": "categoryId", "cargoWeight": 0.5 }`
    *   **Expected Result:** `201 Created` with the new product object.
*   **Create Stock:**
    *   **HTTP Method:** `POST`
    *   **URL Path:** `/api/stock`
    *   **Headers:** `Authorization: Bearer <admin_access_token>`, `Content-Type: application/json`
    *   **Request Body:** `{ "storeId": "storeId", "productId": "productId", "totalQuantity": 100, "pricing": [] }`
    *   **Expected Result:** `201 Created` with the new stock object.
*   **Approve Order (Admin):**
    *   **HTTP Method:** `PUT`
    *   **URL Path:** `/api/storeOrders/:storeOrderId/confirm`
    *   **Headers:** `Authorization: Bearer <admin_access_token>`, `Content-Type: application/json`
    *   **Request Body:** `{}`
    *   **Expected Result:** `200 OK` with the updated store order object (state: "confirmed").
*   **Update Order Status:** (Admin can also use this)
    *   **HTTP Method:** `PUT`
    *   **URL Path:** `/api/storeOrders/:storeOrderId`
    *   **Headers:** `Authorization: Bearer <admin_access_token>`, `Content-Type: application/json`
    *   **Request Body:** `{ "state": "prepared" }` (e.g., "prepared", "shipped", "delivered")
    *   **Expected Result:** `200 OK` with the updated store order object.
*   **Get Store Orders:** (Admin can also use this to view all store orders)
    *   **HTTP Method:** `GET`
    *   **URL Path:** `/api/storeOrders?storeId=<store_id>`
    *   **Headers:** `Authorization: Bearer <admin_access_token>`
    *   **Expected Result:** `200 OK` with a list of store order objects.

### Store-Owner/Merchant Endpoints

*   **Update Order Status:**
    *   **HTTP Method:** `PUT`
    *   **URL Path:** `/api/storeOrders/:storeOrderId`
    *   **Headers:** `Authorization: Bearer <merchant_access_token>`, `Content-Type: application/json`
    *   **Request Body:** `{ "state": "prepared" }`
    *   **Expected Result:** `200 OK` with the updated store order object.
*   **Get Store Orders:**
    *   **HTTP Method:** `GET`
    *   **URL Path:** `/api/storeOrders?storeId=<store_id>`
    *   **Headers:** `Authorization: Bearer <merchant_access_token>`
    *   **Expected Result:** `200 OK` with a list of store order objects specific to the merchant's store.

### Inferred Endpoints (to be confirmed/implemented on backend if not existing)

For full management capabilities, the following standard RESTful endpoints are assumed to be available or will need to be implemented on the backend:

*   **Get All Stores:** `GET /api/stores` (Admin)
*   **Get Store by ID:** `GET /api/stores/:storeId` (Admin, Merchant)
*   **Update Store:** `PUT /api/stores/:storeId` (Admin, Merchant)
*   **Delete Store:** `DELETE /api/stores/:storeId` (Admin)
*   **Get All Products:** `GET /api/products` (Admin)
*   **Get Products by Store:** `GET /api/products?storeId=<store_id>` (Admin, Merchant)
*   **Update Product:** `PUT /api/products/:productId` (Admin, Merchant)
*   **Delete Product:** `DELETE /api/products/:productId` (Admin)
*   **Get Stock by Store/Product:** `GET /api/stock?storeId=<store_id>&productId=<productId>` (Admin, Merchant)
*   **Update Stock:** `PUT /api/stock/:stockId` (Admin, Merchant)

## Phase 1: Admin Pages Implementation

### 1. Admin Dashboard
*   **Purpose:** Provide an overview for administrators, including quick access to store, product, and order management.
*   **Components:**
    *   `AdminDashboardScreen` (new view)
    *   Cards/widgets displaying summary statistics (e.g., total stores, total products, pending orders).
    *   Navigation links to Store Management, Product Management, and Order Management sections.
*   **API Integration:** Minimal direct API calls; primarily aggregates data from other management screens or uses dedicated summary endpoints if available.

### 2. Store Management
*   **Purpose:** Allow administrators to create, view, update, and delete stores.
*   **Components:**
    *   `AdminStoreListScreen` (new view): Displays a list of all stores.
    *   `AdminStoreDetailScreen` (new view): Displays details of a single store, with options to edit or delete.
    *   `AdminStoreCreateEditForm` (new component): Form for creating a new store or editing an existing one.
*   **API Integration:**
    *   `GET /api/stores` (inferred): Fetch all stores for `AdminStoreListScreen`.
    *   `POST /api/stores`: Create new store via `AdminStoreCreateEditForm`.
    *   `GET /api/stores/:storeId` (inferred): Fetch single store details for `AdminStoreDetailScreen`.
    *   `PUT /api/stores/:storeId` (inferred): Update store via `AdminStoreCreateEditForm`.
    *   `DELETE /api/stores/:storeId` (inferred): Delete store from `AdminStoreDetailScreen`.

### 3. Product Management
*   **Purpose:** Allow administrators to create, view, update, and delete products.
*   **Components:**
    *   `AdminProductListScreen` (new view): Displays a list of all products.
    *   `AdminProductDetailScreen` (new view): Displays details of a single product, with options to edit or delete.
    *   `AdminProductCreateEditForm` (new component): Form for creating a new product or editing an existing one.
*   **API Integration:**
    *   `GET /api/products` (inferred): Fetch all products for `AdminProductListScreen`.
    *   `POST /api/products`: Create new product via `AdminProductCreateEditForm`.
    *   `GET /api/products/:productId`: Fetch single product details for `AdminProductDetailScreen`.
    *   `PUT /api/products/:productId` (inferred): Update product via `AdminProductCreateEditForm`.
    *   `DELETE /api/products/:productId` (inferred): Delete product from `AdminProductDetailScreen`.

### 4. Stock Management
*   **Purpose:** Allow administrators to manage stock levels for products in various stores.
*   **Components:**
    *   `AdminStockListScreen` (new view): Displays stock levels per product per store.
    *   `AdminStockCreateEditForm` (new component): Form for creating or updating stock.
*   **API Integration:**
    *   `GET /api/stock?storeId=...&productId=...` (inferred): Fetch stock information.
    *   `POST /api/stock`: Create new stock entry.
    *   `PUT /api/stock/:stockId` (inferred): Update existing stock.

### 5. Admin Order Management
*   **Purpose:** Allow administrators to view all orders and approve them.
*   **Components:**
    *   `AdminOrderListScreen` (new view): Displays a list of all store orders.
    *   `AdminOrderDetailScreen` (new view): Displays details of a specific order.
*   **API Integration:**
    *   `GET /api/storeOrders?storeId=<store_id>`: Fetch store orders (can filter by store or get all if `storeId` is optional/omitted for admin).
    *   `PUT /api/storeOrders/:storeOrderId/confirm`: Approve an order.
    *   `PUT /api/storeOrders/:storeOrderId`: Update order status.

## Phase 2: Store-Owner/Merchant Pages Implementation

### 1. Merchant Dashboard
*   **Purpose:** Provide an overview for store owners/merchants, focusing on their specific store's performance and orders.
*   **Components:**
    *   `MerchantDashboardScreen` (new view)
    *   Cards/widgets displaying store-specific statistics (e.g., total products in their store, pending orders for their store).
    *   Navigation links to their Store-Specific Order Management.
*   **API Integration:** Aggregates data from store-specific endpoints.

### 2. Store-Specific Order Management
*   **Purpose:** Allow store owners/merchants to view and update the status of orders for their store.
*   **Components:**
    *   `MerchantOrderListScreen` (new view): Displays a list of orders for the merchant's store.
    *   `MerchantOrderDetailScreen` (new view): Displays details of a specific order, with options to update status.
*   **API Integration:**
    *   `GET /api/storeOrders?storeId=<merchant_store_id>`: Fetch orders for the merchant's store.
    *   `PUT /api/storeOrders/:storeOrderId`: Update order status (e.g., "prepared", "shipped", "delivered").

## Architecture Considerations

*   **BLoC Pattern:** Continue using the existing BLoC pattern for state management. New BLoCs will be created for `AdminStoreBloc`, `AdminProductBloc`, `AdminStockBloc`, `AdminOrderBloc`, and `MerchantOrderBloc`.
*   **Repositories:** New repositories (`AdminRepository`, `MerchantRepository`) or extensions to existing ones will be needed to encapsulate API calls for these new features.
*   **Routing:** Update the `lib/routing` configuration to include the new screens.
*   **Components:** Re-use existing UI components from `lib/components` where possible (e.g., `basic_list_item.dart`, `app_bar_with_back_button.dart`). Create new specific components as needed (e.g., `StoreCard`, `ProductManagementCard`).
*   **Authentication/Authorization:** Ensure that access to these new pages and their corresponding API calls is properly restricted based on user roles (admin, merchant). This will involve checking `isAdmin` flag or similar role indicators from the user profile.

This plan provides a structured approach to integrating the new API capabilities into the Flutter application, ensuring a clear separation of concerns and adherence to the existing architectural patterns.
