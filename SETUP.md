# Setup guide — from fork to working app

This walks you through every step, assuming you have never used GitHub,
Vercel, or Supabase before. You do not need to install anything, and you
never have to touch a command line. Everything happens in your browser.

**Time:** about 20 minutes.
**Cost:** nothing. All three services have free plans that comfortably cover
this app, and none of them ask for a card.

You will create three free accounts:

| Service      | What it does here                                  |
| ------------ | -------------------------------------------------- |
| **GitHub**   | Stores the code                                     |
| **Supabase** | Stores your study data (the database)               |
| **Vercel**   | Puts the app on the internet at a real web address  |

> **Tip:** open each service in its own browser tab and keep them all open.
> You will jump between them, and you'll need to copy values from Supabase
> into the other two.

---

## Part 1 — Get your own copy of the code (GitHub)

### 1.1 Create a GitHub account

Go to <https://github.com/signup> and sign up. Verify your email when asked.

If you already have an account, just sign in.

### 1.2 Fork the project

"Forking" means making your own copy of someone else's code. Your copy is
completely independent — you can change it, and nothing you do affects the
original.

1. Open the project page on GitHub.
2. Click the **Fork** button in the top-right.
3. Leave the settings as they are and click **Create fork**.

After a few seconds you land on *your* copy. Check the address bar — it
should now say `github.com/YOUR-USERNAME/...` instead of the original owner's
name.

> ✅ **Checkpoint:** the page title shows your own username, and underneath it
> says "forked from ...".

**Keep this tab open.** You'll come back to it in Part 3.

---

## Part 2 — Set up the database (Supabase)

This is the longest part. Take it slowly; the rest is quick.

### 2.1 Create a Supabase account and project

1. Go to <https://supabase.com> and click **Start your project**.
2. Sign in with GitHub (easiest — click **Continue with GitHub** and approve).
3. Click **New project**.
4. Fill in:
   - **Name:** `study-tracker` (anything you like)
   - **Database Password:** click **Generate a password**, then copy it
     somewhere safe. *This app never uses it, but you'll want it if you ever
     poke at the database directly.*
   - **Region:** pick the one closest to you. In India, choose
     **South Asia (Mumbai)**. A closer region means a faster app.
5. Click **Create new project**.

Setting up takes **1–3 minutes**. Wait for the spinner to finish before
continuing.

> ✅ **Checkpoint:** you see a project dashboard, not a "setting up" spinner.

### 2.2 Create the tables

The database starts completely empty. This step creates the two tables the app
needs.

**First, copy the code you need to paste:**

1. Go back to your GitHub tab (your fork).
2. Click the **`supabase`** folder, then click **`schema.sql`**.
3. Click the **copy icon** at the top-right of the file (its tooltip says
   "Copy raw file"). The whole file is now on your clipboard.

**Now run it:**

4. Back in Supabase, click **SQL Editor** in the left sidebar.
5. Click **New query**.
6. Click into the big empty box and paste (`Ctrl+V`, or `Cmd+V` on a Mac).
7. Click **Run** (bottom-right, or press `Ctrl+Enter`).

> ✅ **Checkpoint:** you see **"Success. No rows returned"** in green at the
> bottom. That green message is what success looks like — it does *not* mean
> nothing happened.
>
> To be sure: click **Table Editor** in the left sidebar. You should see two
> tables, **`study_days`** and **`heartbeat`**.

If you get a red error instead, you probably pasted only part of the file.
Clear the box and repeat from step 2.

### 2.3 Create the login account

The app has no "Sign up" screen, deliberately — that stops strangers from
making accounts on your database. So you create the one account by hand.

1. Click **Authentication** in the left sidebar.
2. Click **Users**, then the **Add user** button → **Create new user**.
3. Enter the email and password your brother will use to sign in.
   - Use a real email he knows, and a password he can remember.
   - This is *not* his email account password — you are inventing a new one
     just for this app.
4. **Tick the "Auto Confirm User" box.** This matters. Without it he'll be
   locked out waiting for a confirmation email that may never arrive.
5. Click **Create user**.

> ✅ **Checkpoint:** the user appears in the list, and the **Last Sign In**
> column is empty (he hasn't signed in yet — that's expected).

**Write the email and password down.** You'll type them into the app at the
very end.

### 2.4 Close the door behind you

Stop anyone else from creating accounts on your project:

1. Still under **Authentication**, click **Sign In / Providers**.
2. Click **Email**.
3. Turn **Allow new users to sign up** *off*.
4. Click **Save**.

### 2.5 Copy your two connection values

1. Click **Project Settings** (the gear icon, bottom-left).
2. Click **API keys** — or **API** on older dashboards.
3. You need two values. Copy each with the copy button beside it and paste
   them into a scratch note for a moment:

   | What to look for | Looks like |
   | ---------------- | ---------- |
   | **Project URL** | `https://abcdefghijkl.supabase.co` |
   | **anon** / **public** / **publishable** key | a very long string starting `eyJ...` or `sb_publishable_...` |

> ⚠️ There is also a key labelled **service_role** or **secret**. **Never copy
> that one into this app.** It bypasses all the security rules. The `anon`
> key is the safe one — it is *designed* to be visible in a web page, and on
> its own it grants access to nothing.

---

## Part 3 — Put your keys into the code (GitHub)

You can edit files directly on the GitHub website. No downloads needed.

1. Go back to your GitHub fork tab.
2. Click on **`config.js`** in the file list.
3. Click the **pencil icon** (top-right) to edit.
4. You'll see this:

   ```js
   window.APP_CONFIG = {
     SUPABASE_URL: 'YOUR-PROJECT-URL',
     SUPABASE_ANON_KEY: 'YOUR-ANON-KEY',
   };
   ```

5. Replace the two placeholders with the values you copied in step 2.5.
   **Keep the quote marks** around each value. The result should look like:

   ```js
   window.APP_CONFIG = {
     SUPABASE_URL: 'https://abcdefghijkl.supabase.co',
     SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
   };
   ```

6. Click **Commit changes...** (green button, top-right), then **Commit
   changes** again in the popup.

> ✅ **Checkpoint:** open `config.js` again. Your real values are there, and
> the word `YOUR-` appears nowhere.

Common mistakes: deleting a quote mark or the comma at the end of a line, or
pasting the URL with a `/` on the end. Remove any trailing slash.

---

## Part 4 — Put it on the internet (Vercel)

### 4.1 Create a Vercel account

1. Go to <https://vercel.com/signup>.
2. Choose **Hobby** (the free plan) when asked.
3. Click **Continue with GitHub** and approve the permissions.

### 4.2 Import your fork

1. On your Vercel dashboard, click **Add New...** → **Project**.
2. You'll see a list of your GitHub repositories. Find your fork and click
   **Import**.
   - Don't see it? Click **Adjust GitHub App Permissions** and give Vercel
     access to the repository, then come back.
3. On the configuration screen, **change nothing**. In particular:
   - **Framework Preset** should say **Other**
   - Build and Output settings stay empty — this app needs no build step
4. Click **Deploy**.

Wait about a minute. You'll get a congratulations screen with a preview
image.

> ✅ **Checkpoint:** you have a live address like
> `https://kashyaptracker.vercel.app`. Click it — the app should load and
> show a **sign-in screen**.
>
> If it instead shows a small grey pill saying **"local only — not
> configured"**, your `config.js` edit didn't save. Go back to Part 3.

### 4.3 Add the two environment variables

These are for the daily job that keeps your free database from going to sleep.
The app itself already works without them, but skip this and the app will
break after a week of not using it.

1. In your Vercel project, click the **Settings** tab.
2. Click **Environment Variables** in the sidebar.
3. Add the first one:
   - **Key:** `SUPABASE_URL`
   - **Value:** your Project URL (the same one from step 2.5)
   - Click **Save**.
4. Add the second one:
   - **Key:** `SUPABASE_ANON_KEY`
   - **Value:** your anon key
   - Click **Save**.

### 4.4 Redeploy so the variables take effect

Environment variables only apply to *new* deployments.

1. Click the **Deployments** tab.
2. On the top entry in the list, click the **⋯** menu on the right →
   **Redeploy** → **Redeploy**.

Wait for it to finish.

> ✅ **Checkpoint:** visit `https://YOUR-APP.vercel.app/api/keepalive` in
> your browser. You should see:
>
> ```json
> {"ok":true,"upstream":200,...}
> ```
>
> If it says `"ok":false`, either the variables have a typo, or the SQL in
> step 2.2 never ran.

---

## Part 5 — Sign in and check it works

1. Open your Vercel address.
2. Enter the email and password you created in step 2.3, and tap **Sign in**.
3. The calendar appears. Tap any day, then **Add slot**.
4. Look at the small pill in the bottom-right corner. It should flash
   **saving**, then settle on a green **synced**.

> ✅ **The real test:** open the same address on a *different* device, or in a
> private/incognito window. Sign in with the same details. The slot you just
> added should be there. That means your data is safely in the database and
> not just sitting in one browser.

---

## Part 6 — Put it on the phone and tablet

Do this on each device so it opens like a normal app, full-screen with its own
icon, instead of a browser tab.

**iPhone / iPad — must be Safari:**
1. Open your Vercel address in **Safari** (Chrome on iOS can't do this).
2. Tap the **Share** button (a square with an arrow, at the bottom).
3. Scroll down and tap **Add to Home Screen**.
4. Tap **Add**.

**Android — Chrome:**
1. Open your address in Chrome.
2. Tap the **⋮** menu (top-right).
3. Tap **Add to Home screen** → **Install**.

Then sign in once inside the newly installed app on each device. It stays
signed in after that.

---

## Part 7 — Using it day to day

**The sync pill** (bottom-right corner) tells you what's happening:

| Shows | Meaning |
| ----- | ------- |
| green **synced** | Everything is saved to the database. |
| yellow **saving** | Writing right now. Takes about a second. |
| red **offline** | No connection. **Your work is still saved on the device** and uploads automatically when you're back online. |

Tap the pill for **Sync now** and **Sign out**.

**Marking slots:** tap the circle once to mark a session complete; tap it
twice quickly to mark it bled. These are independent — a slot can be both.

**Backups.** Your data already exists in three places: the phone, the tablet,
and the database. For a fourth, tap **Export** once a month — it downloads a
file you can keep in Google Drive, and **Import** restores it.

---

## Troubleshooting

| Problem | Fix |
| ------- | --- |
| Pill says **"local only — not configured"** | `config.js` still has the placeholder text. Redo Part 3. |
| Pill stuck on **offline** | Usually a wrong Project URL (check for a trailing `/`) or the SQL never ran. Redo step 2.2. |
| **"Invalid login credentials"** | The user doesn't exist, or "Auto Confirm User" wasn't ticked. Delete the user in Supabase and redo step 2.3. |
| **"Email logins are disabled"** | You turned off the email provider itself, not just sign-ups. Re-enable **Email** under Authentication → Sign In / Providers, and turn off only *"Allow new users to sign up"*. |
| App works, but the other device is out of date | Tap the pill → **Sync now**. |
| Everything broke after weeks away | Your free Supabase project paused. Open the Supabase dashboard and click **Restore project**. No data is lost. Then check `/api/keepalive` returns `ok:true` so it doesn't happen again. |
| Changed `config.js` but nothing changed | Vercel redeploys automatically, but it takes a minute. Check the **Deployments** tab, then hard-refresh the page (`Ctrl+Shift+R`). |

### Getting a completely clean start

If you want to wipe everything and begin again: in Supabase go to
**Table Editor → `study_days` → ⋯ → Delete table**, then re-run the SQL from
step 2.2. This erases all study data permanently, so export first.

---

## What this costs you long-term

Nothing, with one thing to know: **Supabase pauses free projects after 7 days
of no activity.** Paused is not deleted — your data stays intact and one click
restores it — but the app would be offline until you do.

The daily job you set up in Part 4.3 prevents this by pinging the database
once a day, even during a long break after exams. That's the only reason those
environment variables exist.

For scale: the free database holds 500 MB, and this app writes roughly 50 KB
per year.
