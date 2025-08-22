module ApiController
using Genie, Genie.Requests, Genie.Renderer.Json
using JSON3, Dates, Random, TimeZones
using ..Services.Aggregations
using ..Models.DailyCategory
using ..Models.GameResult
using ..Models.User
using ..Utils.Teams

const BASE_TYPES = [
  "GAMES_PLAYED",
  "PASS_TDS",
  "RUSH_TDS",
  "RECEPTIONS",
  "RECEIVING_TDS",
  "RUSH_ATTEMPTS",
  "PASS_COMPLETIONS",
  "INTERCEPTIONS_THROWN",
  "SACKS",
  "INTERCEPTIONS",
  "FORCED_FUMBLES",
  "FUMBLE_RECOVERIES",
  "TACKLES_COMBINED",
  "TACKLES_SOLO",
  "PASSES_DEFENDED",
  "FGM",
  "XP_MADE",
  "PUNTS",
  "SINGLE_GAME_REC_YARDS",
  "SINGLE_GAME_RUSH_YARDS",
  "SINGLE_GAME_RECEPTIONS",
  "SINGLE_GAME_PASS_TDS",
  "SINGLE_GAME_PASS_COMPLETIONS",
  "WINS_VS_TEAM",
]

const SUPPORTS_TEAM = Set([
  "GAMES_PLAYED","PASS_TDS","RUSH_TDS","RECEPTIONS","RECEIVING_TDS","RUSH_ATTEMPTS","PASS_COMPLETIONS","INTERCEPTIONS_THROWN",
  "SACKS","INTERCEPTIONS","FORCED_FUMBLES","FUMBLE_RECOVERIES","TACKLES_COMBINED","TACKLES_SOLO","PASSES_DEFENDED",
  "FGM","XP_MADE","PUNTS",
  "SINGLE_GAME_REC_YARDS","SINGLE_GAME_RUSH_YARDS","SINGLE_GAME_RECEPTIONS","SINGLE_GAME_PASS_TDS","SINGLE_GAME_PASS_COMPLETIONS"
])

function get_entities(typ::String, teamname::Union{Nothing,String})
  if typ == "WINS_VS_TEAM"
    return teamname === nothing ? Aggregations.Entity[] : entities_wins_vs_opponent(teamname)
  elseif typ == "GAMES_PLAYED"
    return teamname === nothing ? entities_games_played_all() : entities_games_played_by_team(teamname)
  elseif typ == "PASS_TDS"
    return teamname === nothing ? entities_pass_tds_all() : entities_pass_tds_for_team(teamname)
  elseif typ == "RUSH_TDS"
    return teamname === nothing ? entities_career_rush_tds_all() : entities_rush_tds_for_team(teamname)
  elseif typ == "RECEPTIONS"
    return teamname === nothing ? entities_receptions_all() : entities_receptions_for_team(teamname)
  elseif typ == "RECEIVING_TDS"
    return teamname === nothing ? entities_receiving_tds_all() : entities_receiving_tds_for_team(teamname)
  elseif typ == "RUSH_ATTEMPTS"
    return teamname === nothing ? entities_rush_attempts_all() : entities_rush_attempts_for_team(teamname)
  elseif typ == "PASS_COMPLETIONS"
    return teamname === nothing ? entities_pass_completions_all() : entities_pass_completions_for_team(teamname)
  elseif typ == "INTERCEPTIONS_THROWN"
    return teamname === nothing ? entities_interceptions_thrown_all() : entities_interceptions_thrown_for_team(teamname)
  elseif typ == "SACKS"
    return teamname === nothing ? entities_sacks_all() : entities_sacks_for_team(teamname)
  elseif typ == "INTERCEPTIONS"
    return teamname === nothing ? entities_def_interceptions_all() : entities_def_interceptions_for_team(teamname)
  elseif typ == "FORCED_FUMBLES"
    return teamname === nothing ? entities_forced_fumbles_all() : entities_forced_fumbles_for_team(teamname)
  elseif typ == "FUMBLE_RECOVERIES"
    return teamname === nothing ? entities_fumble_recoveries_all() : entities_fumble_recoveries_for_team(teamname)
  elseif typ == "TACKLES_COMBINED"
    return teamname === nothing ? entities_tackles_combined_all() : entities_tackles_combined_for_team(teamname)
  elseif typ == "TACKLES_SOLO"
    return teamname === nothing ? entities_tackles_solo_all() : entities_tackles_solo_for_team(teamname)
  elseif typ == "PASSES_DEFENDED"
    return teamname === nothing ? entities_passes_defended_all() : entities_passes_defended_for_team(teamname)
  elseif typ == "FGM"
    return teamname === nothing ? entities_fgm_all() : entities_fgm_for_team(teamname)
  elseif typ == "XP_MADE"
    return teamname === nothing ? entities_xp_made_all() : entities_xp_made_for_team(teamname)
  elseif typ == "PUNTS"
    return teamname === nothing ? entities_punts_all() : entities_punts_for_team(teamname)
  elseif typ == "SINGLE_GAME_REC_YARDS"
    return teamname === nothing ? entities_single_game_rec_yards_all() : entities_single_game_rec_yards_for_team(teamname)
  elseif typ == "SINGLE_GAME_RUSH_YARDS"
    return teamname === nothing ? entities_single_game_rush_yards_all() : entities_single_game_rush_yards_for_team(teamname)
  elseif typ == "SINGLE_GAME_RECEPTIONS"
    return teamname === nothing ? entities_single_game_receptions_all() : entities_single_game_receptions_for_team(teamname)
  elseif typ == "SINGLE_GAME_PASS_TDS"
    return teamname === nothing ? entities_single_game_pass_tds_all() : entities_single_game_pass_tds_for_team(teamname)
  elseif typ == "SINGLE_GAME_PASS_COMPLETIONS"
    return teamname === nothing ? entities_single_game_pass_completions_all() : entities_single_game_pass_completions_for_team(teamname)
  else
    return Aggregations.Entity[]
  end
end

# strict subset-sum to 501
function viable(ents::Vector{Aggregations.Entity})
  target = 501
  vals = Int[]
  for e in ents
    v = e.value
    if 0 < v <= target
      push!(vals, v)
    end
  end
  if isempty(vals); return false; end
  dp = falses(target + 1)
  dp[1] = true
  @inbounds for v in vals
    for s = target:-1:v
      if dp[s - v + 1]; dp[s + 1] = true; end
    end
    if dp[target + 1]; return true; end
  end
  return dp[target + 1]
end

# GET /api/entities?type=...&team=...
function entities!()
  q = Genie.Requests.query()
  typ = get(q, "type", "GAMES_PLAYED")
  teamname = get(q, "team", nothing)
  teamname = teamname === "" ? nothing : teamname
  ents = get_entities(typ, teamname)
  out = [(; id = e.id, label = e.label, value = e.value) for e in ents]
  return json((:ok => true, :data => out, :type => typ, :team => teamname))
end

# Daily category: 90% team weighting, no repeat (type+team) in 365 days, skip non-viable
function daily_category!()
  tz = TimeZone("America/Chicago")
  today = Date(ZonedDateTime(now(tz)))
  # finalize yesterday for logged-in user (if any)
  uid = Genie.Sessions.get(:uid, nothing)
  if uid !== nothing
    GameResult.finalize_if_incomplete_for_date!(Int(uid), today - Day(1))
  end

  recent = DailyCategory.last_n_days(365)
  used = Set(String(r.key) for r in recent)

  candidates = Tuple{String,Union{Nothing,String},Int}[]
  for t in BASE_TYPES
    if t == "WINS_VS_TEAM"
      for ab in Teams.TEAM_ABBRS
        push!(candidates, (t, ab, 10)) # requires team
      end
    elseif t in SUPPORTS_TEAM
      for ab in Teams.TEAM_ABBRS
        push!(candidates, (t, ab, 9))
      end
      push!(candidates, (t, nothing, 1))
    else
      push!(candidates, (t, nothing, 1))
    end
  end

  filtered = Tuple{String,Union{Nothing,String},Int}[]
  for (t, ab, w) in candidates
    k = string(t, "|", ab === nothing ? "*" : ab)
    if k in used; continue; end
    teamname = ab === nothing ? nothing : Teams.ABBR_TO_NAME[ab]
    ents = get_entities(t, teamname)
    if viable(ents)
      push!(filtered, (t, ab, w))
    end
  end

  chosen_t = nothing; chosen_ab = nothing
  if !isempty(filtered)
    weights = [w for (_,_,w) in filtered]
    total = sum(weights); r = rand() * total; acc = 0.0
    for i in 1:length(filtered)
      acc += weights[i]
      if r <= acc
        chosen_t, chosen_ab, _ = filtered[i]; break
      end
    end
  else
    # fallback: choose anything viable least-recently-used
    chosen_t, chosen_ab = "GAMES_PLAYED", nothing
  end

  teamname = chosen_ab === nothing ? nothing : Teams.ABBR_TO_NAME[String(chosen_ab)]
  rec = DailyCategory.ensure_for_date(today, String(chosen_t), chosen_ab === nothing ? nothing : String(chosen_ab))
  return json((:ok => true, :date => string(today), :type => rec.category, :team_abbr => chosen_ab, :team_name => teamname, :key => rec.key))
end

# Progress/Submit/History from v3
function progress!()
  uid = Genie.Sessions.get(:uid, nothing)
  if uid === nothing; return json((:ok => false, :error => "auth required"), status=401); end
  tz = TimeZone("America/Chicago")
  today = Date(ZonedDateTime(now(tz)))
  body = String(Genie.Requests.body()); j = JSON3.read(body)
  typ = String(get(j, "type", ""))
  team_name = get(j, "team_name", nothing)
  guesses_count = Int(get(j, "guesses_count", 0))
  remaining = Int(get(j, "remaining", 501))
  guesses_json = String(JSON3.write(get(j, "guesses", JSON3.Array([]))))
  team_abbr = team_name === nothing ? nothing : Teams.NAME_TO_ABBR[String(team_name)]
  rec = GameResult.upsert_progress!(Int(uid), today; category=typ, team=team_abbr, guesses_count=guesses_count, remaining=remaining, guesses_json=guesses_json)
  return json((:ok => true, :status => rec.status, :score => rec.score))
end

function submit!()
  uid = Genie.Sessions.get(:uid, nothing)
  if uid === nothing; return json((:ok => false, :error => "auth required"), status=401); end
  tz = TimeZone("America/Chicago")
  today = Date(ZonedDateTime(now(tz)))
  body = String(Genie.Requests.body()); j = JSON3.read(body)
  typ = String(get(j, "type", ""))
  team_name = get(j, "team_name", nothing)
  guesses_count = Int(get(j, "guesses_count", 0))
  remaining = Int(get(j, "remaining", 0))
  exact = Bool(get(j, "exact", false))
  guesses_json = String(JSON3.write(get(j, "guesses", JSON3.Array([]))))
  team_abbr = team_name === nothing ? nothing : Teams.NAME_TO_ABBR[String(team_name)]
  rec = GameResult.finalize_today!(Int(uid), today; exact=exact, guesses_count=guesses_count, remaining=remaining, category=typ, team=team_abbr, guesses_json=guesses_json)
  return json((:ok => true, :status => rec.status, :score => rec.score))
end

function history!()
  uid = Genie.Sessions.get(:uid, nothing)
  if uid === nothing; return json((:ok => false, :error => "auth required"), status=401); end
  rows = GameResult.history_for_user(Int(uid); limit=120)
  data = [Dict(
    :date => string(r.date),
    :type => r.category,
    :team => r.team,
    :key => r.key,
    :guesses_count => r.guesses_count,
    :remaining => r.remaining,
    :status => r.status,
    :score => r.score
  ) for r in rows]
  return json((:ok => true, :data => data))
end

end
