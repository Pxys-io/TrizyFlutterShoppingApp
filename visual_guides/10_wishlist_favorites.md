# Wishlist/Favorites Visual Guide

## Overview
The wishlist/favorites system allows users to save products for later and manage their favorite items using the store backend API.

## API Endpoints Used
- `POST /api/likes/like` - Like a product
- `DELETE /api/likes/unlike/:productId` - Unlike a product
- `GET /api/likes/get-liked-products` - Get user's liked product IDs
- `GET /api/products/liked-products` - Get liked products with details

## Wishlist View Flow
```
[Profile/Dashboard] → [Wishlist] → [Liked Products List] → [Product Details]
```

### Wishlist Screen Components
```
┌─────────────────────────────────────────┐
│                Wishlist                 │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ [IMG] Premium Headphones            │ │
│ │ $129.99                             │ │
│ │ ★★★★☆ (4.2)                         │ │
│ │                                     │ │
│ │ ♥ [Unlike]                          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [IMG] Wireless Charger              │ │
│ │ $24.99                              │ │
│ │ ★★★☆☆ (3.8)                         │ │
│ │                                     │ │
│ │ ♥ [Unlike]                          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [IMG] Smart Watch                   │ │
│ │ $199.99                             │ │
│ │ ★★★★★ (5.0)                         │ │
│ │                                     │ │
│ │ ♥ [Unlike]                          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [Load More]                             │
└─────────────────────────────────────────┘
```

## Like/Unlike Actions
### From Product List
```
[Product Grid] → [Heart Icon Tap] → [API Call] → [Visual Feedback]
```

### From Product Detail
```
[Product Detail] → [Heart Icon Tap] → [API Call] → [Update Icon State]
```

### Like/Unlike Button States
```
┌─────────────────────────────┐
│ Product Card                │
├─────────────────────────────┤
│ [IMG] Product               │
│ $29.99                      │
│                             │
│ ♥ Unlike (filled red)       │
└─────────────────────────────┘

┌─────────────────────────────┐
│ Product Card                │
├─────────────────────────────┤
│ [IMG] Product               │
│ $29.99                      │
│                             │
│ ♡ Like (outline)            │
└─────────────────────────────┘
```

## Wishlist Management
### Bulk Actions
```
┌─────────────────────────────────────────┐
│                Wishlist                 │
├─────────────────────────────────────────┤
│ [✓ Select All] [Delete Selected]        │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ ☐ [IMG] Product 1                   │ │
│ │                                     │ │
│ │ ♥ [Unlike]                          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ ☐ [IMG] Product 2                   │ │
│ │                                     │ │
│ │ ♥ [Unlike]                          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [Load More]                             │
└─────────────────────────────────────────┘
```

## Integration with Other Screens
### Product Card with Like Status
```
┌─────────────────────────────┐
│ Product Card                │
├─────────────────────────────┤
│ [IMG] Product               │
│ $29.99                      │
│ ★★★★☆                       │
│                             │
│ ♥ (if liked) ♡ (if not)     │
└─────────────────────────────┘
```

### Like Count Display
```
┌─────────────────────────────┐
│ Product Detail              │
├─────────────────────────────┤
│ Product Image               │
│                             │
│ Product Title               │
│ $29.99                      │
│ ★★★★☆ (4.2) • 123 likes     │
│                             │
│ [Add to Cart]               │
│ ♥ Like (4.5k)               │
└─────────────────────────────┘
```

## UI/UX Considerations
- Animated heart icons
- Like count display
- Empty wishlist state
- Sync across devices
- Offline like capability
- Quick access from search
- Like notifications

## State Management
- Wishlist provider
- Individual like state
- Loading states for like operations
- Batch update operations

## Visual States
### Loading State
```
┌─────────────────────────────────────────┐
│                Wishlist                 │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ [ LOADING ]                         │ │
│ │ Product details...                  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [ LOADING ]                         │ │
│ │ Product details...                  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [Load More]                             │
└─────────────────────────────────────────┘
```

### Empty Wishlist State
```
┌─────────────────────────────────────────┐
│                Wishlist                 │
├─────────────────────────────────────────┤
│                                         │
│                 ♥                       │
│                                         │
│           Your wishlist is              │
│           empty                         │
│                                         │
│      Save items to your wishlist        │
│      to find them easily later          │
│                                         │
│         [ Start Shopping ]              │
│                                         │
└─────────────────────────────────────────┘
```

### Like Action Animation
```
[Product Card] → [Tap ♥] → [Animation] → [Filled Heart] → [API Update]

Animation: Heart icon pulses and fills with red color
Feedback: "Added to wishlist" temporary message
```

### Unlike Action Animation
```
[Wishlist Item] → [Tap ♥] → [Animation] → [Outline Heart] → [Item Removal]

Animation: Heart icon fades out and item slides away
Feedback: "Removed from wishlist" message with undo option
```