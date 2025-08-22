import Pkg

# Add the General registry once (no-op if it already exists)
try
    Pkg.Registry.add("General")
catch err
    @info "registry add skipped" err=err
end

# Resolve packages into the persistent depot
Pkg.instantiate()

# Start the Genie server on the port Render provides
using Genie
Genie.config.server_host = "0.0.0.0"
Genie.config.server_port = parse(Int, get(ENV, "PORT", "8000"))

# Boot your app
include("/app/backend/config/routes.jl")
