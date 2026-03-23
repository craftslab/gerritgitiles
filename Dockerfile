FROM eclipse-temurin:11-jdk-jammy AS builder

ARG BAZEL_VERSION=7.0.1
ARG GITILES_REPOSITORY=https://github.com/GerritCodeReview/gitiles.git
ARG GITILES_REF=v1.6.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        ca-certificates-java \
        curl \
        git \
        python-is-python3 \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /usr/local/bin/bazel \
      "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64" \
    && chmod +x /usr/local/bin/bazel

WORKDIR /src

RUN git clone --branch "${GITILES_REF}" --depth 1 --single-branch \
      --recurse-submodules --shallow-submodules "${GITILES_REPOSITORY}" gitiles \
    && cd gitiles \
    && sed -i "s#https://gerrit.googlesource.com/bazlets#https://github.com/GerritCodeReview/bazlets.git#" tools/bazlets.bzl \
    && bazel --server_javabase=/usr/lib/jvm/java-11-openjdk-amd64 build //:gitiles \
    && cp bazel-bin/gitiles.war /gitiles.war

FROM jetty:9.4-jre11

ENV JAVA_OPTIONS="-Dcom.google.gitiles.configPath=/var/lib/gitiles/gitiles.config"

USER root
RUN mkdir -p /var/lib/gitiles /var/git \
    && chown -R jetty:jetty /var/lib/gitiles /var/git

COPY --from=builder /gitiles.war /var/lib/jetty/webapps/ROOT.war
COPY gitiles.config /var/lib/gitiles/gitiles.config
RUN chown jetty:jetty /var/lib/jetty/webapps/ROOT.war /var/lib/gitiles/gitiles.config

USER jetty

VOLUME ["/var/git"]
