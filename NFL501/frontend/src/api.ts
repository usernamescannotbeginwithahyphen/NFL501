export type CategoryKey =
  | 'GAMES_PLAYED'
  | 'PASS_TDS'
  | 'RUSH_TDS'
  | 'RECEPTIONS'
  | 'RECEIVING_TDS'
  | 'RUSH_ATTEMPTS'
  | 'PASS_COMPLETIONS'
  | 'INTERCEPTIONS_THROWN'
  | 'SACKS'
  | 'INTERCEPTIONS'
  | 'FORCED_FUMBLES'
  | 'FUMBLE_RECOVERIES'
  | 'TACKLES_COMBINED'
  | 'TACKLES_SOLO'
  | 'PASSES_DEFENDED'
  | 'FGM'
  | 'XP_MADE'
  | 'PUNTS'
  | 'SINGLE_GAME_REC_YARDS'
  | 'SINGLE_GAME_RUSH_YARDS'
  | 'SINGLE_GAME_RECEPTIONS'
  | 'SINGLE_GAME_PASS_TDS'
  | 'SINGLE_GAME_PASS_COMPLETIONS'
  | 'WINS_VS_TEAM'

export type Entity = { id: string; label: string; value: number }

export let csrf: string | null = null

export async function bootAuth() {
  const m = await me()
  return m
}

export async function register(username: string, password: string) {
  const res = await fetch('/api/register', {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password })
  }); return res.json()
}

export async function login(username: string, password: string) {
  const res = await fetch('/api/login', {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password })
  }); return res.json()
}

export async function logout() {
  const res = await fetch('/api/logout', { method: 'POST' })
  return res.json()
}

export async function me() {
  const res = await fetch('/api/me')
  return res.json()
}

export async function fetchEntities(category: CategoryKey, team: string | null): Promise<Entity[]> {
  const url = `/api/entities?type=${category}&team=${encodeURIComponent(team ?? '')}`
  const r = await fetch(url)
  const j = await r.json()
  return j.data as Entity[]
}

export async function fetchDailyCategory() {
  const r = await fetch('/api/daily_category', { credentials: 'include' })
  return r.json()
}

export async function postProgress(type: CategoryKey, team_name: string | null, guesses_count: number, remaining: number, guesses: any[]) {
  const res = await fetch('/api/progress', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify({ type, team_name, guesses_count, remaining, guesses })
  })
  return res.json()
}

export async function submitResult(type: CategoryKey, team_name: string | null, guesses_count: number, remaining: number, exact: boolean, guesses: any[]) {
  const res = await fetch('/api/submit', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify({ type, team_name, guesses_count, remaining, exact, guesses })
  })
  return res.json()
}

export async function fetchHistory() {
  const res = await fetch('/api/history', { credentials: 'include' })
  return res.json()
}
