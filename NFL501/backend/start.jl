using Genie
Genie.config.server_host = "0.0.0.0"
Genie.config.server_port = parse(Int, get(ENV, "PORT", "8000"))
include("/app/backend/config/routes.jl")
