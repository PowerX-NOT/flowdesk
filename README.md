# FlowDesk — Employee Task Management System

> **Flutter + FastAPI + MySQL** — online-only deployment for real mobile devices.

---

## 📱 Flutter App

| Screen | Description |
|--------|-------------|
| Login | Email/password with JWT auth |
| Register | Name, email, password with strength validation |
| Dashboard | Tasks list with search, filter, pull-to-refresh |
| Add/Edit Task | Title, description, priority, date picker, status |
| Task Detail | View, quick status update, edit, delete |

### Release build

```bash
cd flutter_app
flutter pub get
flutter build apk --release \
  --dart-define=API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
```

---

## 🐍 Backend API

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/auth/register` | No | Register |
| POST | `/api/v1/auth/login` | No | Login (JWT + refresh) |
| POST | `/api/v1/auth/refresh` | No | Refresh access token |
| GET | `/api/v1/users/me` | Yes | Current user |
| GET/POST | `/api/v1/tasks/` | Yes | List / create tasks |
| GET/PUT/DELETE | `/api/v1/tasks/{id}` | Yes | Task CRUD |
| GET | `/health` | No | Health + DB status |

Hosted on **Railway** (FastAPI + Gunicorn + MySQL). See **[DEPLOYMENT.md](DEPLOYMENT.md)** for setup.

Environment variable reference: `backend/.env.example` (Railway Variables tab only — no local `.env`).

---

## 🔐 Security

- JWT HS256, refresh tokens, bcrypt passwords
- Task ownership enforced server-side
- Rate limiting, strict CORS, HSTS, security headers
- Tokens in `flutter_secure_storage` (Keychain / Keystore)

---

## 📝 Git

Atomic conventional commits. After clone: `sh scripts/setup-git-hooks.sh`
