# Dockerfile (Render-safe, Julia 1.9.4)
FROM julia:1.9.4-bullseye

WORKDIR /app
# tzdata so Dates.now() uses Central time; curl for healthchecks
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    tzdata curl ca-certificates \
 && ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata \
 && rm -rf /var/lib/apt/lists/*

ENV TZ=America/Chicago
# Use the official pkg server (fewer weird edge cases than raw GitHub tars)
ENV JULIA_PKG_SERVER=https://pkg.julialang.org

# Persist packages + your app data on the Render Disk (mount here in the service)
ENV JULIA_PROJECT=/app/backend \
    GENIE_ENV=production \
    NFL501_DATA_DIR=/app/backend/data \
    JULIA_DEPOT_PATH=/app/backend/data/depot

# Copy code
COPY backend /app/backend

# Prepare persistent dirs (become backed by Render disk at runtime)
RUN mkdir -p /app/backend/data /app/backend/data/depot

EXPOSE 8000

# IMPORTANT: do NOT force-remove/re-add the registry.
# Add "General" only if missing, then instantiate, then start the server.
CMD ["julia","--project=/app/backend","-e","using Pkg; try Pkg.Registry.add(\"General\") catch err; @info(\"registry add skipped\", err=err); end; Pkg.instantiate(); include(\"/app/backend/config/routes.jl\");"]
