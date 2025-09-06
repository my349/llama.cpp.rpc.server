FROM ubuntu:25.10

RUN apt update && \
    apt install -y g++ cmake libcurl4-openssl-dev

WORKDIR /app

COPY . .

RUN cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_NATIVE=OFF \
    -DLLAMA_BUILD_TESTS=OFF \
    -DGGML_BACKEND_DL=ON \
    -DGGML_CPU_ALL_VARIANTS=ON \
    -DGGML_RPC=ON;
RUN cmake --build build -j $(nproc) --target rpc-server

EXPOSE 8000/tcp

ENV LLAMA_ARG_RPC_PORT=$LLAMA_ARG_RPC_PORT
ENTRYPOINT /app/build/bin/rpc-server -H 127.0.0.1 -p $LLAMA_ARG_RPC_PORT
