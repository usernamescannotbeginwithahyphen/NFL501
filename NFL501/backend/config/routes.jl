using Genie, Genie.Router, Genie.Renderer.Json, SearchLight, SearchLightSQLite

include(joinpath(@__DIR__, "initializers.jl"))
Initializers.run_migrations!()

# load app
module NFL501
  include(joinpath(@__DIR__, "..", "src", "Utils", "Teams.jl"))
  include(joinpath(@__DIR__, "..", "src", "Services", "NFLVerse.jl"))
  include(joinpath(@__DIR__, "..", "src", "Services", "Aggregations.jl"))
  include(joinpath(@__DIR__, "..", "src", "Models", "DailyCategory.jl"))
  include(joinpath(@__DIR__, "..", "src", "Models", "GameResult.jl"))
  include(joinpath(@__DIR__, "..", "src", "Models", "User.jl"))
  include(joinpath(@__DIR__, "..", "src", "Controllers", "ApiController.jl"))
  include(joinpath(@__DIR__, "..", "src", "Controllers", "AuthController.jl"))
end

using .NFL501

Genie.config.run_as_server = true
Genie.config.server_host = "0.0.0.0"
Genie.config.server_port = 8000

route("/") do
  Genie.Renderer.Html.render_file(joinpath(@__DIR__, "..", "public", "index.html"))
end

route("/app.js") do
  Genie.Renderer.Json.render_file(joinpath(@__DIR__, "..", "public", "app.js"))
end

route("/styles.css") do
  Genie.Renderer.Json.render_file(joinpath(@__DIR__, "..", "public", "styles.css"))
end

# Auth
route("/api/register", method=POST) do; NFL501.AuthController.register!(); end
route("/api/login",    method=POST) do; NFL501.AuthController.login!();    end
route("/api/logout",   method=POST) do; NFL501.AuthController.logout!();   end
route("/api/me",       method=GET)  do; NFL501.AuthController.me!();       end

# Game
route("/api/daily_category", method=GET)  do; NFL501.ApiController.daily_category!();  end
route("/api/entities",       method=GET)  do; NFL501.ApiController.entities!();        end
route("/api/progress",       method=POST) do; NFL501.ApiController.progress!();       end
route("/api/submit",         method=POST) do; NFL501.ApiController.submit!();         end
route("/api/history",        method=GET)  do; NFL501.ApiController.history!();        end

Genie.AppServer.startup()
