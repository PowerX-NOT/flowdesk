# FlowDesk Admin

Desktop-oriented admin console for **FlowDesk**. Built with **React**, **TypeScript**, and **Vite**.

Only users with role **`admin`** can sign in. Employees registered via the mobile app cannot access this UI.

---

## Features

- **Login** — JWT auth against the FastAPI backend
- **Users** — stats overview, search, list all accounts, delete users
- **Tasks** — stats overview, search, status filters, update status, delete tasks
- **UI** — dark theme, full-width layout, FlowDesk gradient app icon

---

## Prerequisites

- Node.js 20.19+ (or 22.12+) recommended for Vite 8
- Running FlowDesk API (local or Railway)
- An **admin** account on the API

---

## Local development

```bash
cd admin-web
cp .env.example .env
```

Edit `.env`:

```env
VITE_API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
```

```bash
npm install
npm run dev
```

Open the URL shown in the terminal (default `http://localhost:5173`).

### Create an admin user

On Railway (API service shell):

```bash
python scripts/init_db.py --seed-admin \
  --email admin@yourcompany.com \
  --password 'YourSecurePass1' \
  --name 'Admin'
```

Or set `role = 'admin'` for an existing user in MySQL.

---

## Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Dev server with HMR |
| `npm run build` | Production build → `dist/` |
| `npm run preview` | Preview production build locally |

---

## Project layout

```
admin-web/
├── public/
│   └── favicon.svg          # FlowDesk app icon
├── src/
│   ├── components/
│   │   ├── AdminShell.tsx   # Sidebar + top bar
│   │   ├── FlowDeskLogo.tsx # Brand mark (SVG)
│   │   └── Icons.tsx        # Nav/action icons
│   ├── pages/
│   │   ├── LoginPage.tsx
│   │   ├── UsersPage.tsx
│   │   └── TasksPage.tsx
│   ├── lib/
│   │   ├── api.ts           # API client + auth
│   │   ├── env.ts
│   │   └── types.ts
│   └── styles/
│       └── admin.css
├── vercel.json              # SPA rewrites
└── DEPLOYMENT.md            # Vercel deploy guide
```

---

## API endpoints used

| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/login` | Login |
| GET | `/users/me` | Current user (must be `admin`) |
| GET | `/users/` | List users |
| DELETE | `/users/{id}` | Delete user |
| GET | `/tasks/admin` | List all tasks (`?search=&status=`) |
| PUT | `/tasks/admin/{id}` | Update task (e.g. status) |
| DELETE | `/tasks/admin/{id}` | Delete task |

Paths are relative to `VITE_API_BASE_URL` (already includes `/api/v1`).

---

## Deploy

See **[DEPLOYMENT.md](./DEPLOYMENT.md)** for Vercel setup, env vars, and CORS notes.

---

## Related docs

- [Root README](../README.md)
- [Production deployment (Railway + Flutter)](../DEPLOYMENT.md)
