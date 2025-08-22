CREATE TABLE IF NOT EXISTS game_results (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  category TEXT NOT NULL,
  team TEXT,
  key TEXT NOT NULL,
  guesses_count INTEGER DEFAULT 0,
  remaining INTEGER DEFAULT 501,
  status TEXT DEFAULT 'incomplete',
  score INTEGER DEFAULT 0,
  guesses_json TEXT DEFAULT '[]',
  inserted_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, date)
);
CREATE INDEX IF NOT EXISTS idx_game_results_user_date ON game_results(user_id, date);
