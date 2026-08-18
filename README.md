# Study Tracker

A single-page study tracker: a month calendar, a per-day timeline of study
slots, a focus timer per slot, and per-label totals. Runs as a static page on
Vercel with Supabase for storage. Free to host, built for one user.

```
Phone / Tablet  ──►  Vercel (static CDN)      the page itself
       │
       └──────────►  Supabase (Postgres+Auth) the data
```

There is no backend server. The browser talks to Supabase directly using the
public anon key, and Row-Level Security in the database enforces that a signed-in
user can only ever touch their own rows.

---

## Setup

Roughly 15 minutes, all free tier. Do the steps in order — Vercel needs values
that Supabase gives you.

### 1. Create the Supabase project

1. Sign up at <https://supabase.com> and create a new project.
2. Pick a region close to you (for India, Mumbai / `ap-south-1`).
3. Save the database password somewhere — you won't need it for this app, but
   losing it is annoying later.

### 2. Create the tables

In the Supabase dashboard: **SQL Editor → New query**. Paste the entire contents
of [`supabase/schema.sql`](supabase/schema.sql), then **Run**.

It's safe to run more than once.

### 3. Create the one user account

This app has no sign-up screen on purpose — that keeps strangers from creating
accounts on your project. Make the account by hand:

1. **Authentication → Users → Add user → Create new user**
2. Enter your brother's email and a password.
3. Tick **Auto Confirm User** so he doesn't need to click a confirmation email.

Then close the door behind you:

4. **Authentication → Sign In / Providers → Email**, turn **Allow new users to
   sign up** off.

### 4. Fill in `config.js`

In Supabase: **Project Settings → API**. Copy two values into `config.js`:

```js
window.APP_CONFIG = {
  SUPABASE_URL: 'https://abcdefgh.supabase.co',   // "Project URL"
  SUPABASE_ANON_KEY: 'eyJhbGciOi...',             // "anon" / "public" key
};
```

Both are safe to commit to a public repo. The anon key is designed to be
handed to browsers; on its own it grants access to nothing, because every
table is behind RLS.

> Do **not** put the `service_role` key anywhere in this project. That one
> bypasses RLS entirely.

### 5. Deploy to Vercel

Push this folder to a GitHub repo, then at <https://vercel.com>:

1. **Add New → Project**, import the repo.
2. Framework preset: **Other**. No build command, no output directory — it's a
   static folder.
3. Deploy.

Then add the same two Supabase values as environment variables, which the daily
keep-alive function needs: **Project Settings → Environment Variables**

| Name                 | Value                          |
| -------------------- | ------------------------------ |
| `SUPABASE_URL`       | your Project URL               |
| `SUPABASE_ANON_KEY`  | your anon key                  |

Redeploy once after adding them so the function picks them up.

### 6. Put it on his home screen

Open the Vercel URL on the phone and the tablet, sign in once on each, then:

- **iPhone/iPad (Safari):** Share → Add to Home Screen
- **Android (Chrome):** ⋮ → Add to Home screen

It then opens full-screen with its own icon, like a normal app.

---

## How syncing works

Understanding this matters, because it's what makes the data safe.

- **localStorage is the working copy.** Every edit saves to the device
  instantly. The app never blocks on the network and works fully offline.
- **Supabase is the durable, shared copy.** Edits are pushed 2 seconds after
  you stop making them, so a burst of taps is one write, not twenty.
- **Pulls happen** on open, whenever you return to the app, every 60 seconds
  while it's open, and when the network comes back.
- **Conflicts merge, they don't overwrite.** If the phone and the tablet both
  changed the same day while apart, the two slot lists are merged by slot:
  focus time takes the higher value, and the done/bled marks are kept if
  either device set them. A logged session cannot be destroyed by the other
  device coming online later.
- **A failed write is never a lost write.** The data is already on the device;
  the tracker shows `offline` and retries every 20 seconds.
- **Nothing is pushed before a successful pull.** A fresh or re-installed
  device can't blank out the server copy.

The little pill in the bottom-right corner shows the current state
(`synced` / `saving` / `offline`). Tap it to force a sync or sign out.

### Where your data lives

At any moment there are three copies: the phone, the tablet, and Postgres.
For a fourth, use the **Export** button — it downloads a JSON file that
**Import** can restore. Worth doing once a month; keep it in Drive.

---

## The free-tier catch, and what handles it

Supabase pauses free projects after **7 consecutive days with no activity**.
Paused is not deleted — the data is intact and you restore it with one click
in the dashboard — but the app would be stuck offline until someone does.

`api/keepalive.js` runs once a day via the cron in `vercel.json` and reads a
one-row `heartbeat` table, so activity never reaches zero even during a long
break after exams. You can check it yourself any time:

```
https://your-app.vercel.app/api/keepalive
```

A healthy response looks like `{"ok":true,"upstream":200,...}`. If it returns
`ok:false`, the schema wasn't applied or the environment variables are missing.

Other limits worth knowing: the free database is 500 MB, and this app writes
about 50 KB per year. Vercel's Hobby tier is for non-commercial use, which a
personal study tracker plainly is.

---

## Files

| Path                  | What it is                                              |
| --------------------- | ------------------------------------------------------- |
| `index.html`          | The whole app — markup, styles, logic, sync layer        |
| `config.js`           | Your two Supabase values                                 |
| `supabase/schema.sql` | Tables, RLS policies, keep-alive table. Run once.        |
| `api/keepalive.js`    | Daily ping so the free project never pauses              |
| `vercel.json`         | Cron schedule and cache headers                          |
| `manifest.json`       | Makes "Add to Home Screen" produce a real app            |
| `icon-*.png`          | App icons                                                |

## Running it locally

Any static file server works, e.g.:

```bash
npx serve .
```

Opening `index.html` as a `file://` URL mostly works but Supabase auth won't,
so use a server if you're testing sign-in.

## Troubleshooting

**Pill says "local only — not configured"** — `config.js` still has the
placeholder values.

**Pill says "offline" and never turns green** — check the browser console. The
usual causes are a wrong Project URL, or step 2 (the schema) never having been
run.

**"Invalid login credentials"** — the user wasn't created, or wasn't confirmed.
Recreate them in the dashboard with **Auto Confirm User** ticked.

**Data looks out of date on one device** — tap the sync pill, then "Sync now".
