# Admin Dashboard — Vercel Deployment

Deploy the FlowDesk admin SPA to [Vercel](https://vercel.com). The API stays on **Railway**; this project is frontend-only.

---

## Quick deploy

1. **Import** the GitHub repository on Vercel.
2. **Root Directory:** `admin-web`
3. **Framework Preset:** Vite (auto-detected)
4. **Environment variable:**

   | Name | Example |
   |------|---------|
   | `VITE_API_BASE_URL` | `https://flowdesk-production-xxxx.up.railway.app/api/v1` |

   Must include the `/api/v1` prefix. Vite embeds this at **build time** — redeploy after changing it.

5. Deploy. Vercel runs `npm run build` and serves `dist/`.

`vercel.json` rewrites all routes to `index.html` for client-side routing.

---

## Build settings

| Setting | Value |
|---------|--------|
| Build command | `npm run build` |
| Output directory | `dist` |
| Install command | `npm install` |
| Node version | 20.x or 22.x (see Vite requirements) |

---

## Environment variables

### Local (`.env`)

```env
VITE_API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
```

Copy from `.env.example`. Do not commit `.env`.

### Vercel

**Project → Settings → Environment Variables**

- Add `VITE_API_BASE_URL` for **Production** (and **Preview** if you use preview deploys).
- Trigger a **redeploy** after any change.

---

## CORS (Railway API)

The admin app runs in the browser and calls the Railway API cross-origin.

**Option A — default (no config)**  
If `ALLOWED_ORIGINS` is unset on Railway, the API allows `*` origins (credentials off). Login and admin routes work without extra setup.

**Option B — production (recommended)**  
On the Railway API service:

```env
ALLOWED_ORIGINS=https://your-project.vercel.app,https://admin.yourdomain.com
```

Use your exact Vercel URL(s). Redeploy the API after updating.

If login fails with a CORS error in the browser console, check Railway logs for `OPTIONS` requests and verify `ALLOWED_ORIGINS`.

---

## Admin access

1. Seed an admin on Railway:

   ```bash
   python scripts/init_db.py --seed-admin \
     --email admin@yourcompany.com \
     --password 'YourSecurePass1' \
     --name 'Admin'
   ```

2. Open your Vercel URL and sign in with that account.
3. Non-admin users see: *"You are not an admin."*

---

## Verify deployment

- [ ] `/health` on Railway returns `ok`
- [ ] Admin login succeeds on the Vercel URL
- [ ] Users page loads and shows accounts
- [ ] Tasks page loads; status update works
- [ ] Browser tab shows FlowDesk favicon (hard-refresh if cached)
- [ ] Layout is full-width (no narrow centered column)

---

## Custom domain (optional)

1. Vercel → **Domains** → add your domain.
2. Add the custom domain to Railway `ALLOWED_ORIGINS`.
3. Redeploy API if using strict CORS.

---

## Troubleshooting

| Issue | What to check |
|-------|----------------|
| `Network Error` / failed fetch | `VITE_API_BASE_URL` correct; Railway API up; DNS from your network |
| CORS / preflight 405 | `ALLOWED_ORIGINS` includes Vercel URL; API redeployed |
| "You are not an admin" | User `role` is `admin` in database |
| Old Vite logo favicon | Hard refresh (`Ctrl+Shift+R`) or clear site data |
| Build fails on Node version | Use Node 20.19+ or 22.12+ in Vercel project settings |

---

## Related

- [admin-web README](./README.md)
- [Root deployment guide](../DEPLOYMENT.md)
