default: base-image

base-image:
    #!/usr/bin/env bash
    cd /workspace/src

    current_tag=$(skopeo list-tags docker://ghcr.io/seungjin/leloi-linux | jq -r '.Tags[]' | grep -v latest | sort -V | tail -1)
    next_tag=$(( $current_tag + 1 ))

    base_version=$(skopeo inspect docker://quay.io/fedora/fedora-bootc:43 | jq -r '.Labels["org.opencontainers.image.version"]')
    this_version=$base_version+next_tag

    buildah bud --format docker --layers --build-arg VERSION=$this_version -f Containerfile -t leloi-linux:$next_tag-temp > /dev/null 2>&1

    local_image_id=$(skopeo inspect --format '{{ "{{" }} .Layers {{ "}}" }}' containers-storage:localhost/leloi-linux:$next_tag-temp)
    remote_image_id=$(skopeo inspect --format '{{ "{{" }} .Layers {{ "}}" }}' docker://ghcr.io/seungjin/leloi-linux:$current_tag)

    if diff <(echo "$local_image_id") <(echo "$remote_image_id") > /dev/null ; then
        echo "[{\"result\": \"No image pushed\"}]" 
        exit 0
    fi

    skopeo login "$CONTAINER_REPO" -u "$CONTAINER_REPO_USERNAME" -p "$CONTAINER_REPO_PASSWORD"
    skopeo copy containers-storage:localhost/leloi-linux:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux:$next_tag
    skopeo copy containers-storage:localhost/leloi-linux:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux:latest
    echo "[{\"result\": \"New image: ghcr.io/seungjin/leloi-linux:$next_tag\"}]"
    exit 0
