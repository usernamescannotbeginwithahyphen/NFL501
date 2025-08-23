FROM julia:1.9.4-bullseye

WORKDIR /app
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    tzdata curl ca-certificates \
 && ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata \
 && rm -rf /var/lib/apt/lists/*

ENV TZ=America/Chicago
ENV JULIA_PKG_SERVER=https://pkg.julialang.org
# NOTE: do NOT set JULIA_DEPOT_PATH to your data disk. Keep packages inside the image.

# Copy code and resolve packages during image build
COPY backend /app/backend

# If your code uses SearchLightSQLite, uncomment the Pkg.add line.
# Otherwise, skip it (the Project.toml you pasted has moved to using SQLite.jl directly).
RUN julia --project=/app/backend -e 'using Pkg; \
    Pkg.Registry.add("General"); \
    # Pkg.add("SearchLightSQLite"); \
    Pkg.instantiate(); \
    Pkg.precompile()'

# App data dir (used for SQLite DB + nflverse cache)
RUN mkdir -p /app/backend/data

EXPOSE 8000
CMD ["julia","--project=/app/backend","/app/backend/start.jl"]
