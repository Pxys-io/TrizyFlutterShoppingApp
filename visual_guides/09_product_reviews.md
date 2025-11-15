# Product Reviews Visual Guide

## Overview
The product review system allows users to create, read, and manage product reviews using the store backend API.

## API Endpoints Used
- `POST /api/reviews/create-review` - Create product review
- `GET /api/reviews/get-product-reviews/:productId` - Get product reviews
- `DELETE /api/reviews/delete-review/:reviewId` - Delete user's review
- `GET /api/reviews/get-reviewable-products/:orderId` - Get products eligible for review

## Review Creation Flow
```
[Product Details] → [Write Review] → [Review Form] → [API Call] → [Review Added]
```

### Review Form Components
```
┌─────────────────────────────────────────┐
│            Write a Review               │
├─────────────────────────────────────────┤
│ Product: Wireless Headphones            │
│                                         │
│ Rate this product:                      │
│ ★★★★☆ (4/5 stars)                      │
│                                         │
│ Title: [Great product!]                 │
│                                         │
│ Review:                                 │
│ [Write your detailed review here...]    │
│                                         │
│ [ Post Review ] [ Cancel ]              │
└─────────────────────────────────────────┘
```

## Product Reviews View Flow
```
[Product Details] → [See All Reviews] → [Reviews List] → [Individual Review]
```

### Reviews List Components
```
┌─────────────────────────────────────────┐
│           Product Reviews               │
├─────────────────────────────────────────┤
│ ★★★★★                                    │
│ John D. • Verified Purchase             │
│ Great quality and sound!                │
│ [Helpful] [Flag]                        │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Reply from Seller (2 days ago):     │ │
│ │ Thank you for your feedback!        │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ★★★☆☆                                    │
│ Sarah M.                                │
│ Decent but battery life could be better │
│ [Helpful] [Flag]                        │
│                                         │
│ [Load More Reviews]                     │
│                                         │
│ [Write a Review]                        │
└─────────────────────────────────────────┘
```

## Reviewable Products Flow
```
[Order History] → [Order Details] → [Reviewable Products] → [Write Reviews]
```

### Reviewable Products Components
```
┌─────────────────────────────────────────┐
│       Products to Review                │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ [IMG] Wireless Headphones           │ │
│ │                                     │ │
│ │ ★★★☆☆ Rate Product                  │ │
│ │                                     │ │
│ │ [Write Review]                      │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [IMG] Phone Charger                 │ │
│ │                                     │ │
│ │ ★★★★☆ Rate Product                  │ │
│ │                                     │ │
│ │ [Write Review]                      │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [ Skip All ]                            │
└─────────────────────────────────────────┘
```

## Rating System
### Star Rating Components
```
┌─────────────────────────────────────────┐
│              Rate Product               │
├─────────────────────────────────────────┤
│                                         │
│ ★☆☆☆☆ 1 - Poor                         │
│ ★★☆☆☆ 2 - Fair                         │
│ ★★★☆☆ 3 - Good                         │
│ ★★★★☆ 4 - Very Good                    │
│ ★★★★★ 5 - Excellent                    │
│                                         │
│ [Select Rating]                         │
└─────────────────────────────────────────┘
```

## Review Management
### User's Own Review
```
┌─────────────────────────────────────────┐
│              Your Review                │
├─────────────────────────────────────────┤
│ ★★★★☆                                    │
│ Great product!                          │
│ [Edit] [Delete]                         │
│                                         │
│ Detailed review text here...            │
└─────────────────────────────────────────┘
```

## UI/UX Considerations
- Star rating input component
- Review character limits
- Verified purchase indicators
- Helpful/Not helpful voting
- Review moderation flags
- Reply functionality from sellers
- Review filtering (by rating, date, etc.)

## State Management
- Review list provider
- User review state
- Rating selection state
- Review submission state
- Loading states for review data

## Visual States
### Review Form Loading State
```
┌─────────────────────────────────────────┐
│            Write a Review               │
├─────────────────────────────────────────┤
│ Product: [ LOADING... ]                 │
│                                         │
│ Rate this product:                      │
│ [ LOADING STARS ]                       │
│                                         │
│ Title: [ LOADING... ]                   │
│                                         │
│ Review:                                 │
│ [ LOADING...]                          │
│                                         │
│ [ Post Review ] [ Cancel ]              │
└─────────────────────────────────────────┘
```

### Empty Reviews State
```
┌─────────────────────────────────────────┐
│           Product Reviews               │
├─────────────────────────────────────────┤
│                                         │
│              ✍️                         │
│                                         │
│        Be the first to review           │
│        this product!                    │
│                                         │
│        [ Write a Review ]               │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

### Review Submission Success
```
┌─────────────────────────────────────────┐
│           Review Posted!                │
├─────────────────────────────────────────┤
│                                         │
│           ✅                            │
│                                         │
│      Thank you for your review!         │
│                                         │
│      Your feedback helps other          │
│      shoppers make better decisions.    │
│                                         │
│        [ Close ] [ Share ]              │
└─────────────────────────────────────────┘
```

### Review Submission Error
```
┌─────────────────────────────────────────┐
│            Write a Review               │
├─────────────────────────────────────────┤
│ Product: Wireless Headphones            │
│                                         │
│ Rate this product:                      │
│ ★★★★☆                                   │
│                                         │
│ Title: [Great product!]                 │
│                                         │
│ Review:                                 │
│ [Write your detailed review here...]    │
│                                         │
│ ❌ You must have purchased this         │
│    product to review it                │
│                                         │
│ [ Back to Product ]                     │
└─────────────────────────────────────────┘
```