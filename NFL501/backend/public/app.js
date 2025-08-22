async function j(method, path, body) {
  const res = await fetch(path, {
    method, headers: { 'Content-Type': 'application/json' }, credentials: 'include',
    body: body ? JSON.stringify(body) : undefined
  })
  return await res.json()
}
function qs(s){return document.querySelector(s)}
function el(t,c){const e=document.createElement(t); if(c) e.className=c; return e}
let ENTITIES = []

async function refreshMe(){
  const me = await fetch('/api/me', {credentials:'include'}).then(r=>r.json())
  const who = qs('#whoami'), logout = qs('#logout'), game = qs('#game')
  if (me.user) {
    who.textContent = 'signed in as ' + me.user.username
    logout.classList.remove('hidden')
    qs('#signup').classList.add('hidden'); qs('#login').classList.add('hidden')
    qs('#username').classList.add('hidden'); qs('#password').classList.add('hidden')
    game.classList.remove('hidden')
    await loadDaily()
  } else {
    who.textContent = ''
    logout.classList.add('hidden')
    qs('#signup').classList.remove('hidden'); qs('#login').classList.remove('hidden')
    qs('#username').classList.remove('hidden'); qs('#password').classList.remove('hidden')
    game.classList.add('hidden')
  }
}
async function loadDaily(){
  const d = await fetch('/api/daily_category',{credentials:'include'}).then(r=>r.json())
  if (!d.ok) return
  qs('#date').textContent = d.date
  const label = (d.type === 'WINS_VS_TEAM') ? ('# of Wins Against ' + d.team_name) : d.type.replaceAll('_',' ')
  qs('#label').textContent = label
  // get full entity list for client-side suggestions
  const ents = await fetch(`/api/entities?type=${d.type}&team=${encodeURIComponent(d.team_name || '')}`, {credentials:'include'}).then(r=>r.json())
  ENTITIES = ents.data || []
  qs('#answer').disabled = false
  qs('#guessBtn').disabled = false
  qs('#giveUpBtn').disabled = false
  // reset state
  REM = 501; GUESSES = []; render()
}
let REM = 501
let GUESSES = []

function render(){
  qs('#remaining').textContent = REM
  const list = qs('#guesses'); list.innerHTML = ''
  GUESSES.sort((a,b)=>b.value-a.value).forEach(g=>{
    const row = el('div', 'guess ' + (g.valid?'valid':'invalid'))
    row.innerHTML = `<div>${g.label}</div><div>${g.value}</div>`
    list.appendChild(row)
  })
}

async function makeGuess(name){
  name = name.trim(); if (!name) return
  const canon = s=>s.toLowerCase().replace(/[^a-z0-9\.\-\s']/g,'').trim()
  const found = ENTITIES.find(e => canon(e.label) === canon(name))
  let value = found ? found.value : 0
  let valid = true
  if (!found) valid = false
  if (found && value > REM) valid = false
  const guess = { label: name, value, valid }
  GUESSES.unshift(guess)
  if (valid) REM -= value
  render()
  // persist progress
  const d = await fetch('/api/daily_category',{credentials:'include'}).then(r=>r.json())
  await j('POST','/api/progress', { type: d.type, team_name: d.team_name || null, guesses_count: GUESSES.filter(g=>g.valid).length, remaining: REM, guesses: GUESSES })
  // exact auto-submit
  if (REM === 0) {
    const res = await j('POST','/api/submit', { type: d.type, team_name: d.team_name || null, guesses_count: GUESSES.filter(g=>g.valid).length, remaining: 0, exact: true, guesses: GUESSES })
    showFinal(res)
  }
}

function showFinal(res){
  const box = qs('#final')
  box.style.display = 'block'
  box.innerHTML = `<strong>Final:</strong> status <em>${res.status}</em> — score <b>${res.score}</b>`
}

async function giveUp(){
  const d = await fetch('/api/daily_category',{credentials:'include'}).then(r=>r.json())
  const res = await j('POST','/api/submit', { type: d.type, team_name: d.team_name || null, guesses_count: GUESSES.filter(g=>g.valid).length, remaining: REM, exact: false, guesses: GUESSES })
  showFinal(res)
}

function initAuth(){
  qs('#signup').addEventListener('click', async ()=>{
    const u=qs('#username').value, p=qs('#password').value
    const r=await j('POST','/api/register',{username:u,password:p}); if(r.ok===false){alert(r.error||'signup error');return} await refreshMe()
  })
  qs('#login').addEventListener('click', async ()=>{
    const u=qs('#username').value, p=qs('#password').value
    const r=await j('POST','/api/login',{username:u,password:p}); if(r.ok===false){alert(r.error||'login error');return} await refreshMe()
  })
  qs('#logout').addEventListener('click', async ()=>{ await j('POST','/api/logout'); await refreshMe() })
}

function initGame(){
  qs('#answer').addEventListener('input', e => {
    const q = e.target.value.toLowerCase()
    const box = qs('#suggestions'); box.innerHTML=''
    if (!q) return
    ENTITIES.filter(it=>it.label.toLowerCase().includes(q)).slice(0,15).forEach(it=>{
      const pill = el('div','suggestion'); pill.textContent = `${it.label} • ${it.value}`
      pill.addEventListener('click', ()=>{ qs('#answer').value = it.label })
      box.appendChild(pill)
    })
  })
  qs('#guessBtn').addEventListener('click', ()=>{ const v=qs('#answer').value; qs('#answer').value=''; qs('#suggestions').innerHTML=''; makeGuess(v) })
  qs('#answer').addEventListener('keydown', e=>{ if(e.key==='Enter'){ const v=qs('#answer').value; qs('#answer').value=''; qs('#suggestions').innerHTML=''; makeGuess(v)}})
  qs('#giveUpBtn').addEventListener('click', giveUp)
}

(async function main(){
  initAuth(); initGame(); await refreshMe()
})()
