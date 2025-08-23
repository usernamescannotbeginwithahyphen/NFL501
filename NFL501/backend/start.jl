# --- bootstrap: make sure deps exist even on a totally fresh container ---
import Pkg
try
  # Ensure General registry is present
  Pkg.Registry.add(Pkg.RegistrySpec(name="General", url="https://github.com/JuliaRegistries/General"))
catch
  # already added
end

# Add/resolve everything we need by **name** (avoid UUID mismatches)
# Includes the ORM + adapter + DB driver.
Pkg.add([
  "Genie",
  "SearchLight",
  "SearchLightSQLite",
  "SQLite",
  "HTTP",
  "JSON3",
  "DataFrames",
  "CSV",
  "MbedTLS",
  "Bcrypt",
  "Parsers",
])
Pkg.precompile()

# now load
using Genie, HTTP, JSON3, DataFrames, CSV, SQLite, SearchLight, SearchLightSQLite, MbedTLS, Bcrypt, Parsers
# --- end bootstrap ---
