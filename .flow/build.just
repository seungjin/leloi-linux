default:
    #!/usr/bin/env bash
    cd /workspace/src
    buildah bud -f Containerfile-base -t foo:2
