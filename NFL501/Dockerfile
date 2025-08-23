FROM julia:1.9.4-bullseye

WORKDIR /app
# tzdata for Central time; git helps Pkg when it needs it
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    tzdata ca-certificates git \
 && ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata \
 && rm -rf /var/lib/apt/lists/*

ENV TZ=America/Chicago
ENV JULIA_PKG_SERVER=https://pkg.julialang.org
# NOTE: do NOT set JULIA_DEPOT_PATH to your data disk. Keep packages inside the image.
ENV JULIA_PROJECT=/app/backend \
    GENIE_ENV=production \
    NFL501_DATA_DIR=/app/backend/data

# Copy the app
COPY backend /app/backend

# Resolve packages during image build (3 attempts, no precompile to keep memory low)
RUN julia --color=yes --project=/app/backend -e 'import Pkg; \
for i in 1:3; \
  println(">>> Pkg resolve attempt ", i); \
  try; \
    Pkg.Registry.add(Pkg.RegistrySpec(url="https://github.com/JuliaRegistries/General")); \
    Pkg.instantiate(); \
    break; \
  catch e; \
    i==3 && rethrow(e); \
    sleep(5); \
  end; \
end'

# App data dir (SQLite DB + nflverse cache)
RUN mkdir -p /app/backend/data

EXPOSE 8000
CMD ["julia","--project=/app/backend","/app/backend/start.jl"]
