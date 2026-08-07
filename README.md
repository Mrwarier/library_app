# Library Management System

Flutter app backed by Firebase (Auth + Firestore). Any signed-in user
can browse the catalog, add/edit/delete books, and borrow/return —
there is no separate admin role and no cover images.

## ⚠️ Before you run this

This project was hand-written in a sandbox with no Flutter SDK and no
network access to fetch one, so **none of it has been run through
`flutter pub get`, `flutter analyze`, or `flutter build`.** Every file
is written to compile against current package APIs, but you are the
first to actually build it. Start with:

```bash
flutter pub get
flutter analyze
```

and fix anything that surfaces before running on a device/emulator.

## Setup

1. **Android is pre-configured** using the `google-services.json` you
   provided (project `librarymobileapp`, package `com.library.app`).
   It's already placed at `android/app/google-services.json`.

2. **iOS platform folder is not included, and Web is not configured.**
   Your `google-services.json` only contained an Android client, and
   the `ios/` folder's `.xcodeproj`/`.xcworkspace`/`Info.plist` files
   are generated XML that isn't safe to hand-write without the Flutter
   SDK to verify against — so rather than ship broken stubs, it's
   omitted. To add iOS support:
   ```bash
   flutter create --platforms=ios .
   flutterfire configure   # fills in iOS/web values in firebase_options.dart too
   ```
   run from this project's root once you have Flutter installed. For
   Web only (no iOS), `flutter create --platforms=web .` plus
   `flutterfire configure` is enough. `lib/firebase_options.dart`
   already has placeholder iOS/web values with `TODO` comments marking
   what `flutterfire configure` will overwrite.

3. **Enable Firebase products** in the console if you haven't:
   - Authentication → Sign-in method → Email/Password
   - Firestore Database → Create database

4. **Deploy the security rules** (`firestore.rules` at the project
   root):
   ```bash
   firebase deploy --only firestore:rules
   ```
   Without this, Firestore runs in whatever default mode your project
   was created with — likely locked down, which will make every
   read/write fail with a permission error.

## Project structure

```
lib/
  models/        Book, BorrowRecord — Firestore <-> Dart mapping
  services/      AuthService, BookService, BorrowService, Session
  screens/
    auth/        Login, signup
    catalog/     Catalog browsing, add/edit/delete, book detail + borrow,
                 loan history — all reachable by any signed-in user
  widgets/       Shared BookTile
  firebase_options.dart   Android filled in; iOS/web are placeholders (see above)
```

## Known gaps / things to check yourself

- **No integration tests run.** `test/widget_test.dart` is a single
  smoke test for the login screen; it hasn't been executed.
- **No admin/member distinction.** Any signed-in user can edit or
  delete any book. If you need that boundary back later, it would
  mean reintroducing a role field (e.g. on a `users` collection) and
  checking it in both the UI and `firestore.rules`.
- **Borrow logic uses Firestore transactions** to avoid two users
  grabbing the last copy simultaneously — reasoned through, not
  tested against a live project.
- **Overdue tracking is computed client-side** (`BorrowRecord.isOverdue`
  compares `dueAt` to `DateTime.now()`) — there's no scheduled Cloud
  Function marking records overdue server-side. Fine for a course
  project; worth adding for anything real.
- **Release Android builds sign with the debug key** (see
  `android/app/build.gradle.kts`) so `flutter build apk --release`
  works immediately. Replace with a real signing config before
  publishing anywhere.
- **Loan length is hardcoded to 14 days** (`BorrowService.loanDurationDays`).
