-- Study tracker schema.
-- Run this once in the Supabase dashboard: SQL Editor -> New query -> paste -> Run.
-- Safe to re-run: every statement is guarded.

create table if not exists public.study_days (
  user_id    uuid        not null references auth.users(id) on delete cascade,
  day        date        not null,
  slots      jsonb       not null default '[]'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, day)
);

-- The primary key (user_id, day) already indexes the RLS predicate, because
-- user_id is its leading column. No additional index is needed on this table.

alter table public.study_days enable row level security;

-- One policy covering select/insert/update/delete. auth.uid() is wrapped in a
-- subquery so Postgres evaluates it once per statement instead of once per row.
drop policy if exists study_days_owner on public.study_days;
create policy study_days_owner on public.study_days
  for all
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- Keep updated_at honest even if a client forgets to send it.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists study_days_touch on public.study_days;
create trigger study_days_touch
  before insert or update on public.study_days
  for each row execute function public.touch_updated_at();

-- The anon role must never touch this table; only signed-in users, filtered by RLS.
revoke all on public.study_days from anon;
grant select, insert, update, delete on public.study_days to authenticated;

-- ---------------------------------------------------------------------------
-- Keep-alive target.
--
-- The daily cron in vercel.json needs a request that genuinely reads the
-- database, so the free-tier inactivity timer never reaches 7 days. It can't
-- use study_days: RLS correctly refuses the anon role there, and a rejected
-- request is not a reliable activity signal. This single-row table holds no
-- personal data and is safe to expose read-only.
-- ---------------------------------------------------------------------------

create table if not exists public.heartbeat (
  id        smallint primary key,
  pinged_at timestamptz not null default now(),
  constraint heartbeat_single_row check (id = 1)
);

insert into public.heartbeat (id) values (1) on conflict (id) do nothing;

alter table public.heartbeat enable row level security;

drop policy if exists heartbeat_read on public.heartbeat;
create policy heartbeat_read on public.heartbeat
  for select
  to anon, authenticated
  using (true);

grant select on public.heartbeat to anon, authenticated;
