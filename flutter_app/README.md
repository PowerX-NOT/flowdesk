# FlowDesk — Flutter App

Mobile client for **FlowDesk** employees: authenticate, manage personal tasks, and view profile.

**Stack:** Flutter · Riverpod · GoRouter · Dio · `flutter_secure_storage`

---

## Screens

| Route | Screen |
|-------|--------|
| `/` | Splash → auth redirect |
| `/login` | Email / password login |
| `/register` | New employee account |
| `/dashboard` | Task list, search, filters |
| `/tasks/new` | Create task |
| `/tasks/:id` | Task detail |
| `/tasks/:id/edit` | Edit task |
| `/profile` | User info & logout |

New registrations receive role **`employee`**. Admin access is via the [admin web](../admin-web/) dashboard only.

---

## Setup

```bash
cd flutter_app
cp .env.example .env
```

Edit `.env`:

```env
API_BASE_URL=https://YOUR_RAILWAY_URL/api/v1
```

```bash
flutter pub get
flutter run
```

Use a **physical device** or emulator with network access to your API. For production, point `API_BASE_URL` at your Railway HTTPS URL.

---

## Release build

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

flutter build appbundle --release   # Google Play
```

Configure Android release signing before Play Store upload. See the [root deployment guide](../DEPLOYMENT.md).

---

## Environment

| Variable | Description |
|----------|-------------|
| `API_BASE_URL` | Backend base URL **including** `/api/v1` |

Loaded from `.env` via `flutter_dotenv` (bundled as a Flutter asset).

---

## Theming

Dark Material 3 theme aligned with FlowDesk brand colors (`lib/core/theme/app_theme.dart`):

- Primary: `#5C6BC0`
- Secondary: `#26C6DA`
- Surface: `#12131A`

---

## Related docs

- [Root README](../README.md)
- [Production deployment](../DEPLOYMENT.md)
- [Admin web](../admin-web/README.md)
