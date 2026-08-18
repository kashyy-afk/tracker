// Daily keep-alive ping.
//
// Supabase pauses free-tier projects after ~7 consecutive days with no
// activity. A paused project isn't lost — you restore it from the dashboard —
// but the app would be down until someone does. This runs once a day (see the
// cron entry in vercel.json) so activity never reaches zero, even if he stops
// tracking for a few weeks after exams.
//
// It reads the single-row `heartbeat` table, which exists purely so this ping
// performs a real, successful database read. It cannot read study_days: RLS
// refuses the anon role there, and a rejected request is not a dependable
// activity signal. Only the public anon key is needed, so there is no secret
// in this function.

export default async function handler(req, res) {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY;

  if (!url || !key) {
    return res.status(500).json({
      ok: false,
      error: 'SUPABASE_URL / SUPABASE_ANON_KEY are not set in the Vercel project environment variables.',
    });
  }

  try {
    const r = await fetch(`${url}/rest/v1/heartbeat?select=id&limit=1`, {
      headers: { apikey: key, Authorization: `Bearer ${key}` },
    });
    const body = await r.text();
    // a non-200 here means the schema was never applied, so surface it loudly
    // rather than letting the project quietly drift toward being paused
    return res.status(r.ok ? 200 : 502).json({
      ok: r.ok, upstream: r.status, body: body.slice(0, 200), at: new Date().toISOString(),
    });
  } catch (e) {
    return res.status(502).json({ ok: false, error: String(e) });
  }
}
