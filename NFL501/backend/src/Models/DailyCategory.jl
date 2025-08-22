module DailyCategory
using SearchLight, Dates

@kwdef mutable struct DailyCategory <: SearchLight.AbstractModel
  id::DbId = DbId()
  date::Date = Date(0)
  category::String = ""
  team_abbr::Union{Nothing,String} = nothing
  key::String = ""
end

function ensure_for_date(d::Date, category::String, team_abbr::Union{Nothing,String})
  recs = SearchLight.find(DailyCategory; where="date = ?", values=[string(d)])
  if isempty(recs)
    k = string(category, "|", team_abbr === nothing ? "*" : team_abbr)
    rec = DailyCategory(date=d, category=category, team_abbr=team_abbr, key=k)
    SearchLight.save(rec)
    return rec
  else
    return first(recs)
  end
end

function last_n_days(n::Int)
  SearchLight.find(DailyCategory; limit=n, order="date DESC")
end

end
