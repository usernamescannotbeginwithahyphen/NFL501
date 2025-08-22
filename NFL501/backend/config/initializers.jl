module Initializers
using SearchLight, SearchLightSQLite

function run_migrations!()
  for file in sort(readdir(joinpath(@__DIR__, "..", "db", "migrations")))
    path = joinpath(@__DIR__, "..", "db", "migrations", file)
    sql = read(path, String)
    try
      SearchLight.query(sql)
    catch e
      @warn "migration failed" file path e
    end
  end
end

end
