set shell := ["bash", "-cu"]

default: build

build:
    sudo podman build -t leloi-linux .
    sudo podman run --rm -it --privileged --pull=newer \
    --security-opt label=type:unconfined_t \
    -v ./output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    -v ./config.toml:/config.toml:ro \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type iso \
    --chown 1000:1000 \
    localhost/leloi-linux

clean:
    trash ./output
    mkdir ./output
