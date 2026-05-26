# FlowDesk — Production Deployment Guide

Deploy the **FastAPI backend** to [Railway](https://railway.app), **MySQL** on Railway, the **Flutter app** as a release APK/App Bundle, and the **admin dashboard** to [Vercel](https://vercel.com).

---

## Architecture

```
[Flutter app]  ──HTTPS──►  [Railway: FastAPI + Gunicorn]
[Admin web]    ──HTTPS──►         │
   (Vercel)                       ▼
                          [Railway MySQL]
```

- API base path: `https://<your-railway-domain>/api/v1`
- Health check: `GET https://<your-railway-domain>/health`
- Admin UI: `https://<your-vercel-domain>` (static SPA)
- HTTPS only in production — no emulator/local API URLs in release builds

---

## 1. Railway — MySQL database

1. Create a Railway project → **New** → **Database** → **MySQL**.
2. MySQL service → **Variables** — Railway provides `MYSQL_URL`, `MYSQLHOST`, etc.
3. Reference these from the API service (step 2); do not copy credentials manually.

---

## 2. Railway — Backend API

1. **New** → **GitHub Repo** → select this repository.
2. Set **Root Directory** to `backend`.
3. API service → **Variables** → **RAW Editor**.
4. Paste from `backend/.env.example`. For `DATABASE_URL`, use **Reference**: **MySQL** → `MYSQL_URL` (`${{MySQL.MYSQL_URL}}`).
5. Generate JWT secret:

```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

### API service variables (copy-paste)

```env
DATABASE_URL=${{MySQL.MYSQL_URL}}
JWT_SECRET_KEY=your-secret-at-least-32-characters-long
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
DATABASE_SSL=false
DB_POOL_SIZE=5
DB_MAX_OVERFLOW=10
DB_POOL_TIMEOUT=30
DB_POOL_RECYCLE=1800
APP_ENV=production
LOG_LEVEL=INFO
TRUST_PROXY_HEADERS=true
TRUSTED_HOSTS=*
```

**Optional — restrict CORS** (recommended when admin is on Vercel):

```env
ALLOWED_ORIGINS=https://your-admin.vercel.app,https://your-admin-custom-domain.com
```

If `ALLOWED_ORIGINS` is empty, the API falls back to `allow_origins=["*"]` with credentials disabled so browser clients (including the admin SPA) still work.

6. Deploy uses `backend/Dockerfile` → `alembic upgrade head` then Gunicorn.
7. Note the public URL, e.g. `https://flowdesk-production-xxxx.up.railway.app`.

### Verify backend

```bash
curl -s https://YOUR_RAILWAY_URL/health
# {"status":"ok","database":"connected","environment":"production"}
```

### Seed admin (one-time, Railway service shell)

```bash
python scripts/init_db.py --seed-admin \
  --email admin@yourcompany.com \
  --password 'YourSecurePass1' \
  --name 'Admin'
```

---

## 3. Vercel — Admin web

1. Import the repo on [Vercel](https://vercel.com).
2. Set **Root Directory** to `admin-web`.
3. **Environment variable** (Production + Preview):

   | Name | Value |
   |------|--------|
   | `VITE_API_BASE_URL` | `https://YOUR_RAILWAY_URL/api/v1` |

4. Build: `npm run build` · Output: `dist` (configured in `vercel.json`).
5. After deploy, add the Vercel URL to Railway `ALLOWED_ORIGINS` if you use a strict CORS list.

Details: **[admin-web/DEPLOYMENT.md](admin-web/DEPLOYMENT.md)**.

---

## 4. Flutter — production build

```bash
cd flutter_app
cp .env.example .env
# API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
flutter pub get
flutter build apk --release
flutter build appbundle --release   # Play Store
```

APK: `flutter_app/build/app/outputs/flutter-apk/app-release.apk`

### Release signing (Android)

Configure `android/key.properties` and signing in `android/app/build.gradle.kts` before Play Store upload.

---

## 5. Environment variables reference

| Variable | Service | Purpose |
|----------|---------|---------|
| `DATABASE_URL` | Railway API | `${{MySQL.MYSQL_URL}}` |
| `JWT_SECRET_KEY` | Railway API | Signs tokens (≥32 chars) |
| `APP_ENV` | Railway API | `production` |
| `ALLOWED_ORIGINS` | Railway API | Comma-separated admin (and other) web origins |
| `TRUSTED_HOSTS` | Railway API | `*` for Railway healthchecks |
| `VITE_API_BASE_URL` | Vercel | Railway API URL including `/api/v1` |
| `API_BASE_URL` | Flutter `.env` | Same API URL for mobile app |

---

## 6. Production checklist

- [ ] `JWT_SECRET_KEY` set (≥32 chars), never committed
- [ ] `APP_ENV=production` on Railway
- [ ] `/health` returns `database: connected`
- [ ] Alembic migrations applied on deploy
- [ ] Admin user seeded or promoted in DB
- [ ] `VITE_API_BASE_URL` set on Vercel; admin login works
- [ ] `flutter_app/.env` has production `API_BASE_URL`
- [ ] Register/login on a **physical device**
- [ ] Create, edit, delete tasks from Flutter
- [ ] Admin web: list users/tasks, update task status, logout

---

## 7. Security notes

- HTTPS only for API URLs in production
- JWT access + refresh; Flutter uses `flutter_secure_storage`
- bcrypt passwords, CORS, HSTS in production
- Rate limiting via slowapi
- Admin web stores tokens in `localStorage` — deploy only over HTTPS; restrict to trusted admins
