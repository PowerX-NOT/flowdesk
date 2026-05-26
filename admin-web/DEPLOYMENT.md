# Admin Dashboard (Vercel)

This project is a simple admin web UI for FlowDesk.

## Environment variables

Vite reads environment variables at build time.

Create `admin-web/.env` (or set Vercel env vars) with:

- `VITE_API_BASE_URL`: your FastAPI base URL including the `/api/v1` prefix
  - Example: `https://YOUR_BACKEND_DOMAIN/api/v1`

Vercel:
- Add the same variable in **Project Settings → Environment Variables**.
- `VITE_API_BASE_URL` must be available during the build.

## Build / Deploy

- Build command: `npm run build`
- Output directory: `dist`

`vercel.json` is included to rewrite all paths to `index.html` (SPA-friendly).

## Admin access

The UI calls:
- `POST /auth/login`
- `GET /users/me`
- Admin endpoints:
  - `GET /tasks/admin`
  - `PUT /tasks/admin/:task_id`
  - `DELETE /tasks/admin/:task_id`
  - `GET /users/`
  - `DELETE /users/:user_id`

Only users with role `admin` can manage users/tasks.

