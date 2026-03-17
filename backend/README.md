# GreenGuard Backend (Node.js, Express, MongoDB)

REST API backend for the GreenGuard plantation monitoring system.

## Tech stack

- Node.js + Express
- MongoDB + Mongoose
- JWT authentication
- Multer for image uploads

## Project structure

- `server.js` – app entry point
- `config/db.js` – MongoDB connection
- `models/` – Mongoose models (`User`, `Plant`)
- `controllers/` – request handlers (`authController`, `plantController`)
- `routes/` – Express routers (`authRoutes`, `plantRoutes`)
- `middleware/` – auth, error, and upload middleware

## Setup

1. Install dependencies:

   ```bash
   cd backend
   npm install
   ```

2. Configure environment variables:

   ```bash
   cp .env.example .env
   ```

   Then edit `.env` and set:

   - `MONGO_URI` – your MongoDB connection string
   - `JWT_SECRET` – strong random string
   - `PORT` – (optional) server port, default `5000`

3. Start the server:

   ```bash
   npm start
   ```

   For development with auto‑reload:

   ```bash
   npm run dev
   ```

## REST API

### Auth

- `POST /api/auth/register` – register a new user
- `POST /api/auth/login` – log in and obtain a JWT token

### Plants

All plant routes require a `Bearer <token>` Authorization header.

- `POST /api/plants` – create a plant
  - Body fields: `plantName`, `latitude`, `longitude`, optional `status`, `lastUpdated`
  - Optional file field: `photo` (multipart/form-data)
- `GET /api/plants` – list plants
- `PUT /api/plants/:id` – update existing plant (supports `photo` upload)
- `DELETE /api/plants/:id` – delete plant

Uploaded images are stored under `backend/uploads` and served at `/uploads/...`.

