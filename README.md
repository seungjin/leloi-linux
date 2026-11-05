# LeLoi Linux

**LeLoi Linux** is a custom, container-native [bootc](https://containers.github.io/bootc/)-based Linux distribution tailored for the **ThinkPad P14s Gen 6 AMD** (code-named *LeLoi*). It provides a developer-centric, immutable, and fully reproducible environment based on Fedora 45.

## 🚀 Overview

LeLoi Linux leverages the power of `bootc` to manage the operating system as a container image. This allows for transactional updates, easy rollbacks, and a consistent environment across multiple machines or reinstalls.

- **Base OS:** Fedora 45 (via `quay.io/fedora/fedora-bootc:45`)
- **Desktop:** [niri](https://github.com/YaLTeR/niri), a scrollable-tiling Wayland compositor
- **Philosophy:** Immutable core, containerized workloads, and hardware-optimized defaults.

## ✨ Key Features

- **Immutable & Atomic:** OS updates are delivered as container images, ensuring atomicity and easy rollbacks via `bootc`.
- **Advanced Storage:** Btrfs with the subvolumes `/` (`root`), `/var` (`var`) and `/var/home` (`var_home`) on a LUKS2-encrypted partition, configured by the kickstart in `config.toml`.
- **Hardware-optimized Keymap:** US Colemak on the virtual console (`vconsole.keymap` karg, `vconsole.conf`), under Xorg, and via `XKBOPTIONS=ctrl:nocaps`.
- **Developer First:** Pre-loaded with essential tools like Emacs, Zsh, Podman/Buildah, KVM/QEMU/libvirt, git, and a set of prebuilt static binaries (`niri`, `fish`, `nu`, `hx`, `rg`, …) shipped in `rootfs/usr/local/bin`.
- **Security Hardened:**
  - Uses `sudo-rs` for privilege escalation, with a narrow `NOPASSWD` allowlist in `rootfs/etc/sudoers.d/seungjin`.
  - Root account locked by the installer kickstart (`rootpw --lock`).
  - Firewalld enabled.
  - PackageKit and its offline-update service are masked; `systemd-remount-fs` is disabled (bootc manages the root filesystem).
- **Tuned for Daily Use:** Daily `bootc update` via a timer, lid-close hibernate via `logind.conf.d`, and lid wakeup disabled at boot.
- **Modern Stack:** `dnf5` with `fastestmirror=1`, and `systemd-sysusers` for declarative user management.

## 💻 Hardware Specifications

Designed and optimized for the [ThinkPad P14s Gen 6 AMD](https://psref.lenovo.com/Product/ThinkPad/ThinkPad_P14s_Gen_6_AMD):

- **CPU:** AMD Ryzen™ AI 9 HX PRO 370
- **Display:** 14" WUXGA (1920 × 1200) IPS, 400nits, 60Hz
- **Memory:** 64GB LPDDR5x-7500
- **Keymap:** US Colemak (Software-level optimization)

## 🏗️ Project Architecture

The project uses a two-layer build strategy to optimize build times and separation of concerns:

1.  **Base Image (`ghcr.io/seungjin/leloi-linux-base`):** `Containerfile-base` on top of `fedora-bootc:45`. Installs the desktop stack, `NetworkManager`, `linux-firmware` and `initial-setup`, masks PackageKit, and ships `rootfs/usr/lib/os-release`.
2.  **Final Image (`ghcr.io/seungjin/leloi-linux`):** `Containerfile` on top of the base image. Applies the package lists and the `rootfs/` overlay described below.

### Package lists

`rootfs/usr/local/share/bootc/packages-added` and `rootfs/usr/local/share/bootc/packages-removed` are the single source of truth for the final image's packages. The `Containerfile` installs them in alphabetical letter ranges (`A-E`, `F-J`, …) so that adding a package only invalidates a single layer.

### Overlay (`rootfs/`)

`rootfs/` is copied verbatim onto `/` in the final image. It contains:

- `etc/` — sysusers, sudoers, logind, vconsole/keyboard, X11 keymap, vnstat, and the `librewolf` repo.
- `usr/lib/bootc/kargs.d/` — kernel arguments (`vconsole.keymap=us-colemak`).
- `usr/lib/systemd/system/` — `bootc-fetch.{service,timer}`, `disable-lid-wake.service`, `set-colemak-keymap.service`, `firstboot-setup.service`.
- `usr/local/bin/` — prebuilt static binaries.
- `usr/local/share/` — niri session integration and XDG desktop portal configuration.

## 🛠️ Getting Started

This project uses `just` as a command runner.

### Prerequisites
- `podman`
- `just`
- `bootc-image-builder` (run via podman)
- `skopeo` and `jq` (used by `just b` to find the latest tag)
- `gomplate` (only for the legacy `render-ks` recipe)

### 1. Build the Images

You can build and push the images to GHCR using the following shortcuts:

- **Build Base Image:**
  ```bash
  just a  # Increments version, builds, and pushes ghcr.io/seungjin/leloi-linux-base
  ```
- **Build Final Image:**
  ```bash
  just b  # Increments version, builds, and pushes ghcr.io/seungjin/leloi-linux
  ```
- **Build the base locally, without pushing:**
  ```bash
  just build-foo  # Tags the result as leloi-linux-base:daily
  ```

### 2. Generate Bootable Media (ISO)

To generate a bare-metal installation ISO:

- **From the final image (local build):**
  ```bash
  just build2  # Builds final image and then generates ISO
  ```
- **ISO Only (using base image):**
  ```bash
  just build iso
  ```
The output ISO will be placed in the `./output` directory.

### 3. Apply Updates to a Running System

If you are already running LeLoi Linux, you can "push" your local changes to your system:
```bash
just c  # Saves local image, loads it into system storage, and performs 'bootc switch'
```

## 📁 Project Structure

- `Containerfile-base`: The Fedora 45 bootc + niri foundation.
- `Containerfile`: The final layer with extra packages and personal tweaks.
- `rootfs/`: Overlay files (systemd units, configs, static binaries) copied into the image.
- `config.toml`: `bootc-image-builder` customizations. Contains the actual installer kickstart (btrfs subvolumes, LUKS2, locked root) and disables Anaconda's Users module.
- `ks.cfg.template`: A standalone kickstart template, rendered with `just render-ks` via `gomplate` and an untracked `.secrets` file (LUKS passphrase).
- `justfile`: Automation logic for the entire lifecycle.
- `scripts/`: Helper snippets for authselect and user configuration.
- `.flow/`: Buildah-based build logic for self-hosted CI (layer-diff based, skips no-op pushes).
- `output/`: Generated ISOs and manifests (gitignored).

## 🔁 CI

There are no GitHub Actions. Builds are run by a self-hosted CI named `.flow`, driven by `buildah` and `skopeo` (see `.flow/build.just` and `.flow/build-base.just`). A push to GHCR only happens when the image layers actually changed.

## 📝 License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.

---
*Last Updated: November 2026*
