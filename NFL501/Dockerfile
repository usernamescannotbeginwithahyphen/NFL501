
FROM julia:1.10-bullseye
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*

COPY backend /app/backend
RUN julia --project=/app/backend -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

RUN mkdir -p /app/backend/data
VOLUME ["/app/backend/data"]

ENV JULIA_PROJECT=/app/backend
ENV GENIE_ENV=production
ENV NFL501_DATA_DIR=/app/backend/data

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=5 CMD curl -fsS http://localhost:8000/ || exit 1

CMD ["julia", "--project=/app/backend", "-e", "include(\"/app/backend/config/routes.jl\");"]
