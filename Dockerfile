# 빌드 레이어
FROM ubuntu:22.04 AS builder

# 빌드 의존성 설치
RUN apt update && apt install -y \
    build-essential cmake libmicrohttpd-dev \
    libjansson-dev libssl-dev libsrtp2-dev libsofia-sip-ua-dev \
    libglib2.0-dev libopus-dev libogg-dev libcurl4-openssl-dev \
    liblua5.3-dev libconfig-dev pkg-config gengetopt libtool automake autoconf \
    libnice-dev \
    git \
    wget \
    libwebsockets-dev \
    && rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 설정
WORKDIR /opt/janus-gateway

# 소스 코드 복사 (로컬 빌드 컨텍스트에서)
COPY . .

# 컴파일
RUN sh autogen.sh && \
    ./configure --prefix=/opt/janus && \
    make -j$(nproc) && \
    make install && \
    make configs

# 런타임 레이어
FROM ubuntu:22.04

# 런타임 의존성만 설치
RUN apt update && apt install -y \
    libmicrohttpd12 libjansson4 libssl3 libsrtp2-1 \
    libsofia-sip-ua0 libglib2.0-0 libopus0 libogg0 \
    libcurl4 liblua5.3-0 libconfig9 \ 
    libnice10 \
    libwebsockets16 \
    && rm -rf /var/lib/apt/lists/*

# 컴파일된 바이너리와 설정 파일만 복사
COPY --from=builder /opt/janus /opt/janus

# 환경 변수 설정
ENV PATH="/opt/janus/bin:$PATH"

# 포트 개방
EXPOSE 8088 8089 8188 8189 10000-10010/udp
EXPOSE 8000 

# 실행 명령어
CMD ["janus"]
