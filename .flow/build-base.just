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

    buildah bud -f Containerfile-base -t leloi-linux-base:$next_tag-temp > /dev/null 2>&1

    LOCAL_DIFFIDS=$(buildah inspect --type image localhost/leloi-linux-base:$next_tag-temp | jq -r '.OCIv1.rootfs.diff_ids[]')

    TMP=$(mktemp -d)
    trap "rm -rf $TMP" EXIT
    skopeo copy docker://ghcr.io/seungjin/leloi-linux-base:$current_tag "oci:$TMP:img" >/dev/null

    MANIFEST=$(jq -r '.manifests[0].digest' "$TMP/index.json")
    CONFIG_DIGEST=$(jq -r '.config.digest' "$TMP/blobs/sha256/${MANIFEST#sha256:}")

    REMOTE_DIFFIDS=$(jq -r '.rootfs.diff_ids[]' "$TMP/blobs/sha256/${CONFIG_DIGEST#sha256:}")

    if diff <(echo "$LOCAL_DIFFIDS") <(echo "$REMOTE_DIFFIDS") >/dev/null; then
        echo "[{\"result\": \"Image not pushed.\"}]"
        exit 0
    fi

    skopeo login "$CONTAINER_REPO" -u "$CONTAINER_REPO_USERNAME" -p "$CONTAINER_REPO_PASSWORD"
    skopeo copy containers-storage:localhost/leloi-linux-base:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux-base:$next_tag
    skopeo copy containers-storage:localhost/leloi-linux-base:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux-base:latest
    #buildah rmi ghcr.io/seungjin/leloi-linux-base:$next_tag-temp
    # echo "[{\"result\": \"New image: ghcr.io/seungjin/leloi-linux-base:$next_tag\"}]"
    exit 0
