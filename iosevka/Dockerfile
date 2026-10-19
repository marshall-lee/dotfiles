# syntax=docker/dockerfile:1
# Builds Iosevka Term SS06X and patches it with Nerd Fonts. The final stage
# holds only the fonts: docker buildx build --output type=local,dest=dist .

ARG IOSEVKA_VERSION=34.9.0
ARG NERD_FONTS_VERSION=3.5.1

FROM node:24-trixie-slim AS iosevka
ARG IOSEVKA_VERSION
WORKDIR /iosevka
ADD https://github.com/be5invis/Iosevka/archive/refs/tags/v${IOSEVKA_VERSION}.tar.gz /tmp/iosevka.tar.gz
RUN tar -xzf /tmp/iosevka.tar.gz --strip-components=1 && rm /tmp/iosevka.tar.gz && npm ci
COPY private-build-plans.toml .
# Each build job needs over 1 GB of RAM.
ARG JOBS=4
RUN npm run build -- ttf-unhinted::IosevkaTermSS06X --jCmd=${JOBS}

FROM debian:trixie-slim AS nerd-fonts
ARG NERD_FONTS_VERSION
RUN apt-get update \
 && apt-get install -y --no-install-recommends fontforge python3-fontforge \
 && rm -rf /var/lib/apt/lists/*
ADD https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONTS_VERSION}/FontPatcher.zip /tmp/
RUN python3 -m zipfile -e /tmp/FontPatcher.zip /patcher && rm /tmp/FontPatcher.zip
COPY --from=iosevka /iosevka/dist/IosevkaTermSS06X/TTF-Unhinted/ /in/
RUN for font in /in/*.ttf; do \
      fontforge -script /patcher/font-patcher --complete --mono --quiet --outputdir /out "$font" || exit 1; \
    done
COPY verify.py /
RUN fontforge -script /verify.py /out/*.ttf

FROM scratch
COPY --from=nerd-fonts /out/ /
