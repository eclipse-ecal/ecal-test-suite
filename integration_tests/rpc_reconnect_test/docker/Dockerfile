# Dockerfile for rpc_reconnect_test
FROM ecal_base

ARG ROLE

WORKDIR /app

# Dependencies
RUN apt-get update && apt-get install -y libtclap-dev

# Copy helper lib and sources
COPY lib/EcalConfigHelper /app/lib/EcalConfigHelper
COPY rpc_reconnect_test/src/ /app/src/
COPY rpc_reconnect_test/scripts/entrypoint.sh /app/entrypoint.sh

# Build the specified target (client or server)
WORKDIR /app/src
RUN mkdir -p build && cd build && \
    cmake -DECALCONFIGHELPER_PATH=/app/lib/EcalConfigHelper .. && \
    make -j$(nproc)

# Setup entrypoint
WORKDIR /app
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
