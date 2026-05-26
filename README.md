# FlowDesk — Employee Task Management System

> **Flutter + FastAPI + MySQL** full-stack task management app for employees.

---

## 📱 Flutter App (FlowDesk)

### Screens
| Screen | Description |
|--------|-------------|
| Login | Email/password with JWT auth |
| Register | Name, email, password with strength validation |
| Dashboard | Tasks list with search, filter, pull-to-refresh |
| Add/Edit Task | Title, description, priority selector, date picker, status |
| Task Detail | Full view with quick status update, edit, delete |

### Architecture
```
lib/
├── core/           # Theme, constants, router, errors, utils
├── domain/         # Entities, repository interfaces, use cases
├── data/           # Models, datasources, repository implementations
└── presentation/   # Screens, widgets, Riverpod providers
```

### Setup (production / real devices)
```bash
cd flutter_app
flutter pub get
flutter run --dart-define=API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
```

See **[DEPLOYMENT.md](DEPLOYMENT.md)** for Railway, MySQL, and release APK commands.

---

## 🐍 Backend (FastAPI + MySQL)

### API Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/auth/register` | No | Register new user |
| POST | `/api/v1/auth/login` | No | Login, returns JWT |
| GET | `/api/v1/users/me` | Yes | Current user profile |
| GET | `/api/v1/tasks/` | Yes | List tasks (search, filter) |
| POST | `/api/v1/tasks/` | Yes | Create task |
| GET | `/api/v1/tasks/{id}` | Yes | Get single task |
| PUT | `/api/v1/tasks/{id}` | Yes | Update task |
| DELETE | `/api/v1/tasks/{id}` | Yes | Delete task |

### Setup
```bash
# 1. Create MySQL database
mysql -u root -p -e "CREATE DATABASE employee_tasks; CREATE USER 'taskuser'@'localhost' IDENTIFIED BY 'yourpassword'; GRANT ALL ON employee_tasks.* TO 'taskuser'@'localhost';"

# 2. Setup Python env
cd backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# 3. Configure environment
cp .env.example .env
# Edit .env — set DATABASE_URL and generate JWT_SECRET_KEY:
python -c "import secrets; print(secrets.token_hex(32))"

# 4. Run migrations and server
alembic upgrade head
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Production deploy: Railway — see **[DEPLOYMENT.md](DEPLOYMENT.md)**.

---

## 🔐 Security Highlights
- JWT HS256 (no `none` algorithm, `exp` always validated)
- bcrypt password hashing with unique salts
- Ownership enforced server-side on every task request
- Rate limiting on all endpoints (slowapi)
- Strict CORS — no wildcard `*`
- Security headers: CSP, X-Frame-Options, X-Content-Type-Options
- Tokens stored in Keychain/Keystore via `flutter_secure_storage`
- No secrets in source code — env-var driven

---

## 📝 Git History
Meaningful atomic commits — one per feature/layer. See `git log --oneline`.
