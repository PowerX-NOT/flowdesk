# FlowDesk — Production Deployment Guide

Deploy the **FastAPI backend** to [Railway](https://railway.app), **MySQL** on Railway (or PlanetScale), and ship the **Flutter app** as a release APK/App Bundle for real Android/iOS devices over HTTPS.

---

## Architecture

```
[Android / iOS app]  --HTTPS-->  [Railway: FastAPI + Gunicorn/Uvicorn]
                                        |
                                        v
                               [Railway MySQL or PlanetScale]
```

- API base path: `https://<your-domain>/api/v1`
- Health check: `GET https://<your-domain>/health`
- HTTPS only — no local or emulator API URLs

---

## 1. Railway — MySQL database

1. Create a Railway project → **New** → **Database** → **MySQL**.
2. MySQL service → **Variables** — Railway provides (among others):
   - `MYSQL_URL`, `MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE`
3. Do **not** copy these into the API service manually — reference them from the API (step 2).

---

## 2. Railway — Backend API

1. **New** → **GitHub Repo** → select this repository.
2. Set **Root Directory** to `backend`.
3. Open the **API** service → **Variables** → **RAW Editor**.
4. Paste the block below. For `DATABASE_URL`, use the **Reference** picker: **MySQL** → `MYSQL_URL` (shows as `${{MySQL.MYSQL_URL}}`).
5. Replace `your-secret-at-least-32-characters-long` with your JWT secret:

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

Quotes are optional in Railway; unquoted values work the same.

**Do not add** placeholder `USER:PASSWORD@HOST`, duplicate `MYSQLHOST` copies, or `MYSQL_PUBLIC_URL` on the API service.

6. Deploy uses `backend/Dockerfile` → `alembic upgrade head` then Gunicorn.
7. Copy the public URL, e.g. `https://flowdesk-api-production.up.railway.app`.

### Verify backend

```bash
curl -s https://YOUR_RAILWAY_URL/health
# {"status":"ok","database":"connected","environment":"production"}
```

### Seed admin (one-time, Railway service shell)

Open the API service → **Shell**, then:

```bash
python scripts/init_db.py --seed-admin \
  --email admin@yourcompany.com \
  --password 'YourSecurePass1' \
  --name 'Admin'
```

---

## 3. Flutter — production build

Set your Railway HTTPS URL in `.env` (include `/api/v1`):

```bash
cd flutter_app
cp .env.example .env
# Edit .env:
#   API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
flutter pub get

flutter build apk --release
flutter build appbundle --release   # Play Store
flutter build ios --release         # macOS + Xcode
```

APK output: `flutter_app/build/app/outputs/flutter-apk/app-release.apk`

### Release signing (Android)

Create `android/key.properties` and configure signing in `android/app/build.gradle.kts` before Play Store upload. Debug signing is fine for internal testing only.

### App icon / splash

```bash
dart pub add dev:flutter_launcher_icons dev:flutter_native_splash
# Configure pubspec, add assets/images/icon.png, then:
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## 4. Environment variables reference

| Variable | Purpose |
|----------|---------|
| `DATABASE_URL` | `${{MySQL.MYSQL_URL}}` — internal MySQL connection (auto `mysql+pymysql://`) |
| `JWT_SECRET_KEY` | Signs access/refresh tokens (≥32 characters) |
| `APP_ENV` | Must be `production` |
| `TRUSTED_HOSTS` | `*` — allows Railway healthchecks |
| `DATABASE_SSL` | `false` for Railway MySQL |

Full copy-paste block: `backend/.env.example` (for Railway only — not a local `.env` file).

---

## 5. Production checklist

- [ ] `JWT_SECRET_KEY` set (≥32 chars), never committed
- [ ] `APP_ENV=production` on Railway
- [ ] `/health` returns `database: connected`
- [ ] Alembic migrations applied (`alembic upgrade head` on deploy)
- [ ] `flutter_app/.env` has `API_BASE_URL=https://...` (from `.env.example`)
- [ ] Register/login on a **physical device** on cellular Wi‑Fi
- [ ] Create, edit, delete tasks end-to-end
- [ ] Token persists after app restart; expired JWT triggers re-login or refresh

---

## 6. Security notes

- HTTPS only for API URL in release builds
- JWT access + refresh tokens; refresh stored in `flutter_secure_storage`
- bcrypt passwords, strict CORS allow-list, HSTS in production
- Rate limiting via slowapi (100 req/min default)
