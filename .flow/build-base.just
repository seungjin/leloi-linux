default: base-image

current_tag := `curl -s \
  -H "Authorization: Bearer $(curl -s "https://ghcr.io/token?scope=repository:seungjin/leloi-linux-base:pull" | jq -r '.token')" \
  https://ghcr.io/v2/seungjin/leloi-linux-base/tags/list \
  | jq -r '.tags[]' | sort -V | grep -v latest | tail -1`

base-image:
    #!/usr/bin/env bash
    cd /workspace/src
    next_tag=$(( {{ current_tag }} + 1 ))
    current_tag={{ current_tag }}

    buildah bud --format docker --layers -f Containerfile-base -t leloi-linux-base:$next_tag-temp > /dev/null 2>&1

    local_image_id=$(skopeo inspect --format '{{ "{{" }} .Layers {{ "}}" }}' containers-storage:localhost/leloi-linux-base:$next_tag-temp)
    remote_image_id=$(skopeo inspect --format '{{ "{{" }} .Layers {{ "}}" }}' docker://ghcr.io/seungjin/leloi-linux-base:$current_tag)

    if diff <(echo "$local_image_id") <(echo "$remote_image_id") > /dev/null ; then
        echo "[{\"result\": \"No image pushed\"}]" 
        exit 0
    fi

    skopeo login "$CONTAINER_REPO" -u "$CONTAINER_REPO_USERNAME" -p "$CONTAINER_REPO_PASSWORD"
    skopeo copy containers-storage:localhost/leloi-linux-base:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux-base:$next_tag
    skopeo copy containers-storage:localhost/leloi-linux-base:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux-base:latest
    echo "[{\"result\": \"New image: ghcr.io/seungjin/leloi-linux-base:$next_tag\"}]"
    exit 0
