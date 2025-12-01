default:
    #!/usr/bin/env bash
    cd /workspace/src
    next_tag=$(( {{ current_tag }} + 1 ))
    buildah bud -f Containerfile-base -t ghcr.io/seungjin/leloi-linux-base:$next_tag-temp > /dev/null 2>&1
    new_image_id=$(skopeo inspect --format '{{ "{{" }} .Digest {{ "}}" }}' "containers-storage:ghcr.io/seungjin/leloi-linux-base:${next_tag}-temp")
    current_repo_id=$(curl -s -H "Authorization: Bearer $(curl -s 'https://ghcr.io/token?scope=repository:seungjin/leloi-linux-base:pull' | jq -r '.token')" -H 'Accept: application/vnd.oci.image.manifest.v1+json' https://ghcr.io/v2/seungjin/leloi-linux-base/manifests/{{ current_tag }} | jq -r '.config.digest')

    echo $new_image_id
    echo $current_repo_id

    if [[ "$new_image_id" == "$current_repo_id" ]]; then
      buildah rmi "ghcr.io/seungjin/leloi-linux-base:$next_tag-temp"
      echo "[{\"result\": \"No Image Created\"}]"
      exit 0
    fi

    buildah login "$CONTAINER_REPO" -u "$CONTAINER_REPO_USERNAME" -p "$CONTAINER_REPO_PASSWORD"
    buildah push ghcr.io/seungjin/leloi-linux-base:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux-base:$next_tag
    buildah push ghcr.io/seungjin/leloi-linux-base:$next_tag-temp docker://ghcr.io/seungjin/leloi-linux-base:latest
    #buildah rmi ghcr.io/seungjin/leloi-linux-base:$next_tag-temp

current_tag := `curl -s \
  -H "Authorization: Bearer $(curl -s "https://ghcr.io/token?scope=repository:seungjin/leloi-linux-base:pull" | jq -r '.token')" \
  https://ghcr.io/v2/seungjin/leloi-linux-base/tags/list \
  | jq -r '.tags[]' | sort -V | grep -v latest | tail -1`
