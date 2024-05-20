FROM python:3.11-alpine AS builder

ARG AWSCLI_VERSION

RUN test -n "$AWSCLI_VERSION" || (echo "AWSCLI_VERSION not set" && false)

RUN apk update && apk add --no-cache \
    curl \
    make \
    cmake \
    gcc \
    g++ \
    libc-dev \
    libffi-dev \
    openssl-dev

RUN curl https://awscli.amazonaws.com/awscli-${AWSCLI_VERSION}.tar.gz | tar -xz \
    && cd awscli-${AWSCLI_VERSION} \
    && ./configure --prefix=/opt/aws-cli/ --with-download-deps \
    && make \
    && make install

FROM python:3.11-alpine
COPY --from=builder /opt/aws-cli/ /opt/aws-cli/
RUN ln -s /opt/aws-cli/bin/aws /usr/bin/aws

# groff is needed for help text
RUN apk update && apk add --no-cache groff
ENTRYPOINT ["/usr/bin/aws"]
