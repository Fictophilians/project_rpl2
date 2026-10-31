# 🎮 GameHaven - Game Catalog & Vault

> Folder tugas dan latihan flutter - GameHaven Flutter Application

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**GameHaven** is a modern, responsive game catalog application built with Flutter Web & Mobile. It allows users to explore game collections, view ratings, manage personal profiles with Cloudinary-backed avatar uploads, and provides role-based access control (Admin vs User) for complete game catalog management.

---

## ✨ Features

- **🔐 Authentication & Authorization**
  - User registration with role selection (`User` / `Admin`).
  - Secure JWT-based login with persistent local storage.
  - Route guard (`AuthGate`) to seamlessly restore sessions.

- **🎯 Game Catalog Management (CRUD)**
  - Real-time catalog listing with ratings (`0.0 - 10.0`).
  - Dynamic instant search by game title or developer name.
  - Role-based capabilities:
    - **Admin**: Full access to Add, Edit, and Delete games.
    - **User**: Read-only browsing and discovery experience.

- **👤 User Management & Profile**
  - Admin dashboard displaying all registered users with role badges and account deletion capability.
  - User profile dashboard displaying account ID, email, role, and avatar.
  - Profile avatar upload to **Cloudinary** via backend multipart HTTP endpoint.

- **🖥️ Responsive Layout**
  - **Mobile (< 600px)**: Compact single-column card layout.
  - **Tablet (600px - 950px)**: 2-column responsive grid.
  - **Desktop (≥ 950px)**: 3-column gaming vault grid with centered desktop dock navigation.

---

## 🛠️ Tech Stack

- **Frontend**: Flutter 3 (Dart 3.x)
- **UI Components & Icons**:
  - `google_fonts` (Comic Relief)
  - `salomon_bottom_bar`
  - `image_picker` & `http_parser`
- **State & Networking**:
  - `http` client with Bearer Token interceptor
  - `shared_preferences` for session persistence
- **Backend API**: Node.js, Express, TypeScript, Prisma/MySQL, Cloudinary, Multer

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19+ recommended)
- [Node.js](https://nodejs.org/) (for running the backend service)
- Chrome / Edge (for Web development) or Android Emulator

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Fictophilians/project_rpl2.git
   cd project_rpl2
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoint:**
   Verify `lib/service/api.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:3000/api';
   ```

4. **Run the Application:**
   ```bash
   # Run on Chrome
   flutter run -d chrome

   # Run on connected mobile device/emulator
   flutter run
   ```

---

## 📂 Project Structure

```
lib/
├── main.dart             # App entrypoint, themes, and AuthGate
├── pages/
│   ├── StarterPage.dart  # Onboarding screen
│   ├── LoginPage.dart    # User sign-in
│   ├── Register.dart     # User registration with role picker
│   ├── MenuPage.dart     # Main hub (Games, Users, Profile tabs)
│   ├── AddGamePage.dart  # Game creation form
│   └── EditGamePage.dart # Game modification form
└── service/
    └── api.dart          # HTTP API client, token handling, and upload logic
```

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.
