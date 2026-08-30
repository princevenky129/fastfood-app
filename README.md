# 🍔 FastFood Ordering System

A smart fast food ordering system that eliminates long queues and order confusion at local fast food shops. Customers scan a QR code and order from a website — no app install needed. The shop owner manages everything from a Flutter mobile app.

---

## 🌐 Customer Ordering Panel (Website)

> **Live URL:** [https://web-nu-umber-54.vercel.app](https://web-nu-umber-54.vercel.app)

Customers scan the QR code displayed at the shop → website opens on their phone → they browse the menu, add items to cart, and pay via **UPI or Cash** → they receive a **Token Number**.

No app download. No registration. Just scan and order.

---

## 📱 Shop Owner App (Flutter Mobile)

The owner installs the Android app to:
- View all incoming orders in real-time, sorted by token number
- Mark orders as completed
- Manage the menu (add/edit/toggle availability/upload photos)
- Generate and display the shop QR code for customers

---

## 💡 Problem It Solves

During peak hours at local fast food shops:
- Customers queue up and shout orders across the counter
- The cook is busy cooking and tries to remember multiple orders
- Orders get missed or mixed up when many people order at once
- No clear priority on who ordered first

**This app fixes that** — every order comes in digitally with a token number. The cook always knows what to prepare next.

---

## 🔄 How It Works

```
Customer                        Owner (Mobile App)
────────                        ──────────────────
Scan QR code at shop     →      QR generated inside app
Opens website            →      https://web-nu-umber-54.vercel.app
Browses menu & orders    →      Order appears in real-time queue
Pays via UPI or Cash     →      Cook sees token number & items
Gets Token Number        →      Marks order as complete when done
```

---

## 📱 App Screens

### Customer Panel (Website)
- Browse menu by category (Rice, Noodles, Kabab, Gobi, Soft Drinks)
- Search for dishes
- Add items to cart
- Checkout with UPI or Cash payment
- Receive token number on order confirmation

### Admin Panel (Mobile App)
| Screen | Description |
|---|---|
| **Order Queue** | Live orders sorted by token — Active & Completed tabs |
| **Menu Management** | Add, edit, delete dishes — upload photos from gallery |
| **QR Code Screen** | Generates scannable QR for the shop + UPI payment QR |
| **Auth Screen** | Owner login/signup with session persistence |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) |
| Customer Website | Flutter Web — deployed on Vercel |
| Real-Time Order Sync | Firebase Realtime Database |
| Local Session Storage | Shared Preferences |
| QR Code Generation | qr_flutter |
| UPI Payment | url_launcher (upi:// deep link) |
| Admin Photo Upload | image_picker |
| Typography | Google Fonts (Poppins, Inter, Space Grotesk) |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point & auth routing
├── models/
│   ├── menu_item.dart                 # MenuItem model + seed menu data
│   └── order.dart                     # FoodOrder, OrderLineItem models
├── screens/
│   ├── auth/
│   │   └── auth_screen.dart           # Login & Sign Up screen
│   ├── admin/
│   │   ├── admin_home.dart            # Admin sidebar navigation shell
│   │   ├── order_queue_screen.dart    # Live order queue with token sorting
│   │   └── menu_management_screen.dart # Full menu CRUD with photo upload
│   └── customer/
│       ├── customer_home.dart         # Menu browse, search, cart
│       ├── checkout_modal.dart        # Payment selection & order placement
│       └── order_success_dialog.dart  # Token number confirmation screen
├── services/
│   ├── auth_service.dart              # Account registration, login, session
│   ├── menu_repository.dart           # Menu item CRUD with local persistence
│   └── order_repository.dart          # Real-time Firebase order sync
├── theme/
│   ├── app_colors.dart                # Brand color tokens
│   └── app_theme.dart                 # Material 3 theme definitions
└── widgets/
    ├── order_chit_card.dart           # Order ticket card widget
    └── shop_qr_dialog.dart            # QR code generator modal
```

---

## 🚀 Run Locally

### Prerequisites
- Flutter SDK v3.19+
- Dart SDK v3.3+
- Android Studio (for Android emulator)

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/princevenky129/fastfood-app.git
cd fastfood-app

# 2. Install dependencies
flutter pub get

# 3. Run on Android device or emulator
flutter run

# 4. Run customer panel on browser (for testing)
flutter run -d chrome
```

---

## 📦 Build

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Web (Customer Panel)
```bash
flutter build web --release
cd build/web
npx vercel --prod --yes
```

---

## 🧪 End-to-End Test

1. Open **[https://web-nu-umber-54.vercel.app](https://web-nu-umber-54.vercel.app)** on any phone
2. Browse the menu, add items, and place an order
3. Open the FastFood Android app
4. Watch the order appear instantly in the **Active Queue** with a token number

---

## 📌 Notes

- The mobile app is for the **shop owner only** — not for customers
- Customers never need to download an app or create an account
- Token numbers ensure the cook always knows which order to prepare first
- The owner can switch between Customer view and Admin view inside the app for testing

---

Built with ❤️ to solve a real problem at local fast food shops.
