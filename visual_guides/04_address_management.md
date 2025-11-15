# Address Management Visual Guide

## Overview
The address management system allows users to create, view, edit, and delete their shipping addresses using the store backend API.

## API Endpoints Used
- `POST /api/address/create-user-address` - Create new address
- `GET /api/address/get-all-addresses` - Get user's addresses
- `PUT /api/address/update-address/:addressId` - Update address
- `DELETE /api/address/delete-address/:addressId` - Delete address
- `GET /api/address/get-default-address` - Get default address

## Address List Flow
```
[Dashboard] → [Address Book] → [List of Addresses]
```

### Address List Components
```
┌─────────────────────────────────┐
│         Address Book            │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ Home Address ✨             │ │
│ │ John Doe                    │ │
│ │ 123 Main St, Apt 4B         │ │
│ │ New York, NY 10001          │ │
│ │ (555) 123-4567              │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Work Address                │ │
│ │ John Doe                    │ │
│ │ 456 Office Blvd             │ │
│ │ New York, NY 10002          │ │
│ │ (555) 987-6543              │ │
│ └─────────────────────────────┘ │
│                                 │
│ [ + Add New Address ]           │
└─────────────────────────────────┘
```

## Create Address Flow
```
[Address List] → [Create Form] → [API Call] → [Address Added]
```

### Create Address Form Components
```
┌─────────────────────────────────┐
│        Create Address           │
├─────────────────────────────────┤
│ Full Name:    [_____________]   │
│ Phone:        [_____________]   │
│ Address:      [_____________]   │
│ City:         [_____________]   │
│ State:        [_____________]   │
│ Postal Code:  [_____________]   │
│ Country:      [_____________]   │
│ Address Type: ○ Home ○ Work    │
│ Set as Default: [✓]            │
│                                 │
│ [ Save ] [ Cancel ]             │
└─────────────────────────────────┘
```

## Update Address Flow
```
[Address List] → [Select Address] → [Edit Form] → [API Call] → [Address Updated]
```

## Delete Address Flow
```
[Address List] → [Select Address] → [Confirm Delete] → [API Call] → [Address Deleted]
```

## Address Fields
- Full Name
- Phone Number
- Street Address
- City
- State/Province
- Postal/ZIP Code
- Country
- Address Type (Home/Work/Other)
- Default Address Flag

## UI/UX Considerations
- Default address indicator (star icon)
- Address type selection
- Form validation for required fields
- Country selection dropdown
- Set as default option
- Address validation feedback
- Loading states during operations

## State Management
- Address list provider
- Current address selection
- Form submission states
- Error handling for CRUD operations

## Visual States
### Loading State
```
┌─────────────────────────────────┐
│         Address Book            │
├─────────────────────────────────┤
│           [ LOADING... ]        │
│                                 │
│ [ + Add New Address ]           │
└─────────────────────────────────┘
```

### Form Error State
```
┌─────────────────────────────────┐
│        Create Address           │
├─────────────────────────────────┤
│ Full Name:    [_____________]   │
│ Phone:        [_____________]   │
│ Address:      [_____________]   │
│ City:         [_____________]   │
│ State: ✓      [_____________]   │
│ Postal Code:  [_____________]   │
│ Country:      [_____________]   │
│ ❌ State is required            │
│                                 │
│ [ Save ] [ Cancel ]             │
└─────────────────────────────────┘
```

### Success State
```
┌─────────────────────────────────┐
│         Address Book            │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ New Address ✨              │ │
│ │ John Smith                  │ │
│ │ 789 New St                  │ │
│ │ Los Angeles, CA 90001       │ │
│ │ (555) 111-2222              │ │
│ └─────────────────────────────┘ │
│                                 │
│ ✓ Address created successfully  │
│ [ + Add New Address ]           │
└─────────────────────────────────┘
```