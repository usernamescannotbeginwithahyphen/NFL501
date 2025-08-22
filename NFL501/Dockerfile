# Dockerfile (Render-safe, Julia 1.9.4)
FROM julia:1.9.4-bullseye

WORKDIR /app
# tzdata so Dates.now() uses America/Chicago; curl for healthchecks
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends     tzdata curl ca-certificates  && ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime  && dpkg-reconfigure -f noninteractive tzdata  && rm -rf /var/lib/apt/lists/*

ENV TZ=America/Chicago
ENV JULIA_PKG_SERVER=https://pkg.julialang.org

# Persist packages + app data on your Render Disk mounted at /app/backend/data
ENV JULIA_PROJECT=/app/backend     GENIE_ENV=production     NFL501_DATA_DIR=/app/backend/data     JULIA_DEPOT_PATH=/app/backend/data/depot

# Copy backend source
COPY backend /app/backend

# Prepare persistent dirs (become backed by the disk at runtime)
RUN mkdir -p /app/backend/data /app/backend/data/depot

EXPOSE 8000

# Safe bootstrap: try to add General registry if missing, then instantiate, start server
CMD ["julia","--project=/app/backend","-e","using Pkg; try Pkg.Registry.add(\"General\") catch err; @info(\"registry add skipped\", err=err); end; Pkg.instantiate(); include(\"/app/backend/config/routes.jl\");"]
