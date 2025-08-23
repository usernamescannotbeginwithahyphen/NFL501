#!/usr/bin/env bash
set -euo pipefail

# enter the backend folder (handles nested repo layouts)
if [ -d NFL501/backend ]; then
  cd NFL501/backend
elif [ -d backend ]; then
  cd backend
else
  echo "backend/ not found" >&2
  exit 1
fi

# generate the Manifest.toml
julia --project -e 'using Pkg; Pkg.Registry.add("General"); Pkg.instantiate(); Pkg.precompile()'
