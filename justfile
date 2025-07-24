set shell := ["bash", "-cu"]

#default: build

list +args:
    #!/usr/bin/env python
    import subprocess
    import json
    import datetime
    args = "{{ args }}".split()
    match args[0]:
        case "image":
            a = subprocess.run(["podman", "image", "list", "--format", "json",
                                "ghcr.io/seungjin/leloi-linux"],
                                capture_output=True, text=True).stdout
            b = subprocess.run(["podman", "image", "list", "--format", "json",
                                "ghcr.io/seungjin/leloi-linux-base"],
                                capture_output=True ,text=True).stdout
            c = json.loads(a);
            for i in json.loads(b):
                c.append(i)

            # Print table header
            print(f"{'REPOSITORY':<34} {'TAG':<10} {'IMAGE ID':<12} {'CREATED':<15} {'SIZE'}")
            for info in c:
                image_id = info['Id'][:12]
                repository, tag = info['Names'][0].split(':')
                created_ago = datetime.datetime.now(datetime.UTC) - datetime.datetime.fromtimestamp(info['Created'], datetime.UTC)
                created_str = (
                    f"{int(created_ago.total_seconds() // 3600)} hours ago"
                    if created_ago.days == 0 else
                    f"{created_ago.days} days ago"
                )
                size_gb = f"{info['Size'] / 1_000_000_000:.2f} GB"

                # Print image info
                print(f"{repository:<34} {tag:<10} {image_id:<12} {created_str:<15} {size_gb}")
        case _:
            print( "Command not found: {}".format(args[0]) )

pre:
    #!/usr/bin/env python
    import shutil
    my_list = ["bandwhich", "fish", "lefthk-worker", "leftwm-check", "leftwm-state", "restic",
    "start_vpn_if_not_run.sh", "trashy", "hx", "leftwm", "leftwm-command",
    "leftwm-worker", "rg", "trash"]

    for a in my_list:
        path = shutil.which(a)
        dst = "/var/home/seungjin/Works/ops/leloi-linux/bin/{}".format(a)
        b = shutil.copyfile(path, dst)

build +args:
    #!/usr/bin/env python
    import subprocess
    args = "{{ args }}".split()
    match args[0]:
        case "image":
            print("aaa")
        case "iso":
            subprocess.run(["sudo", "podman", "run", "--rm", "-it", "--privileged",
            "--pull=newer", "--security-opt", "label=type:unconfined_t",
            "-v", "./output:/output",
            "-v", "/var/lib/containers/storage:/var/lib/containers/storage",
            "-v", "./config.toml:/config.toml:ro",
            "quay.io/centos-bootc/bootc-image-builder:latest",
            "--type", "iso",
            "--chown", "1000:1000",
            "--rootfs", "btrfs",
            "ghcr.io/seungjin/leloi-linux-base:latest"
            ])
        case _:
            print( "Command not found: {}".format(args[0]) )

build-foo:
    podman build -f Containerfile-base -t leloi-linux-base:daily .

build2:
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

a:
    #!/usr/local/bin/fish
    set latest_tag (podman image ls ghcr.io/seungjin/leloi-linux-base --format '{{{{.Tag}}' | \
        grep -E '^[0-9]+$' | sort -n | tail -1) 

    if test -z "$latest_tag"
        set new_tag "1"
    else
        set parts (string split . $latest_tag)
        set last (math $parts[-1] + 1)
        set parts[-1] $last
        set new_tag (string join . $parts)
    end

    podman build -f Containerfile-base -t ghcr.io/seungjin/leloi-linux-base:$new_tag .
    podman tag ghcr.io/seungjin/leloi-linux-base:$new_tag ghcr.io/seungjin/leloi-linux-base:latest
    podman push ghcr.io/seungjin/leloi-linux-base:$new_tag
    podman push ghcr.io/seungjin/leloi-linux-base:latest

b:
    #!/usr/local/bin/fish
    set latest_tag (podman image ls ghcr.io/seungjin/leloi-linux --format '{{{{.Tag}}' | \
        grep -E '^[0-9]+$' | sort -n | tail -1) 

    if test -z "$latest_tag"
        set new_tag "1"
    else
        set parts (string split . $latest_tag)
        set last (math $parts[-1] + 1)
        set parts[-1] $last
        set new_tag (string join . $parts)
    end

    podman build -f Containerfile -t ghcr.io/seungjin/leloi-linux:$new_tag .
    podman push ghcr.io/seungjin/leloi-linux:$new_tag

c:
    #!/usr/local/bin/fish
    set VER (podman image ls ghcr.io/seungjin/leloi-linux --format '{{{{.Tag}}' | \
        grep -E '^[0-9]+$' | sort -n | tail -1) 
    podman save -o /tmp/leloi-linux-$VER.tar ghcr.io/seungjin/leloi-linux:$VER && sudo podman load -i /tmp/leloi-linux-$VER.tar && /usr/bin/rm -fr /tmp/lelo-linux-$VER.tar && sudo bootc switch --transport containers-storage ghcr.io/seungjin/leloi-linux:$VER
