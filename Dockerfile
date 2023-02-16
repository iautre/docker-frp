FROM golang:alpine as go-builder

LABEL maintainer="a little <little@autre.cn> https://coding.autre.cn"

ARG FRPS_VERSION=0.47.0
WORKDIR /app

RUN set -x \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update && apk upgrade\
    && apk --no-cache add tzdata upx

RUN set -x \
    && go env -w GO111MODULE=on \
    && go env -w GOPROXY=https://goproxy.cn,direct \
    && go env -w CGO_ENABLED=0 \
    && go env -w GOOS=linux
    
RUN set -x \
    && wget https://github.com/fatedier/frp/archive/refs/tags/v${FRPS_VERSION}.tar.gz \
    && tar -zxvf v${FRPS_VERSION}.tar.gz -C ./ \
    && mv frp-${FRPS_VERSION}/* ./

RUN set -x \
    ## -ldflags "-s -w"进新压缩
    && go build -trimpath -ldflags "-s -w" -o frps_temp ./cmd/frps \
    ## 借助第三方工具再压缩压缩级别为-1-9
    && upx -9 frps_temp -o /app/frps

# production stage
FROM scratch as production

ENV GO_ENV=prod

VOLUME ["/conf"]

COPY --from=go-builder /app/frps frps
COPY --from=go-builder /app/conf/frps* /conf/
COPY --from=go-builder /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# EXPOSE 7000
ENTRYPOINT ["/frps", "-c", "/conf/frps.ini"]