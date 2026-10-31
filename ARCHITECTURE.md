# System Architecture

This document describes the high-level software architecture and interaction models of GameHaven.

## 🏗️ Overview

GameHaven is built using a decoupled Client-Server architecture:
- **Client (Frontend)**: Flutter application running on Web and Mobile platforms.
- **Server (Backend)**: Express.js REST API with Prisma ORM and MySQL database.
- **Cloud Storage**: Cloudinary for user profile pictures and media assets.

```
┌─────────────────────────────────┐
│     Flutter Client (GameHaven)  │
│  (Mobile, Tablet, Desktop Web)  │
└────────────────┬────────────────┘
                 │ HTTP / REST (JWT Bearer)
                 ▼
┌─────────────────────────────────┐
│       Express.js Backend        │
│  Auth, Users, & Games Endpoints │
└────────┬───────────────┬────────┘
         │               │
         ▼               ▼
┌─────────────────┐ ┌─────────────┐
│ MySQL / Prisma  │ │ Cloudinary  │
│  Data Storage   │ │ Image CDN   │
└─────────────────┘ └─────────────┘
```

## 🔐 Authentication & Session Flow

1. **Sign Up / Sign In**:
   - Client sends credentials via `POST /api/auth/register` or `POST /api/auth/login`.
   - Backend signs and returns a JSON Web Token (JWT).
2. **Local Persistence**:
   - JWT and basic user role info are stored in `SharedPreferences`.
3. **Authorized Requests**:
   - `Apiservice` appends the `Authorization: Bearer <token>` header to all outgoing requests.
   - 401 Unauthorized responses trigger session clearance and redirect to the login screen.

## 🛡️ Role-Based Access Control (RBAC)

- **Admin Role**:
  - Full CRUD on `/api/games`.
  - Access to list all users (`GET /api/users`) and delete users (`DELETE /api/users/:id`).
- **User Role**:
  - Read access to games (`GET /api/games`).
  - Read & update personal profile (`GET /api/profile`, `PUT /api/profile/upload-photo`).
