module GameResult
using SearchLight, Dates

@kwdef mutable struct GameResult <: SearchLight.AbstractModel
  id::DbId = DbId()
  user_id::Int = 0
  date::Date = Date(0)
  category::String = ""
  team::Union{Nothing,String} = nothing
  key::String = ""
  guesses_count::Int = 0
  remaining::Int = 501
  status::String = "incomplete"
  score::Int = 0
  guesses_json::String = "[]"
  inserted_at::DateTime = now()
  updated_at::DateTime = now()
end

function upsert_progress!(user_id::Int, date::Date; category::String, team::Union{Nothing,String}, guesses_count::Int, remaining::Int, guesses_json::String="[]")
  k = isnothing(team) ? string(category, "|*") : string(category, "|", team)
  existing = SearchLight.find(GameResult; where="user_id = ? AND date = ?", values=[user_id, string(date)])
  if isempty(existing)
    rec = GameResult(user_id=user_id, date=date, category=category, team=team, key=k, guesses_count=guesses_count, remaining=remaining, guesses_json=guesses_json, status="incomplete")
    SearchLight.save(rec); return rec
  else
    rec = first(existing)
    rec.category = category; rec.team = team; rec.key = k
    rec.guesses_count = guesses_count; rec.remaining = remaining; rec.guesses_json = guesses_json
    if rec.status == "incomplete"; SearchLight.save(rec); end
    return rec
  end
end

function finalize_today!(user_id::Int, date::Date; exact::Bool, guesses_count::Int, remaining::Int, category::String, team::Union{Nothing,String}, guesses_json::String="[]")
  rec = upsert_progress!(user_id, date; category=category, team=team, guesses_count=guesses_count, remaining=remaining, guesses_json=guesses_json)
  if rec.status != "incomplete"; return rec; end
  if exact
    rec.status = "exact"; rec.score = guesses_count
  else
    rec.status = "gave_up"; rec.score = guesses_count + remaining
  end
  SearchLight.save(rec); return rec
end

function finalize_if_incomplete_for_date!(user_id::Int, date::Date)
  existing = SearchLight.find(GameResult; where="user_id = ? AND date = ?", values=[user_id, string(date)])
  if isempty(existing); return nothing; end
  rec = first(existing)
  if rec.status == "incomplete"
    rec.status = "gave_up"; rec.score = rec.guesses_count + rec.remaining
    SearchLight.save(rec); return rec
  end
  return rec
end

function history_for_user(user_id::Int; limit::Int=60)
  SearchLight.find(GameResult; where="user_id = ?", values=[user_id], limit=limit, order="date DESC")
end

end
