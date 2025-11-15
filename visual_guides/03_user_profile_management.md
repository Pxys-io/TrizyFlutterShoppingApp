# User Profile Management Visual Guide

## Overview
The user profile management system allows users to view and update their personal information using the store backend API.

## API Endpoints Used
- `GET /api/userProfiles/get-user-profile` - Get user profile
- `PUT /api/user-profile` - Update user profile

## Profile View Flow
```
[Dashboard] → [Profile Screen] → [View/Edit Profile]
```

### Profile View Components
```
┌─────────────────────────────┐
│        User Profile         │
├─────────────────────────────┤
│  [User Avatar]              │
│  John Doe                   │
│  john.doe@example.com       │
│                             │
│ ┌─────────────────────────┐ │
│ │ First Name: John        │ │
│ │ Last Name: Doe          │ │
│ │ Email: j...@e.com       │ │
│ │ Phone: [Edit]           │ │
│ └─────────────────────────┘ │
│                             │
│ [Edit Profile]              │
└─────────────────────────────┘
```

## Profile Edit Flow
```
[Profile Screen] → [Edit Form] → [API Call] → [Success Message]
```

### Profile Edit Form Components
```
┌─────────────────────────────┐
│      Edit Profile           │
├─────────────────────────────┤
│ First Name: [John_______]   │
│ Last Name:  [Doe________]   │
│ Phone:      [+1234567890]  │
│                             │
│ [ Save Changes ] [ Cancel ] │
└─────────────────────────────┘
```

## Profile Fields
- First Name
- Last Name
- Email (read-only)
- Phone Number
- Profile Picture (optional)

## UI/UX Considerations
- Loading states during API calls
- Success/error feedback
- Validation for phone format
- Avatar upload functionality (future enhancement)
- Email verification status indicator

## Security Measures
- Only authenticated users can access
- Email cannot be changed for security reasons
- Input sanitization on backend

## State Management
- Profile data provider
- Loading states for fetch/update operations
- Error handling for update failures

## Visual States
### Loading State
```
┌─────────────────────────────┐
│        User Profile         │
├─────────────────────────────┤
│        [ LOADING... ]       │
│                             │
│                             │
│                             │
│                             │
│ [Edit Profile]              │
└─────────────────────────────┘
```

### Edit State
```
┌─────────────────────────────┐
│      Edit Profile           │
├─────────────────────────────┤
│ First Name: [____________]  │
│ Last Name:  [____________]  │
│ Phone:      [____________]  │
│                             │
│        [ SAVING... ]        │
└─────────────────────────────┘
```

### Success State
```
┌─────────────────────────────┐
│        User Profile         │
├─────────────────────────────┤
│  [User Avatar]              │
│  John Doe                   │
│  john.doe@example.com       │
│                             │
│ ┌─────────────────────────┐ │
│ │ ✓ Profile updated       │ │
│ └─────────────────────────┘ │
│                             │
│ [Edit Profile]              │
└─────────────────────────────┘
```