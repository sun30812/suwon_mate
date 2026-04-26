FROM mcr.microsoft.com/devcontainers/base:debian

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt
RUN apt update && apt upgrade -y
RUN apt install --no-install-recommends -y curl git unzip xz-utils zip libglu1-mesa tar
RUN git clone --depth 1 https://github.com/flutter/flutter.git -b stable
RUN chown -R vscode flutter