
# DV Photo App — Part 4 (Supabase + Admin + Payments stubs)

This drop adds:
- **Supabase SQL schema** (tables + relations) and **RLS policies**.
- **Flutter Supabase integration** (client init + order repository).
- **Replace Ethiopia local queue with Supabase-backed service** (toggle by flag).
- **Minimal Admin (Next.js)**: login, orders list, order detail placeholder.
- **Payments stubs**: Stripe (global), Telebirr (local) webhook contract.

> You can deploy Supabase with one click, run the SQL, set env vars, and the app will read/write real data.

---

## A) Supabase setup

1. Create a Supabase project.  
2. Open SQL editor and run files in this order:
   - `supabase/schema.sql`
   - `supabase/policies.sql`

3. Copy your keys to the Flutter app:
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY` (public) in Dart.
   - For the Admin web, also set `SERVICE_ROLE_KEY` **only on server**.

4. Enable **Storage** bucket `photos` (public uploads disabled). Use RLS from the SQL below.

---

## B) Flutter wiring

### pubspec.yaml (merge)
```yaml
dependencies:
  supabase_flutter: ^2.5.6
  uuid: ^4.4.0
  http: ^1.2.2
```

### Env (Dart)
Add these to your run config (`--dart-define`):
```
--dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co
--dart-define=SUPABASE_ANON_KEY=YOUR-ANON-KEY
```

### What’s new
- `lib/services/supabase_client.dart` – client init helper.
- `lib/features/ethiopia/supa_order_service.dart` – reads/writes `orders` table.
- `lib/config/app_config.dart` – add a flag `useSupabaseForQueue` (true by default).
- `lib/features/ethiopia/queue_screen.patch.txt` – minimal patch notes for switching list source.

---

## C) Admin (Next.js 14, minimal)

**Folder**: `admin/`  
- `npm i`  
- Set `.env.local` (see sample)  
- `npm run dev`

Features:
- Email magic-link sign in (Supabase Auth)
- Orders list (status, name, createdAt)
- Order detail placeholder (for notes, confirmation entry later)

---

## D) Payments stubs

- **Stripe**: client uses Payment Links or Checkout (simplest). Webhook path: `/api/stripe/webhook` updates `payments` row by `session_id`.
- **Telebirr**: set up a callback URL `/api/telebirr/webhook`. Expect JSON: `{order_id, amount, status, tx_ref}`.

> Both webhook handlers are included as Next.js API routes (skeletal logic).

---

## E) Rollout order

1) Deploy Supabase + run SQL.  
2) Put env vars into Flutter run config; run Ethiopia flavor and submit a test order.  
3) Run the admin app; confirm you can see the order.  
4) (Optional) Point domain + add Stripe payment link to the app; configure Telebirr callback.
