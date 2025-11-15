# Project Structure Visual Guide

## Overview
This guide outlines the project structure needed to implement the complete functionality of the Trizy shopping app using the store backend API.

## Folder Structure
```
lib/
├── main.dart
├── app.dart
├── models/                 # Data models from API
│   ├── user.dart
│   ├── product.dart
│   ├── order.dart
│   ├── cart.dart
│   ├── address.dart
│   ├── review.dart
│   ├── category.dart
│   ├── deal.dart
│   └── store.dart
├── services/              # API service classes
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── cart_service.dart
│   ├── order_service.dart
│   ├── address_service.dart
│   ├── review_service.dart
│   └── payment_service.dart
├── repositories/          # Repository pattern implementation
│   ├── auth_repository.dart
│   ├── product_repository.dart
│   ├── cart_repository.dart
│   ├── order_repository.dart
│   └── ...
├── views/                 # UI Screens
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── forgot_password_page.dart
│   ├── home/
│   │   ├── home_page.dart
│   │   ├── deals_section.dart
│   │   └── best_of_week_section.dart
│   ├── product/
│   │   ├── product_list_page.dart
│   │   ├── product_detail_page.dart
│   │   └── search_page.dart
│   ├── cart/
│   │   ├── cart_page.dart
│   │   └── checkout_page.dart
│   ├── profile/
│   │   ├── profile_page.dart
│   │   ├── address_page.dart
│   │   └── order_history_page.dart
│   └── common/
│       ├── app_bar.dart
│       ├── bottom_nav.dart
│       └── widgets/
├── utils/
│   ├── api_endpoints.dart
│   ├── networking_manager.dart
│   ├── validators.dart
│   └── constants.dart
├── providers/             # State management (Provider/BLoC)
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── product_provider.dart
│   └── ...
└── theme/
    ├── app_theme.dart
    └── colors.dart
```

## Architecture Pattern
Uses the Repository pattern with dependency injection:
- Models: Define data structures
- Services: Handle API calls
- Repositories: Business logic layer
- Views: UI components
- Providers: State management

## Key Dependencies
- http: For API calls
- provider: For state management
- shared_preferences: For local data persistence
- stripe_payment: For payment processing
- cached_network_image: For image caching

## Visual Components Hierarchy
1. App (main entry point)
2. Authentication Flow
   - Login/Register
   - Token management
3. Main App Shell
   - Bottom Navigation
   - Tab-based navigation
4. Feature Modules
   - Each with its own screens and components