module Aggregations
using DataFrames, Dates, Statistics
using ..Utils.Teams
using ..Services.NFLVerse

export Entity,
       entities_games_played_all, entities_games_played_by_team,
       entities_pass_tds_all, entities_pass_tds_for_team,
       entities_career_rush_tds_all, entities_rush_tds_for_team,
       entities_receptions_all, entities_receptions_for_team,
       entities_receiving_tds_all, entities_receiving_tds_for_team,
       entities_rush_attempts_all, entities_rush_attempts_for_team,
       entities_pass_completions_all, entities_pass_completions_for_team,
       entities_interceptions_thrown_all, entities_interceptions_thrown_for_team,
       entities_sacks_all, entities_sacks_for_team,
       entities_def_interceptions_all, entities_def_interceptions_for_team,
       entities_forced_fumbles_all, entities_forced_fumbles_for_team,
       entities_fumble_recoveries_all, entities_fumble_recoveries_for_team,
       entities_tackles_combined_all, entities_tackles_combined_for_team,
       entities_tackles_solo_all, entities_tackles_solo_for_team,
       entities_passes_defended_all, entities_passes_defended_for_team,
       entities_fgm_all, entities_fgm_for_team,
       entities_xp_made_all, entities_xp_made_for_team,
       entities_punts_all, entities_punts_for_team,
       entities_single_game_rec_yards_all, entities_single_game_rec_yards_for_team,
       entities_single_game_rush_yards_all, entities_single_game_rush_yards_for_team,
       entities_single_game_receptions_all, entities_single_game_receptions_for_team,
       entities_single_game_pass_tds_all, entities_single_game_pass_tds_for_team,
       entities_single_game_pass_completions_all, entities_single_game_pass_completions_for_team,
       entities_wins_vs_opponent

const DEFAULT_SEASONS = collect(1999:year(today()))

struct Entity
  id::String
  label::String
  value::Int
end

# Helpers
function _sum(df, groupcol, valcols, outcol; round_int=false)
  col = nothing
  for c in valcols
    if haskey(df, c); col = c; break; end
  end
  if col === nothing; return DataFrame(; x=[], y=[]); end
  combine(groupby(df, groupcol), col => sum => outcol)
end

function _entities_from_sum(df, namecol::Symbol, valcols::Vector{Symbol}, outcol::Symbol; round_int::Bool=false)
  if nrow(df) == 0; return Entity[]; end
  g = _sum(df, namecol, valcols, outcol; round_int=round_int)
  if nrow(g) == 0; return Entity[]; end
  sort!(g, outcol, rev=true)
  out = Entity[]
  for r in eachrow(g)
    v = r[outcol]
    v = round_int ? Int(round(v)) : Int(v)
    push!(out, Entity(string(r[namecol]), string(r[namecol]), v))
  end
  return out
end

function _entities_from_max(df, namecol::Symbol, valcols::Vector{Symbol}, outcol::Symbol)
  if nrow(df) == 0; return Entity[]; end
  col = nothing
  for c in valcols
    if haskey(df, c); col = c; break; end
  end
  if col === nothing; return Entity[]; end
  g = combine(groupby(df, namecol), col => maximum => outcol)
  sort!(g, outcol, rev=true)
  return [Entity(string(r[namecol]), string(r[namecol]), Int(r[outcol])) for r in eachrow(g)]
end

# Games played
function entities_games_played_all(; seasons=DEFAULT_SEASONS)
  rosters = NFLVerse.load_rosters_weekly(seasons)
  gdf = combine(groupby(rosters, :player_name), nrow => :gp)
  sort!(gdf, :gp, rev=true); return [Entity(string(r.player_name), string(r.player_name), Int(r.gp)) for r in eachrow(gdf)]
end
function entities_games_played_by_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]
  rosters = NFLVerse.load_rosters_weekly(seasons)
  team_rows = rosters[rosters[:, :team] .== abbr, :]
  gdf = combine(groupby(team_rows, :player_name), nrow => :gp)
  sort!(gdf, :gp, rev=true); return [Entity(string(r.player_name), string(r.player_name), Int(r.gp)) for r in eachrow(gdf)]
end

# Offense
function entities_pass_tds_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:passing_tds], :ptd)
end
function entities_pass_tds_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:passing_tds], :ptd)
end

function entities_career_rush_tds_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:rushing_tds], :rtd)
end
function entities_rush_tds_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:rushing_tds], :rtd)
end

function entities_receptions_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:receptions], :recs)
end
function entities_receptions_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:receptions], :recs)
end

function entities_receiving_tds_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:receiving_tds], :retd)
end
function entities_receiving_tds_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:receiving_tds], :retd)
end

function entities_rush_attempts_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:carries, :rushing_att, :rushing_attempts], :ra)
end
function entities_rush_attempts_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:carries, :rushing_att, :rushing_attempts], :ra)
end

function entities_pass_completions_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:completions, :passing_completions], :comp)
end
function entities_pass_completions_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:completions, :passing_completions], :comp)
end

function entities_interceptions_thrown_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:interceptions], :ints_thrown)
end
function entities_interceptions_thrown_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:interceptions], :ints_thrown)
end

# Defense
function entities_sacks_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:sacks, :def_sacks], :scks; round_int=true)
end
function entities_sacks_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:sacks, :def_sacks], :scks; round_int=true)
end

function entities_def_interceptions_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:def_interceptions, :interceptions], :defints)
end
function entities_def_interceptions_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:def_interceptions, :interceptions], :defints)
end

function entities_forced_fumbles_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:def_fumbles_forced, :forced_fumbles], :ff)
end
function entities_forced_fumbles_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:def_fumbles_forced, :forced_fumbles], :ff)
end

function entities_fumble_recoveries_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:def_fumbles_rec, :fumble_recoveries, :fumbles_recovered], :fr)
end
function entities_fumble_recoveries_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:def_fumbles_rec, :fumble_recoveries, :fumbles_recovered], :fr)
end

function entities_tackles_combined_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:tackles_combined, :tackles, :total_tackles], :tackles)
end
function entities_tackles_combined_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:tackles_combined, :tackles, :total_tackles], :tackles)
end

function entities_tackles_solo_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:tackles_solo, :solo_tackles], :tackles_solo)
end
function entities_tackles_solo_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:tackles_solo, :solo_tackles], :tackles_solo)
end

function entities_passes_defended_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:passes_defended, :passes_defensed, :pass_defended], :pd)
end
function entities_passes_defended_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:passes_defended, :passes_defensed, :pass_defended], :pd)
end

# Special Teams
function entities_fgm_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:field_goals_made, :field_goals], :fgm)
end
function entities_fgm_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:field_goals_made, :field_goals], :fgm)
end

function entities_xp_made_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:xp_made, :extra_points_made], :xpm)
end
function entities_xp_made_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:xp_made, :extra_points_made], :xpm)
end

function entities_punts_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_sum(s, :player_display_name, [:punts], :punts)
end
function entities_punts_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_sum(df, :player_display_name, [:punts], :punts)
end

# Single-game maxima
function entities_single_game_rec_yards_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_max(s, :player_display_name, [:receiving_yards], :maxrec)
end
function entities_single_game_rec_yards_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_max(df, :player_display_name, [:receiving_yards], :maxrec)
end

function entities_single_game_rush_yards_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_max(s, :player_display_name, [:rushing_yards], :maxrush)
end
function entities_single_game_rush_yards_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_max(df, :player_display_name, [:rushing_yards], :maxrush)
end

function entities_single_game_receptions_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_max(s, :player_display_name, [:receptions], :maxrecs)
end
function entities_single_game_receptions_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_max(df, :player_display_name, [:receptions], :maxrecs)
end

function entities_single_game_pass_tds_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_max(s, :player_display_name, [:passing_tds], :maxptd)
end
function entities_single_game_pass_tds_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_max(df, :player_display_name, [:passing_tds], :maxptd)
end

function entities_single_game_pass_completions_all(; seasons=DEFAULT_SEASONS)
  s = NFLVerse.load_player_stats(seasons); return _entities_from_max(s, :player_display_name, [:completions, :passing_completions], :maxcomp)
end
function entities_single_game_pass_completions_for_team(teamname::String; seasons=DEFAULT_SEASONS)
  abbr = Teams.NAME_TO_ABBR[teamname]; s = NFLVerse.load_player_stats(seasons); df = s[s[:, :recent_team] .== abbr, :]; return _entities_from_max(df, :player_display_name, [:completions, :passing_completions], :maxcomp)
end

# Team vs opponent (teams as entities)
function entities_wins_vs_opponent(teamname::String; seasons=DEFAULT_SEASONS)
  opp = Teams.NAME_TO_ABBR[teamname]
  sched = NFLVerse.load_schedules(seasons)
  if nrow(sched) == 0 || !all(h -> haskey(sched, h), [:home_team,:away_team,:home_score,:away_score])
    return Entity[]
  end
  sched[:, :winner] = ifelse.(sched[:, :home_score] .> sched[:, :away_score], sched[:, :home_team],
                       ifelse.(sched[:, :home_score] .< sched[:, :away_score], sched[:, :away_team], "TIE"))
  wins = Dict{String,Int}()
  for r in eachrow(sched)
    if r[:winner] == "TIE"; continue; end
    if r[:home_team] == opp
      if r[:winner] == r[:away_team]; wins[r[:away_team]] = get(wins, r[:away_team], 0) + 1; end
    elseif r[:away_team] == opp
      if r[:winner] == r[:home_team]; wins[r[:home_team]] = get(wins, r[:home_team], 0) + 1; end
    end
  end
  ents = [Entity(t, Teams.ABBR_TO_NAME[t], v) for (t,v) in wins]
  sort!(ents, by = e->e.value, rev=true)
  return ents
end

end
