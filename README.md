# MarupX - Smart Digital Marup Management Platform

MarupX is a premium fintech application for automated community savings and lottery-based member payouts.

## 🚀 Getting Started

### 1. Firebase Setup
1. Create a new Firebase Project at [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** (Google Sign-In).
3. Enable **Cloud Firestore**.
4. Enable **Cloud Functions** (Requires Blaze plan).
5. Enable **Firebase Storage**.

### 2. Configuration
1. **Android**: Download `google-services.json` and place it in `android/app/`.
2. **iOS**: Download `GoogleService-Info.plist` and place it in `ios/Runner/`.
3. **Web**: Add your Firebase config to `web/index.html`.

### 3. Deploy Backend
```bash
cd firebase
firebase deploy --only functions,firestore:rules
```

### 4. Run the App
```bash
flutter pub get
flutter run
```

## 🏗️ Architecture
- **State Management**: GetX
- **Database**: Cloud Firestore
- **Authentication**: Firebase Google Sign-In
- **Backend**: Firebase Cloud Functions (Secure Lottery Draw)
- **UI/UX**: Fintech-grade with Emerald Green theme and animations.

## 🛡️ Security
- **Role-Based Access Control**: Defined in `firestore.rules`.
- **Fairness**: Lottery logic runs exclusively on the server (Cloud Functions) to prevent frontend manipulation.
- **Audit Trail**: Every wallet transaction is logged immutably.

## 📱 Platforms Supported
- Android
- iOS
- Windows
- Web (Responsive Admin Panel)
