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
    -DGGML_CPU_ALL_VARIANTS=ON;
RUN cmake --build build -j $(nproc) --target llama-server

ENV LLAMA_CHAT_TEMPLATE_KWARGS='{"reasoning_effort":"medium","builtin_tools":[]}'
ENV LLAMA_ARG_HF_REPO=ggml-org/gpt-oss-20b-GGUF
#ENV LLAMA_ARG_API_PREFIX=$LLAMA_ARG_API_PREFIX
ENV LLAMA_ARG_CONTEXT_SHIFT=1
ENV LLAMA_ARG_CTX_SIZE=0
ENV LLAMA_ARG_NO_WEBUI=1
ENV LLAMA_ARG_JINJA=1
ENV LLAMA_ARG_HOST=0.0.0.0

EXPOSE 8080/tcp

HEALTHCHECK CMD curl -f http://0.0.0.0:8080/$LLAMA_ARG_API_PREFIX/health
ENTRYPOINT [ "/app/build/bin/llama-server" ]
