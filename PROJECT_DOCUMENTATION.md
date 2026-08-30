# 🍔 FastFood App — Complete Project Documentation

Welcome to the official technical and operational documentation for the **FastFood** application. This document details the complete end-to-end architecture, technology stack, features, installation instructions, database design, and deployment steps.

---

## 📌 1. Project Overview

**FastFood** is a modern, cross-platform fast-food ordering and kitchen management system built to streamline restaurant operations and customer experience.

### Key Capabilities:
1. **Customer QR Ordering (Web & App)**: Customers scan an in-shop QR code or visit the web link to browse the menu, filter by category, search dishes, and place orders directly from their smartphones.
2. **Kitchen Admin Queue (Mobile App)**: Kitchen staff receive orders in real-time, view detailed item breakdowns, update order statuses (*Pending* → *Preparing* → *Ready for Pickup* → *Completed*), and manage menu items.
3. **Real-Time Cloud Synchronization**: Built with a live Firebase database backend so orders placed from any web browser appear instantly on the admin kitchen display.
4. **Persistent Authentication**: One-time sign-up and login for mobile app users with session persistence via local storage.

---

## 🛠️ 2. Technology Stack & Languages

| Technology Layer | Tool / Library Used | Purpose |
| :--- | :--- | :--- |
| **Programming Language** | **Dart** (v3.3.0+) | Core programming language for cross-platform app logic |
| **UI Framework** | **Flutter** (v3.19+) | Single codebase for Android Native App & Web |
| **Web Hosting** | **Vercel** | Free high-performance web deployment for customer panel |
| **Cloud Database** | **Firebase Realtime Database** | Real-time JSON data store for order sync |
| **Session Storage** | `shared_preferences` | Local key-value store for persistent login state |
| **Typography & Theme** | `google_fonts` | Space Grotesk, Outfit, Inter, and Poppins fonts |
| **QR Code Generation** | `qr_flutter` | Dynamic in-shop QR code generation |
| **Photo Upload** | `image_picker` | Admin food item image selection |
| **Deep Linking / Payments**| `url_launcher` | Direct integration with UPI apps (GPay, PhonePe, Paytm) |
| **HTTP Communication** | `http` | REST client for Firebase cloud sync |

---

## 🎨 3. Design Aesthetic & Branding

- **Brand Colors**: Warm Orange (`#FF6B00`), Vibrant Crimson Red (`#E52E71`), Dark Charcoal (`#0F0F13` / `#1E1E26`).
- **Design Style**: Inspired by modern food delivery applications (Swiggy & Zomato), utilizing glassmorphism cards, vibrant gradients, micro-animations, and high-contrast badges.
- **Custom Logo**: High-resolution 3D icon featuring a golden lightning bolt and gourmet fast food burger emblem.

---

## 🔐 4. System Architecture & Authentication

### User Authentication Flow
1. **Sign Up**: New users create an account with Name, Email, and Password.
2. **Login**: Existing users sign in with their credentials.
3. **Session Persistence**: Upon successful authentication, `AuthService` writes `auth_is_logged_in = true` and user metadata to `SharedPreferences`.
4. **Auto-Login**: When launching the mobile app, `_checkAuthStatus()` reads `SharedPreferences`. If authenticated, the app opens the main interface immediately without prompting for credentials.
5. **Logout**: Tapping the Logout button `[ 🚪 ]` displays a confirmation dialog. Confirming clears the stored credentials and returns the user to the login screen.

> **Note on Web Access**: Web users (customers scanning QR codes) bypass auth screens to ensure friction-free ordering.

---

## 🌐 5. Real-Time Cloud Data Synchronization

Orders are synchronized across devices using Firebase Realtime Database via REST endpoints:

- **Database Base URL**:
  `https://fastfood-app-venky-7894e-default-rtdb.asia-southeast1.firebasedatabase.app`
- **Data Structure (`/orders/{orderId}.json`)**:
  ```json
  {
    "id": "ORD-1001",
    "tokenNumber": 1,
    "customerName": "Customer #1",
    "items": [
      {
        "menuItemId": "m1",
        "name": "Classic Cheeseburger",
        "quantity": 2,
        "price": 149.0
      }
    ],
    "totalAmount": 298.0,
    "paymentMethod": "Pay at Counter",
    "status": "pending",
    "placedAt": "2026-08-29T20:15:00.000Z"
  }
  ```

---

## 💻 6. Project Directory Structure

```
fastfood_app/
├── android/                   # Android native app configuration & manifest
│   └── app/src/main/
│       ├── AndroidManifest.xml # Label: "FastFood", launcher icon config
│       └── res/                # Swiggy/Zomato style launcher mipmaps
├── lib/
│   ├── main.dart              # App entrypoint, auth state & navigation
│   ├── models/
│   │   ├── menu_item.dart     # Food dish data model & seed menu
│   │   └── order.dart         # Food order & order line item models with JSON serialization
│   ├── screens/
│   │   ├── admin/             # Kitchen queue, order management, menu CRUD
│   │   │   ├── admin_home.dart
│   │   │   ├── menu_management_screen.dart
│   │   │   └── order_queue_screen.dart
│   │   ├── auth/              # Authentication UI (Login & Sign Up)
│   │   │   └── auth_screen.dart
│   │   └── customer/          # Customer ordering & checkout experience
│   │       ├── checkout_modal.dart
│   │       ├── customer_home.dart
│   │       └── order_success_dialog.dart
│   ├── services/
│   │   ├── auth_service.dart  # Account registration, login, session persistence
│   │   └── order_repository.dart # Real-time order sync with Firebase RTDB
│   └── theme/
│       ├── app_colors.dart    # Curated color system tokens
│       └── app_theme.dart     # Material 3 dark/light theme definitions
├── web/                       # Web build target, index.html & icons
│   ├── favicon.png
│   ├── index.html             # Title: "FastFood"
│   └── manifest.json
└── pubspec.yaml               # Flutter package dependencies
```

---

## 🚀 7. Installation & Setup Guide

### Prerequisites:
- **Flutter SDK** (v3.19.0 or later)
- **Dart SDK** (v3.3.0 or later)
- **Android Studio** (for Android SDK & Gradle tools)
- **Node.js & Vercel CLI** (optional, for web deployments)

### Steps to Run Locally:

1. **Clone or navigate to the project directory**:
   ```bash
   cd fastfood_app
   ```

2. **Install Flutter package dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on an Android device or emulator**:
   ```bash
   flutter run
   ```

4. **Run on Web Browser**:
   ```bash
   flutter run -d chrome
   ```

---

## 📦 8. Build & Deployment Commands

### Build Android Release APK:
To create a standalone `.apk` installer file for Android phones:
```bash
flutter build apk --release
```
- **Output location**:
  `build/app/outputs/flutter-apk/app-release.apk`

### Build & Deploy Web Application to Vercel:
1. **Compile web release bundle**:
   ```bash
   flutter build web --release --no-wasm-dry-run
   ```
2. **Deploy output to Vercel**:
   ```bash
   cd build/web
   npx vercel --prod --yes
   ```
- **Production Web URL**:
  `https://web-nu-umber-54.vercel.app`

---

## 📱 9. How to Test End-to-End

1. **Open Customer Web Ordering**:
   Visit **[https://web-nu-umber-54.vercel.app](https://web-nu-umber-54.vercel.app)** on any phone or PC.
2. **Place an Order**:
   Select food items, add to cart, choose *Pay at Counter* or *UPI*, and submit.
3. **Check Kitchen Admin App**:
   Open the **FastFood** Android app on your phone.
4. **Observe Real-Time Sync**:
   The order placed on the web instantly appears in the **Active Order Queue** with token number, item list, and timestamp!

---

## ✨ Summary

The **FastFood** platform delivers a complete, production-ready solution combining mobile app authentication, real-time cloud data sync, automated web deployments, and intuitive kitchen display management.
