# Yes Native — Backend Server

Node.js + Express + MongoDB backend for the Yes Native vendor and customer apps.

## Architecture

```
┌─────────────────────┐     ┌─────────────────────┐
│  Flutter Vendor App  │     │  Flutter Customer App│
│  (Firebase Auth)     │     │  (Firebase Auth)     │
└────────┬────────────┘     └────────┬────────────┘
         │                           │
         │     HTTPS / REST API      │
         └──────────┬────────────────┘
                    │
         ┌──────────▼──────────┐
         │  Backend (Express)  │
         │  Verifies Firebase  │
         │  ID tokens          │
         └──────────┬──────────┘
                    │
         ┌──────────▼──────────┐
         │  MongoDB (Atlas)    │
         │  Users, Products,   │
         │  Orders, Offers     │
         └─────────────────────┘
```

## Setup

### Prerequisites

- [Node.js](https://nodejs.org/) v18+
- [MongoDB Atlas](https://www.mongodb.com/atlas) cluster (or local MongoDB)
- [Firebase](https://console.firebase.google.com/) project with Google Sign-In enabled

### 1. Clone & Install

```bash
cd backend
npm install
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` with your values:

| Variable                      | Description                                       |
|-------------------------------|---------------------------------------------------|
| `PORT`                        | Server port (default: 3000)                       |
| `MONGODB_URI`                 | MongoDB Atlas connection string                   |
| `FIREBASE_SERVICE_ACCOUNT_PATH` | Path to Firebase Admin SDK service account JSON |
| `CORS_ORIGINS`                | Allowed origins (comma-separated)                 |

### 3. Firebase Admin SDK

1. Go to **Firebase Console → Project Settings → Service Accounts**
2. Click **Generate new private key**
3. Save the JSON file as `config/firebase-service-account.json`
4. Make sure `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env` points to it

### 4. Start the Server

```bash
npm run dev     # Development (with auto-restart)
npm start       # Production
```

The server will start at `http://localhost:3000`.

## API Endpoints

All data endpoints require a `Authorization: Bearer <Firebase ID Token>` header.

### Auth

| Method | Endpoint           | Description                                      |
|--------|--------------------|--------------------------------------------------|
| POST   | `/api/auth/login`  | Verify Firebase token, create/get user in MongoDB |

### Users

| Method | Endpoint           | Description                    |
|--------|--------------------|--------------------------------|
| GET    | `/api/users/me`    | Get current user's profile     |
| PUT    | `/api/users/me`    | Update profile fields          |

### Products

| Method | Endpoint              | Description         |
|--------|-----------------------|---------------------|
| GET    | `/api/products`       | List all products   |
| POST   | `/api/products`       | Create a product    |
| PUT    | `/api/products/:id`   | Update a product    |
| DELETE | `/api/products/:id`   | Delete a product    |

### Orders

| Method | Endpoint                    | Description                |
|--------|-----------------------------|----------------------------|
| GET    | `/api/orders`               | List all orders            |
| GET    | `/api/orders/status/:status`| Filter orders by status    |
| PUT    | `/api/orders/:id`           | Update order status        |

### Offers

| Method | Endpoint              | Description       |
|--------|-----------------------|-------------------|
| GET    | `/api/offers`         | List all offers   |
| POST   | `/api/offers`         | Create an offer   |
| PUT    | `/api/offers/:id`     | Update an offer   |
| DELETE | `/api/offers/:id`     | Delete an offer   |

## Data Model

The `User` schema includes a `role` field (`"vendor"` or `"customer"`).

- **Vendor app** sets `role: "vendor"` on login
- **Customer app** sets `role: "customer"` on login

This allows both apps to share the same Firebase Auth project and MongoDB
collection, while keeping data separate by role.
