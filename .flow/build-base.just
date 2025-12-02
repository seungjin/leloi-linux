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

    buildah bud -f Containerfile-base -t ghcr.io/seungjin/leloi-linux-base:$next_tag-temp > /dev/null 2>&1

    remote_layers=$(skopeo inspect docker://ghcr.io/seungjin/leloi-linux-base:$current_tag | jq -r '.Layers[]')
    local_layers=$(skopeo inspect containers-storage:ghcr.io/seungjin/leloi-linux-base:$next_tag-temp | jq -r '.Layers[]')


    if diff <(printf "%s\n" "$local_layers") <(printf "%s\n" "$remote_layers") >/dev/null 2>&1; then
       # Images are the samep
       echo "[{\"result\": \"No Image Created\"}]"
       exit 0
    fi

    buildah login "$CONTAINER_REPO" -u "$CONTAINER_REPO_USERNAME" -p "$CONTAINER_REPO_PASSWORD"
    buildah push ghcr.io/seungjin/leloi-linux-base:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux-base:$next_tag
    buildah push ghcr.io/seungjin/leloi-linux-base:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux-base:latest
    #buildah rmi ghcr.io/seungjin/leloi-linux-base:$next_tag-temp
    echo "[{\"result\": \"New image: ghcr.io/seungjin/leloi-linux-base:$next_tag\"}]"
    exit 0
