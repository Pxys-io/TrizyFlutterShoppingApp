# Authentication System Visual Guide

## Overview
The authentication system handles user registration, login, logout, and token management using the store backend API.

## API Endpoints Used
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `POST /api/refresh` - Token refresh
- `POST /api/logout` - User logout
- `POST /api/check-tokens` - Token validation

## Registration Flow
```
[Start] → [Registration Form] → [API Call] → [Success/Error]
```

### Registration Form Components
```
┌─────────────────────────────┐
│        Registration         │
├─────────────────────────────┤
│ First Name: [____________]  │
│ Last Name:  [____________]  │
│ Email:      [____________]  │
│ Password:   [____________]  │
│                             │
│ [ Register ] [ Login ]      │
└─────────────────────────────┘
```

### Input Validation
- Email format validation
- Password strength (min 6 characters)
- Required field validation
- Duplicate email detection

## Login Flow
```
[Start] → [Login Form] → [Token Request] → [Token Storage] → [Home Screen]
```

### Login Form Components
```
┌─────────────────────────────┐
│          Login              │
├─────────────────────────────┤
│ Email:    [____________]    │
│ Password: [____________]    │
│                             │
│ [ Forgot Password? ]        │
│                             │
│ [ Login ] [ Register ]      │
└─────────────────────────────┘
```

## Logout Flow
```
[Action] → [API Call] → [Token Clear] → [Navigate to Login]
```

## Token Management
### Storage
- Access token: stored in SharedPreferences
- Refresh token: stored in SharedPreferences
- Token validation on app start

### Refresh Flow
```
[Token Expiry] → [Refresh Token Call] → [New Tokens] → [Continue Request]
```

## UI/UX Considerations
- Loading states during API calls
- Error messaging for failed authentication
- Password visibility toggle
- Social login options (optional)
- Remember me functionality

## Security Measures
- Password hashing (handled by backend)
- Secure token storage
- Token expiration handling
- Automatic logout on token invalidation

## State Management
- Auth state provider to track user session
- Loading state during authentication processes
- Error state for displaying authentication issues

## Visual States
### Loading State
```
┌─────────────────────────────┐
│          Login              │
├─────────────────────────────┤
│ Email:    [____________]    │
│ Password: [____________]    │
│                             │
│        [ LOADING... ]       │
└─────────────────────────────┘
```

### Error State
```
┌─────────────────────────────┐
│          Login              │
├─────────────────────────────┤
│ Email:    [____________]    │
│ Password: [____________]    │
│                             │
│  ❌ Invalid credentials     │
│                             │
│ [ Login ] [ Register ]      │
└─────────────────────────────┘
```