# Kanglei Marup - Community Savings Platform

A complete production-ready realtime online Manipuri Marup draw platform. Built with Flutter, Firebase, and GetX.

## 🎯 App Concept
A community-based digital Marup (ROSCA - Rotating Savings and Credit Association) system where members join groups, contribute money on a scheduled basis, and a real-time automatic draw selects a winner using a two-pot system (Name Pot + Gem Pot).

**Important:** This is positioned strictly as a Community Savings & Digital Marup Platform, not gambling.

## 🛠 Tech Stack
- **Frontend:** Flutter (GetX for State Management, GoRouter/GetRoutes for navigation)
- **Backend:** Firebase (Auth, Firestore, Cloud Functions, Storage, Messaging)
- **UI/UX:** Dark Fintech Theme, Glassmorphism, Gold/Emerald Accents
- **Animations:** Rive, Lottie, Flutter Animate

## 📂 Architecture Overview

```text
lib/
├── core/            # App core settings (constants, initial bindings, theme)
├── models/          # Data models
├── controllers/     # GetX Controllers (Business Logic)
├── views/           # UI Screens (Auth, Home, Draw, Admin, Profile)
├── widgets/         # Reusable UI components
├── services/        # External APIs, Firebase interactions
└── routes/          # Navigation and route guarding
```

## 🔥 Firebase Structure & Schema

### `users` (Collection)
- `uid` (String)
- `name` (String)
- `phone` (String)
- `photoUrl` (String)
- `kycStatus` (Enum: pending, verified, rejected)
- `role` (Enum: member, admin)
- `createdAt` (Timestamp)
- `fcmToken` (String)

### `groups` (Collection)
- `groupId` (String)
- `name` (String)
- `description` (String)
- `contributionAmount` (Double)
- `totalMembers` (Int)
- `frequency` (Enum: weekly, monthly)
- `status` (Enum: active, completed)
- `createdAt` (Timestamp)
- `nextDrawAt` (Timestamp)

### `group_members` (Sub-collection under groups)
- `uid` (String)
- `joinedAt` (Timestamp)
- `status` (Enum: active, suspended)
- `totalContributed` (Double)
- `hasWon` (Boolean)

### `draws` (Collection)
- `drawId` (String)
- `groupId` (String)
- `scheduledAt` (Timestamp)
- `status` (Enum: scheduled, starting, pot_shaking, selecting_name, selecting_gem, winner_reveal, completed)
- `winnerId` (String, nullable)
- `poolAmount` (Double)
- `serverTime` (Timestamp)

### `wallets` (Collection)
- `uid` (String)
- `balance` (Double)
- `updatedAt` (Timestamp)

### `transactions` (Collection)
- `txId` (String)
- `uid` (String)
- `amount` (Double)
- `type` (Enum: contribution, win, deposit, withdrawal)
- `status` (Enum: pending, success, failed)
- `timestamp` (Timestamp)

## 🎲 Live Draw Real-Time Synchronization

The draw relies entirely on **Firestore Document Listeners** and **Cloud Functions**. 
No local device has the authority to select the winner.

### Sync Flow
1. **Cloud Scheduler (GCP)** triggers a Cloud Function 1 minute before the `nextDrawAt`.
2. Cloud Function updates the `draw` document `status` sequentially:
   - `scheduled` -> `starting` (0s)
   - `starting` -> `pot_shaking` (+5s)
   - `pot_shaking` -> `selecting_name` (+10s)
   - `selecting_name` -> `selecting_gem` (+15s)
   - `selecting_gem` -> `winner_reveal` (+20s) - **Function randomly selects a winner from eligible members here**.
   - `winner_reveal` -> `completed` (+30s)
3. Clients listen to this specific `draw` document.
4. When `status` changes, GetX controller triggers the corresponding animation (Flutter Animate/Lottie) locally.

This guarantees absolute synchronization and zero cheating.
