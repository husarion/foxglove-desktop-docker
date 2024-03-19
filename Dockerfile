ARG ROS_DISTRO=humble


FROM ubuntu:22.04 AS foxglove-getter

ARG TARGETARCH="amd64"
ARG FOXGLOVE_RELEASE="2.0.1"

RUN apt update && apt install -y \
        curl

RUN curl -L https://get.foxglove.dev/desktop/latest/foxglove-studio-${FOXGLOVE_RELEASE}-linux-${TARGETARCH}.deb -o /tmp/foxglove-studio.deb

## =========================== Final Stage ===============================
FROM husarnet/ros:$ROS_DISTRO-ros-core

COPY --from=foxglove-getter /tmp/foxglove-studio.deb /tmp/foxglove-studio.deb

RUN apt update && apt install -y \
        /tmp/foxglove-studio.deb \
        libasound2 && \
    apt list --installed 2>/dev/null | grep foxglove | grep -oP 'foxglove-studio/[a-zA-Z0-9,]+ \K[0-9]+\.[0-9]+\.[0-9]+' > /version.txt && \
    rm /tmp/foxglove-studio.deb && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /root/.foxglove-studio/extensions

RUN apt update && apt install -y \
        ros-$ROS_DISTRO-joy \
        libcanberra-gtk-module \
        dbus

COPY extensions /root/.foxglove-studio/extensions

CMD [ "foxglove-studio", "--no-sandbox" ]