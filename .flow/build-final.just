default: base-image

current_tag := `curl -s \
  -H "Authorization: Bearer $(curl -s "https://ghcr.io/token?scope=repository:seungjin/leloi-linux:pull" | jq -r '.token')" \
  https://ghcr.io/v2/seungjin/leloi-linux/tags/list \
  | jq -r '.tags[]' | sort -V | grep -v latest | tail -1`

base-image:
    #!/usr/bin/env bash
    cd /workspace/src
    next_tag=$(( {{ current_tag }} + 1 ))
    current_tag={{ current_tag }}

    buildah bud --format docker --layers -f Containerfile -t leloi-linux:$next_tag-temp > /dev/null 2>&1

    buildah pull ghcr.io/seungjin/leloi-linux:$current_tag > /dev/null 2>&1

    local_image_id=$(buildah inspect --format '{{ "{{" }} .FromImageID {{ "}}" }}' localhost/leloi-linux:$next_tag-temp)
    remote_image_id=$(buildah inspect --format '{{ "{{" }} .FromImageID {{ "}}" }}' ghcr.io/seungjin/leloi-linux:$current_tag)

    if [[ "$local_image_id" == "$remote_image_id" ]]; then
        echo "[{\"result\": \"No image pushed\"}]" 
        exit 0
    fi

    skopeo login "$CONTAINER_REPO" -u "$CONTAINER_REPO_USERNAME" -p "$CONTAINER_REPO_PASSWORD"
    skopeo copy containers-storage:localhost/leloi-linux:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux:$next_tag
    skopeo copy containers-storage:localhost/leloi-linux:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux:latest
    echo "[{\"result\": \"New image: ghcr.io/seungjin/leloi-linux:$next_tag\"}]"
    exit 0
