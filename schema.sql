-- LUMA Wedding Invitations — Cloudflare D1 (SQLite) Schema
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS invitations (
  id TEXT PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  template_id TEXT NOT NULL,
  opening_style TEXT NOT NULL DEFAULT 'couple',
  animation_preset TEXT NOT NULL DEFAULT 'envelope',
  animation_speed TEXT NOT NULL DEFAULT 'measured',
  background_style TEXT NOT NULL DEFAULT 'linen',
  background_image TEXT NOT NULL DEFAULT '',
  scrim_opacity REAL NOT NULL DEFAULT 0.72,
  english_font TEXT NOT NULL DEFAULT 'Cormorant Garamond',
  arabic_font TEXT NOT NULL DEFAULT 'Amiri',
  palette_json TEXT NOT NULL,
  copy_json TEXT NOT NULL,
  schedule_json TEXT NOT NULL,
  event_date TEXT NOT NULL,
  event_time TEXT NOT NULL,
  rsvp_deadline TEXT NOT NULL,
  google_maps_url TEXT NOT NULL,
  published INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_invitations_slug ON invitations(slug);

CREATE TABLE IF NOT EXISTS guests (
  id TEXT PRIMARY KEY,
  invitation_id TEXT NOT NULL,
  guest_token TEXT NOT NULL,
  name_en TEXT NOT NULL,
  name_ar TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL DEFAULT '',
  phone TEXT NOT NULL DEFAULT '',
  group_name TEXT NOT NULL DEFAULT 'General',
  table_label TEXT NOT NULL DEFAULT '',
  party_limit INTEGER NOT NULL DEFAULT 2,
  attending_count INTEGER NOT NULL DEFAULT 0,
  rsvp_status TEXT NOT NULL DEFAULT 'pending' CHECK (rsvp_status IN ('confirmed', 'pending', 'declined')),
  dietary_notes TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (invitation_id) REFERENCES invitations(id) ON DELETE CASCADE,
  UNIQUE(invitation_id, guest_token)
);

CREATE TABLE IF NOT EXISTS guestbook_entries (
  id TEXT PRIMARY KEY,
  invitation_id TEXT NOT NULL,
  author_name TEXT NOT NULL,
  relationship_en TEXT NOT NULL DEFAULT '',
  relationship_ar TEXT NOT NULL DEFAULT '',
  message TEXT NOT NULL,
  language TEXT NOT NULL DEFAULT 'en' CHECK (language IN ('en', 'ar')),
  approved INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (invitation_id) REFERENCES invitations(id) ON DELETE CASCADE
);