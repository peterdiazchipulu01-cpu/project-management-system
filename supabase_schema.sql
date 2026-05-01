-- Project Management System — Supabase Schema
-- Run this in your Supabase project: SQL Editor → New query → paste → Run

-- ─── Tables ───────────────────────────────────────────────────────────────────

create table if not exists users (
  id        bigserial primary key,
  name      text not null,
  email     text not null unique,
  created_at timestamptz default now()
);

create table if not exists projects (
  id          bigserial primary key,
  name        text not null,
  description text,
  start_date  date,
  end_date    date,
  created_at  timestamptz default now()
);

create table if not exists tasks (
  id          bigserial primary key,
  title       text not null,
  description text,
  status      text not null default 'todo'
                check (status in ('todo', 'in_progress', 'done')),
  priority    text not null default 'medium'
                check (priority in ('low', 'medium', 'high')),
  start_date  date,
  due_date    timestamptz,
  progress    integer not null default 0
                check (progress >= 0 and progress <= 100),
  project_id  bigint not null references projects (id) on delete cascade,
  assignee_id bigint references users (id) on delete set null,
  created_at  timestamptz default now()
);

-- ─── Row Level Security (open access — no auth required) ──────────────────────

alter table users    enable row level security;
alter table projects enable row level security;
alter table tasks    enable row level security;

create policy "Public full access" on users    for all to anon using (true) with check (true);
create policy "Public full access" on projects for all to anon using (true) with check (true);
create policy "Public full access" on tasks    for all to anon using (true) with check (true);

-- ─── Company Settings (single-row org config) ─────────────────────────────────

create table if not exists company_settings (
  id                   uuid primary key default gen_random_uuid(),
  organization_name    text not null default 'SafeOps PMS',
  default_resolution   text default '1080p x 720',
  enable_notifications boolean default true,
  updated_at           timestamptz default now()
);

alter table company_settings enable row level security;

create policy "Public full access" on company_settings for all to anon using (true) with check (true);

-- Default org row (single-tenant)
insert into company_settings (id, organization_name, default_resolution, enable_notifications)
values ('00000000-0000-0000-0000-000000000001', 'SafeOps Project Management', '1080p x 720', true)
on conflict (id) do nothing;
