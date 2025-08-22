import React, { useEffect, useMemo, useState } from 'react'
import { bootAuth, fetchEntities, type CategoryKey, type Entity, login, logout, me, register, fetchDailyCategory, postProgress, submitResult, fetchHistory } from './api'

const categoryMeta: Record<CategoryKey, { label: string; placeholder: string; noun: 'players'|'teams', needsTeam: boolean }> = {
  GAMES_PLAYED: { label: '# of Games Played', placeholder: 'Type a player...', noun: 'players', needsTeam: false },
  PASS_TDS: { label: 'Passing TDs', placeholder: 'Type a QB...', noun: 'players', needsTeam: false },
  RUSH_TDS: { label: 'Rushing TDs', placeholder: 'Type a RB...', noun: 'players', needsTeam: false },
  RECEPTIONS: { label: 'Receptions', placeholder: 'Type a receiver...', noun: 'players', needsTeam: false },
  RECEIVING_TDS: { label: 'Receiving TDs', placeholder: 'Type a receiver...', noun: 'players', needsTeam: false },
  RUSH_ATTEMPTS: { label: 'Rushing Attempts', placeholder: 'Type a RB...', noun: 'players', needsTeam: false },
  PASS_COMPLETIONS: { label: 'Pass Completions', placeholder: 'Type a QB...', noun: 'players', needsTeam: false },
  INTERCEPTIONS_THROWN: { label: 'Interceptions Thrown', placeholder: 'Type a QB...', noun: 'players', needsTeam: false },
  SACKS: { label: 'Sacks (defense)', placeholder: 'Type a defender...', noun: 'players', needsTeam: false },
  INTERCEPTIONS: { label: 'Interceptions (defense)', placeholder: 'Type a defender...', noun: 'players', needsTeam: false },
  FORCED_FUMBLES: { label: 'Forced Fumbles', placeholder: 'Type a defender...', noun: 'players', needsTeam: false },
  FUMBLE_RECOVERIES: { label: 'Fumble Recoveries', placeholder: 'Type a defender...', noun: 'players', needsTeam: false },
  TACKLES_COMBINED: { label: 'Tackles (combined)', placeholder: 'Type a defender...', noun: 'players', needsTeam: false },
  TACKLES_SOLO: { label: 'Tackles (solo)', placeholder: 'Type a defender...', noun: 'players', needsTeam: false },
  PASSES_DEFENDED: { label: 'Passes Defended', placeholder: 'Type a DB...', noun: 'players', needsTeam: false },
  FGM: { label: 'Field Goals Made', placeholder: 'Type a kicker...', noun: 'players', needsTeam: false },
  XP_MADE: { label: 'Extra Points Made', placeholder: 'Type a kicker...', noun: 'players', needsTeam: false },
  PUNTS: { label: 'Punts', placeholder: 'Type a punter...', noun: 'players', needsTeam: false },
  SINGLE_GAME_REC_YARDS: { label: 'Highest single-game receiving yards', placeholder: 'Type a receiver...', noun: 'players', needsTeam: false },
  SINGLE_GAME_RUSH_YARDS: { label: 'Highest single-game rushing yards', placeholder: 'Type a RB...', noun: 'players', needsTeam: false },
  SINGLE_GAME_RECEPTIONS: { label: 'Highest single-game receptions', placeholder: 'Type a player...', noun: 'players', needsTeam: false },
  SINGLE_GAME_PASS_TDS: { label: 'Highest single-game passing TDs', placeholder: 'Type a QB...', noun: 'players', needsTeam: false },
  SINGLE_GAME_PASS_COMPLETIONS: { label: 'Highest single-game pass comps', placeholder: 'Type a QB...', noun: 'players', needsTeam: false },
  WINS_VS_TEAM: { label: '# of Wins Against [TEAM]', placeholder: 'Type a team...', noun: 'teams', needsTeam: true },
}

export default function App() {
  const [who, setWho] = useState<{id:number,username:string}|null>(null)
  const [daily, setDaily] = useState<{date:string,type:CategoryKey,team_abbr:string|null,team_name:string|null,key:string}|null>(null)
  const [entities, setEntities] = useState<Entity[]>([])
  const [team, setTeam] = useState('Chicago Bears')
  const [category, setCategory] = useState<CategoryKey>('GAMES_PLAYED')
  const [input, setInput] = useState('')
  const [remaining, setRemaining] = useState(501)
  const [guesses, setGuesses] = useState<{label:string,value:number,valid:boolean}[]>([])
  const won = remaining === 0
  const [gameOver, setGameOver] = useState<null | { exact: boolean; guesses: number; remaining: number; score: number }>(null)

  useEffect(() => { (async () => {
    const m = await me()
    if (m.user) setWho(m.user)
    const d = await fetchDailyCategory()
    if (d.ok) {
      const t = d.team_name as string | null
      setDaily(d)
      setCategory(d.type)
      setTeam(t ?? '—')
      const ents = await fetchEntities(d.type, t)
      setEntities(ents)
    }
  })() }, [])

  useEffect(() => {
    if (won && !gameOver) {
      (async () => {
        const guessesCount = guesses.filter(g=>g.valid).length
        const res = await submitResult(category, categoryMeta[category].needsTeam ? team : null, guessesCount, 0, true, guesses)
        if (res.ok !== false) setGameOver({ exact: true, guesses: guessesCount, remaining: 0, score: guessesCount })
      })()
    }
  }, [won])

  async function makeGuess(name: string) {
    const e = entities.find(x => x.label.toLowerCase() === name.toLowerCase())
    let val = e ? e.value : 0
    let valid = true
    if (!e) valid = false
    if (e && val > remaining) valid = false
    const guess = { label: name, value: val, valid }
    const nextRem = valid ? remaining - val : remaining
    setGuesses(g => [guess, ...g].sort((a,b)=>b.value-a.value))
    setRemaining(nextRem)
    await postProgress(category, categoryMeta[category].needsTeam ? team : null, guesses.filter(g=>g.valid).length + (valid?1:0), nextRem, [guess, ...guesses])
  }

  return (
    <div className="p-4 text-slate-100">
      <div className="text-xs opacity-70">{daily ? daily.date : ''}</div>
      <h1 className="text-2xl font-bold">NFL 501</h1>
      <div className="mt-2 text-slate-300">{categoryMeta[category].label.replace('[TEAM]', categoryMeta[category].needsTeam ? (team||'—') : '—')}</div>
      <div className="mt-1 text-slate-400">Target: <b>{remaining}</b>/501</div>

      <div className="mt-4 flex gap-2">
        <input className="bg-slate-800 rounded px-3 py-2" placeholder={categoryMeta[category].placeholder} value={input} onChange={e=>setInput(e.target.value)} onKeyDown={e=>{if(e.key==='Enter'){makeGuess(input); setInput('')}}} />
        <button onClick={()=>{makeGuess(input); setInput('')}} className="bg-indigo-500 rounded px-3 py-2">Guess</button>
        <button onClick={async ()=>{ const guessesCount = guesses.filter(g=>g.valid).length; const res = await submitResult(category, categoryMeta[category].needsTeam ? team : null, guessesCount, remaining, false, guesses); if (res.ok !== false) setGameOver({ exact:false, guesses: guessesCount, remaining, score: guessesCount + remaining }); }} className="rounded px-3 py-2 bg-rose-500">Give Up</button>
      </div>

      <div className="mt-4 grid gap-2">
        {guesses.map((g,i)=> (
          <div key={i} className={'rounded px-3 py-2 ' + (g.valid ? 'bg-emerald-950/40 border border-emerald-500/30' : 'bg-rose-950/30 border border-rose-500/30')}>
            <div className="font-semibold">{g.label}</div>
            <div className="text-sm opacity-70">{g.value}</div>
          </div>
        ))}
      </div>

      {won && (
        <div className="mt-4 rounded bg-emerald-900/20 p-3 border border-emerald-500/30">
          🎯 501 exactly — score = guesses
        </div>
      )}

      {gameOver && (
        <div className="mt-4 rounded bg-indigo-900/20 p-3 border border-indigo-500/30">
          <div className="font-semibold">{gameOver.exact ? '🎯 Exact 501!' : '📘 Score locked'}</div>
          <div className="text-sm">Guesses: <b>{gameOver.guesses}</b> • Remaining: <b>{gameOver.remaining}</b> • Score: <b>{gameOver.score}</b></div>
        </div>
      )}
    </div>
  )
}

export {}
