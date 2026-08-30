# Fast Food App — Step 1: Admin Orders + Menu (UI foundation)

This is the first build pass: the visual foundation, data models, and the
**Admin → Orders** screen (Active queue + Completed grouped by date), running
on realistic mock data so it's fully interactive right now, no backend setup
needed yet.

## Run it

You'll need the Flutter SDK installed on your machine (this sandbox doesn't
have network access to fetch it, so run these locally):

```bash
flutter pub get
flutter run          # pick any connected device / simulator
```

On the Orders screen, tap **"Simulate order"** (top right) a few times — new
tickets slide into the Active tab in real time, sorted P1/P2/P3 by arrival.
Tap the cash toggle or **Complete** on any card to see it move to the
Completed tab, grouped by date.

## What's built

- `lib/theme/` — color tokens + typography (Space Grotesk / Inter / JetBrains
  Mono) shared across the whole app
- `lib/models/` — `MenuItem`, `FoodOrder`, `OrderLineItem`
- `lib/services/order_repository.dart` — in-memory stand-in for Firestore;
  same shape/methods you'd call against real Firestore, so swapping the
  backend later won't touch the UI code
- `lib/widgets/order_chit_card.dart` — the order "ticket" card (signature
  visual element)
- `lib/screens/admin/order_queue_screen.dart` — Active + Completed tabs
- `lib/screens/admin/menu_management_screen.dart` — menu grid (add/edit/photo
  buttons are wired up visually, not functionally yet)
- `lib/screens/admin/admin_home.dart` — sidebar shell (Menu / Orders)

## Next steps (in order)

1. **Menu CRUD** — make Add/Edit/Remove/Change Photo actually work (dialogs +
   image picker), still on mock data
2. **Firebase wiring** — swap `OrderRepository`'s in-memory list for real
   Firestore reads/writes; add a simple admin login (Firebase Auth)
3. **Customer flow** — the QR-scan → menu → cart → UPI deep link screens
4. **UPI payment note to decide**: `upi://pay` opens the customer's banking
   app, but there's no automatic confirmation it succeeded without a paid
   gateway (Razorpay/Cashfree). Recommend treating UPI orders the same way
   cash ones are handled now — admin taps to confirm — unless you want to add
   a gateway later.
5. **QR generation** — a one-time screen/button that renders the printable QR
   pointing at the customer ordering link

Let me know which of these you want built next.
