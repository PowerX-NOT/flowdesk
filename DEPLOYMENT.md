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
2. Open the MySQL service → **Variables** and note:
   - `MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE`
3. Build `DATABASE_URL` for the API service:

```text
mysql+pymysql://MYSQLUSER:MYSQLPASSWORD@MYSQLHOST:MYSQLPORT/MYSQLDATABASE
```

For **PlanetScale**, use the console connection string, set `DATABASE_SSL=true`, and ensure the URL uses `mysql+pymysql://`.

---

## 2. Railway — Backend API

1. **New** → **GitHub Repo** → select this repository.
2. Set **Root Directory** to `backend`.
3. **Link** the MySQL service to the API service (Railway → API service → Variables → **Add Reference**).

4. Add **Variables** (do **not** leave `DATABASE_URL` as `USER:PASSWORD@HOST:PORT`):

| Variable | Value |
|----------|--------|
| `JWT_SECRET_KEY` | `python -c "import secrets; print(secrets.token_hex(32))"` (≥32 chars) |
| `APP_ENV` | `production` |
| `TRUSTED_HOSTS` | `*` |
| `TRUST_PROXY_HEADERS` | `true` |
| `DATABASE_SSL` | `false` |

Optional: `DATABASE_URL` = `${{MySQL.DATABASE_URL}}` via Reference picker only — or omit it and let the app build the URL from `MYSQLHOST`, `MYSQLUSER`, etc.

Remove duplicate manual `MYSQL_*` copies if you use Reference linking (Railway injects `MYSQLHOST` automatically).

5. Deploy uses `backend/Dockerfile` or `railway.toml` → runs `alembic upgrade head` then Gunicorn.
6. Copy the public URL, e.g. `https://flowdesk-api-production.up.railway.app`.

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

See `backend/.env.example` for the full list (set in Railway Variables — not a local `.env` file).

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
