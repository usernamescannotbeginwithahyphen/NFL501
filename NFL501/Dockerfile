# Dockerfile (Render-safe, no build-time Julia)
FROM julia:1.10.5-bullseye

WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Make package downloads robust on CI builders
ENV JULIA_PKG_SERVER=https://pkg.julialang.org

# Persist Julia packages + your app data on the Render Disk (mounted at /app/backend/data)
ENV JULIA_PROJECT=/app/backend \
    GENIE_ENV=production \
    NFL501_DATA_DIR=/app/backend/data \
    JULIA_DEPOT_PATH=/app/backend/data/depot

# Copy your backend code
COPY backend /app/backend

# Create directories that become persistent when the disk is mounted at runtime
RUN mkdir -p /app/backend/data /app/backend/data/depot

EXPOSE 8000

# First boot will download packages into the persistent depot, then start Genie
CMD ["julia","--project=/app/backend","-e","using Pkg; try Pkg.Registry.add(\"General\") catch end; Pkg.instantiate(); include(\"/app/backend/config/routes.jl\");"]
