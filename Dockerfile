ARG FOXGLOVE_RELEASE="2.0.1"

FROM ubuntu:22.04 AS foxglove-getter

ARG TARGETARCH
ARG FOXGLOVE_RELEASE

RUN apt update && apt install -y \
        curl

RUN curl -L https://get.foxglove.dev/desktop/latest/foxglove-studio-${FOXGLOVE_RELEASE}-linux-${TARGETARCH}.deb -o /tmp/foxglove-studio.deb

## =========================== Final Stage ===============================
FROM ubuntu:22.04

COPY --from=foxglove-getter /tmp/foxglove-studio.deb /tmp/foxglove-studio.deb

RUN apt update && apt install -y \
        /tmp/foxglove-studio.deb \
        libcanberra-gtk-module \
        libcanberra-gtk3-module \
        dbus \
        libasound2 && \
    apt list --installed 2>/dev/null | grep foxglove | grep -oP 'foxglove-studio/[a-zA-Z0-9,]+ \K[0-9]+\.[0-9]+\.[0-9]+' > /version.txt && \
    rm /tmp/foxglove-studio.deb && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /root/.foxglove-studio/extensions

COPY extensions /root/.foxglove-studio/extensions

CMD [ "foxglove-studio", "--no-sandbox" ]