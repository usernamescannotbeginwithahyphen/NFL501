
module NFLVerse
using DataFrames, CSV, HTTP, Dates

export load_player_stats, load_rosters_weekly, load_schedules

const DATA_DIR = get(ENV, "NFL501_DATA_DIR", abspath(joinpath(@__DIR__, "..", "..", "data")))

function _ensure_dir(p::AbstractString)
    isdir(p) || mkpath(p)
end

function _cache_path(url::AbstractString)
    fname = replace(url, r"[^A-Za-z0-9\.\-\_]" => "_")
    return joinpath(DATA_DIR, "cache", fname)
end

function _fetch_csv(url::AbstractString)::DataFrames.DataFrame
    _ensure_dir(joinpath(DATA_DIR, "cache"))
    fp = _cache_path(url)
    if isfile(fp)
        try
            return CSV.read(fp, DataFrames.DataFrame)
        catch
            # fallthrough to refetch
        end
    end
    r = HTTP.get(url)
    if r.status != 200
        error("HTTP $(r.status) fetching $(url)")
    end
    open(fp, "wb") do io
        write(io, r.body)
    end
    return CSV.read(fp, DataFrames.DataFrame)
end

# nflverse release URLs
_offense(y) = "https://github.com/nflverse/nflverse-data/releases/download/player_stats/player_stats_offense_$(y).csv"
_defense(y) = "https://github.com/nflverse/nflverse-data/releases/download/player_stats/player_stats_defense_$(y).csv"
_kicking(y) = "https://github.com/nflverse/nflverse-data/releases/download/player_stats/player_stats_kicking_$(y).csv"
_schedules(y) = "https://github.com/nflverse/nflverse-data/releases/download/schedules/schedules_$(y).csv"

function _years()
    s = get(ENV, "NFL501_DATA_YEARS", "")
    if !isempty(s)
        try
            return parse.(Int, split(s, ","))
        catch
        end
    end
    # default 1999..current
    return collect(1999:year(Dates.now()))
end

function load_player_stats(seasons::Vector{Int}=_years())
    dfs = DataFrames.DataFrame[]
    for y in seasons
        try push!(dfs, _fetch_csv(_offense(y))) catch e end
        try push!(dfs, _fetch_csv(_defense(y))) catch e end
        try push!(dfs, _fetch_csv(_kicking(y))) catch e end
    end
    if isempty(dfs); return DataFrames.DataFrame(); end
    df = vcat(dfs...; cols=:union)
    # Ensure columns exist
    for c in (:player_display_name, :recent_team, :season, :week)
        if !haskey(df, c); df[!, c] = missing; end
    end
    return df
end

function load_rosters_weekly(seasons::Vector{Int}=_years())
    s = load_player_stats(seasons)
    if isempty(s); return DataFrame(player_name=String[], team=String[]); end
    DataFrame(player_name = s[:, :player_display_name], team = s[:, :recent_team])
end

function load_schedules(seasons::Vector{Int}=_years())
    dfs = DataFrames.DataFrame[]
    for y in seasons
        try push!(dfs, _fetch_csv(_schedules(y))) catch e end
    end
    isempty(dfs) ? DataFrames.DataFrame() : vcat(dfs...; cols=:union)
end

end # module
