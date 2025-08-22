CREATE TABLE IF NOT EXISTS daily_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  category TEXT NOT NULL,
  team_abbr TEXT,
  key TEXT NOT NULL,
  UNIQUE(date)
);
