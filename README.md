# LeLoi Linux 

**LeLoi Linux** is a custom [bootc](https://containers.github.io/bootc/)-based Linux distribution tailored for my laptop, **LeLoi** (a ThinkPad P14s Gen 6 AMD). It is based on Fedora 44 and designed for a developer-centric, immutable, and reproducible workflow.

## Hardware Specifications
- **Model:** ThinkPad P14s Gen 6 AMD ([PSREF](https://psref.lenovo.com/Product/ThinkPad/ThinkPad_P14s_Gen_6_AMD))
- **CPU:** AMD Ryzen™ AI 9 HX PRO 370
- **Display:** 14" WUXGA (1920 × 1200) IPS 60Hz
- **Keymap:** Optimized for US Colemak

## Key Features
- **Immutable Base:** Built on `fedora-bootc:44`.
- **Desktop Environment:** Includes the [COSMIC Desktop Environment](https://github.com/pop-os/cosmic-epoch).
- **Storage:** Btrfs-focused layout with subvolumes (`/`, `/var`, `/var/home`) and LUKS2 encryption.
- **Developer Tools:** Pre-installed with Emacs, Zsh, Podman, Buildah, KVM/QEMU, and more.
- **Security:** `sudo-rs` for safer privilege escalation, firewalld, and locked root account.
- **Modern Defaults:** Uses `dnf5`, `systemd-sysusers`, and `greetd`.
- **Snapshots:** Integrated `snapper` for system rollback capability.

## Getting Started

This project uses `just` as a command runner for common tasks.

### 1. Build the Container Images

You can build the images using `podman` directly or use the provided `just` targets:

- **Base Image:**
  ```bash
  just a  # Builds, tags, and pushes the base image (leloi-linux-base)
  ```
  *Or manually:* `podman build -f Containerfile-base -t leloi-linux-base .`

- **Final Image:**
  ```bash
  just b  # Builds, tags, and pushes the final image (leloi-linux)
  ```
  *Or manually:* `sudo podman build -t leloi-linux .`

### 2. Create a Bootable ISO

To generate an ISO for bare-metal installation:
```bash
just build iso  # Generates ISO from the latest base image
```
Alternatively, to build the final image and generate an ISO in one step:
```bash
just build2
```
The output ISO will be located in the `./output` directory.

### 3. Apply Updates Locally

If you are already running LeLoi Linux and want to switch to a newly built local image:
```bash
just c
```
*Note: This saves the image, loads it into `containers-storage`, and performs a `bootc switch`.*

## Project Structure

- `Containerfile-base`: Defines the base OS (Fedora 44 + COSMIC).
- `Containerfile`: Layered image adding extra packages and configurations.
- `rootfs/`: Overlay files for the root filesystem (systemd services, config files, etc.).
- `config.toml`: Configuration for `bootc-image-builder`, including the Kickstart (`ks.cfg`) logic.
- `justfile`: Automation for building, tagging, and pushing images.
- `scripts/`: Helper scripts for initial setup and user configuration.

## Note 
- As of Oct 29, 2025: `leloi-linux-base:86` and `leloi-linux:217` are Fedora 43 based.
- April 30th, 2026: `leloi-linux-base` transitioned to Fedora 44 base.

## TODO
- [ ] Refine COSMIC configuration.
- [ ] Automate more of the first-boot setup.
