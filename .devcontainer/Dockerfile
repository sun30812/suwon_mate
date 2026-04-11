FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt
RUN apt update && apt upgrade -y
RUN apt install -y curl git unzip xz-utils zip libglu1-mesa tar
RUN git clone https://github.com/flutter/flutter.git -b stable
RUN chown -R vscode flutter