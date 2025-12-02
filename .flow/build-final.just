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

    buildah bud -f Containerfile -t ghcr.io/seungjin/leloi-linux:$next_tag-temp > /dev/null 2>&1

    rm -fr /tmp/work
    mkdir /tmp/work
    skopeo copy containers-storage:ghcr.io/seungjin/leloi-linux:$next_tag-temp oci:/tmp/work/local:$next_tag-temp >/dev/null
    skopeo copy docker://ghcr.io/seungjin/leloi-linux:$current_tag oci:/tmp/work/remote:$current_tag >/dev/null

    if diff "/tmp/work/index.json" "/tmp/work/index.json" >/dev/null \
       && diff -r "/tmp/work/blobs" "/tmp/work/blobs" >/dev/null ; then
       # Images are the samep
       echo "[{\"result\": \"No Image Created\"}]"
       exit 0
    fi

    buildah login "$CONTAINER_REPO" -u "$CONTAINER_REPO_USERNAME" -p "$CONTAINER_REPO_PASSWORD"
    buildah push ghcr.io/seungjin/leloi-linux:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux:$next_tag
    buildah push ghcr.io/seungjin/leloi-linux:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux:latest
    #buildah rmi ghcr.io/seungjin/leloi-linux:$next_tag-temp
    echo "[{\"result\": \"New image: ghcr.io/seungjin/leloi-linux:$next_tag\"}]"
    exit 0
