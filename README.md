# FlowDesk — Employee Task Management System

> **Flutter mobile app** + **React admin dashboard** + **FastAPI** + **MySQL** — production deployment on Railway (API) and Vercel (admin).

---

## Project structure

| Path | Stack | Purpose |
|------|--------|---------|
| [`flutter_app/`](flutter_app/) | Flutter, Riverpod, GoRouter | Employee mobile app (tasks, auth, profile) |
| [`admin-web/`](admin-web/) | React, TypeScript, Vite | Desktop-oriented admin console (users & tasks) |
| [`backend/`](backend/) | FastAPI, SQLAlchemy, Alembic | REST API + JWT auth |

---

## 📱 Flutter app (employees)

| Screen | Description |
|--------|-------------|
| Login / Register | Email/password with JWT auth |
| Dashboard | Tasks list with search, filter, pull-to-refresh |
| Add / Edit task | Title, description, priority, due date, status |
| Task detail | View, quick status update, edit, delete |
| Profile | Name, email, role, logout |

```bash
cd flutter_app
cp .env.example .env
# API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
flutter pub get
flutter run
# Release: flutter build apk --release
```

See [`flutter_app/README.md`](flutter_app/README.md) for more detail.

---

## 🖥️ Admin web (admins)

Browser dashboard for **`admin`** role users only.

| Area | Features |
|------|----------|
| Users | List, search, view role/status, delete |
| Tasks | List, search, filter by status, update status, delete |
| Auth | JWT login; session restored from local storage |

```bash
cd admin-web
cp .env.example .env
# VITE_API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
npm install
npm run dev
```

Deploy to **Vercel**: see [`admin-web/DEPLOYMENT.md`](admin-web/DEPLOYMENT.md).

---

## 🐍 Backend API

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/auth/register` | No | Register (default role: `employee`) |
| POST | `/api/v1/auth/login` | No | Login (JWT + refresh) |
| POST | `/api/v1/auth/refresh` | No | Refresh access token |
| GET | `/api/v1/users/me` | Yes | Current user |
| GET/POST | `/api/v1/tasks/` | Yes | List / create own tasks |
| GET/PUT/DELETE | `/api/v1/tasks/{id}` | Yes | Task CRUD (owner) |
| GET | `/api/v1/tasks/admin` | Admin | List all tasks |
| PUT | `/api/v1/tasks/admin/{id}` | Admin | Update any task |
| DELETE | `/api/v1/tasks/admin/{id}` | Admin | Delete any task |
| GET | `/api/v1/users/` | Admin | List all users |
| DELETE | `/api/v1/users/{id}` | Admin | Delete user |
| GET | `/health` | No | Health + DB status |

Hosted on **Railway** (FastAPI + Gunicorn + MySQL). Full setup: **[DEPLOYMENT.md](DEPLOYMENT.md)**.

**Railway variables:** paste from `backend/.env.example` — use `${{MySQL.MYSQL_URL}}` for `DATABASE_URL`.

**Admin user:** seed via Railway shell (`python scripts/init_db.py --seed-admin`) or promote a user to `admin` in the database. New registrations are `employee` by default.

---

## 🔐 Security

- JWT HS256, refresh tokens, bcrypt passwords
- Task ownership enforced server-side; admin routes require `admin` role
- Rate limiting, CORS, HSTS, security headers
- Flutter: tokens in `flutter_secure_storage`
- Admin web: tokens in `localStorage` (admin-only deployment)

---

## 📚 Documentation

- [Production deployment (Railway + Flutter)](DEPLOYMENT.md)
- [Admin web — local dev & Vercel](admin-web/DEPLOYMENT.md)
- [Admin web — project overview](admin-web/README.md)
- [Flutter app](flutter_app/README.md)
