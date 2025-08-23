# Use a modern LTS Julia; 1.10.x has fewer Pkg quirks than 1.9
FROM julia:1.10.5-bullseye

WORKDIR /app
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    tzdata ca-certificates git \
 && ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata \
 && rm -rf /var/lib/apt/lists/*

ENV TZ=America/Chicago
ENV GENIE_ENV=production
ENV NFL501_DATA_DIR=/app/backend/data

# Copy your backend
COPY backend /app/backend

# App data dir (db + caches)
RUN mkdir -p /app/backend/data

EXPOSE 8000
CMD ["julia","--project=@.","/app/backend/start.jl"]
