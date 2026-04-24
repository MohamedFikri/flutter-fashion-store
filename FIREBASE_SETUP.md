# LUXE Fashion Store — Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **"Add project"**
3. Name it `luxe-fashion-store` → Continue
4. Disable Google Analytics (optional) → Create project

---

## Step 2: Add Android App to Firebase

1. In Firebase Console → **Project Overview** → click the Android icon
2. **Android package name**: `com.example.fashion_store`
3. **App nickname**: LUXE Fashion Store
4. Click **"Register app"**
5. Download **`google-services.json`**
6. Place it in: `android/app/google-services.json`

---

## Step 3: Enable Authentication

1. Firebase Console → **Authentication** → Get started
2. Sign-in method tab → **Email/Password** → Enable → Save

---

## Step 4: Create Firestore Database

1. Firebase Console → **Firestore Database** → Create database
2. Select **"Start in test mode"** (for development)
3. Choose a region → Enable

### Firestore Security Rules (for production):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /products/{productId} {
      allow read: if true;
      allow write: if false;
    }
    match /orders/{orderId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

---

## Step 5: Seed Products into Firestore

In your app, call this **once** after login to populate products:

```dart
// In any screen or a debug button:
await ProductService().seedProducts();
```

Or add a temporary button in HomeScreen for testing:
```dart
ElevatedButton(
  onPressed: () => ProductService().seedProducts(),
  child: Text('Seed Products'),
)
```

---

## Step 6: Run the App

```bash
flutter pub get
flutter run
```

---

## Project Structure

```
lib/
├── main.dart                    # Entry point + Splash Screen
├── utils/
│   └── app_theme.dart          # Colors, TextStyles, Theme
├── models/
│   └── models.dart             # ProductModel, CartItem, Order, User
├── services/
│   ├── auth_service.dart       # Firebase Auth
│   ├── product_service.dart    # Firestore products
│   └── order_service.dart      # Firestore orders
├── providers/
│   └── providers.dart          # AuthProvider, CartProvider
├── widgets/
│   └── widgets.dart            # Reusable UI components
└── screens/
    ├── login_screen.dart
    ├── register_screen.dart
    ├── main_nav_screen.dart    # Bottom navigation
    ├── home_screen.dart        # Banners, categories, featured
    ├── product_listing_screen.dart
    ├── product_detail_screen.dart
    ├── cart_screen.dart
    ├── checkout_screen.dart    # 3-step checkout
    ├── order_success_screen.dart
    ├── orders_screen.dart      # Order history
    └── profile_screen.dart     # View & edit profile
```

---

## Dependencies Used

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | User authentication |
| `cloud_firestore` | Products, orders, users |
| `firebase_storage` | Image storage (optional) |
| `provider` | State management |
| `cached_network_image` | Efficient image loading |
| `shimmer` | Loading skeleton effect |
| `flutter_rating_bar` | Star ratings |
| `intl` | Date formatting |
| `uuid` | Unique order IDs |

---

## Features Implemented

### Phase 1 (UI)
- [x] Login / Registration screens
- [x] Home screen (banners, categories, featured products)
- [x] Product Listing (grid + list view, sort)
- [x] Product Detail (image gallery, size/color, add to cart)
- [x] Cart screen
- [x] 3-step Checkout UI
- [x] Profile screen
- [x] Bottom navigation

### Phase 2 (Firebase)
- [x] Firebase Auth (login, register, logout)
- [x] Firestore product display
- [x] Category browsing
- [x] Cart (add, remove, update)
- [x] Place order → saved to Firestore
- [x] Order history from Firestore
- [x] User profile view & edit
- [x] Product seeding via ProductService
