FROM mysql:8.0.38-debian

# Install mysql-client
RUN apt-get update && \
    apt-get install -y mysql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy initialization scripts
COPY ./scripts /docker-entrypoint-initdb.d