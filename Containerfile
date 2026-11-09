FROM ghcr.io/seungjin/leloi-linux-base:latest

# source: https://gitlab.com/fedora/bootc/base-images
# source: https://gitlab.com/fedora/bootc/base-images/-/blob/main/Containerfile?ref_type=heads

ARG VERSION

LABEL org.opencontainers.image.title="LeLoi Linux"
LABEL org.opencontainers.image.description="LeLoi Linux's bootc container's base image"
LABEL org.opencontainers.image.authors="Seungjin Kim <seungjin@duck.com>"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.source="https://github.com/seungjin/leloi-linux"
LABEL org.opencontainers.image.version="$VERSION"

# PREPARE PACKAGES
COPY --chmod=0644 ./rootfs/usr/local/share/bootc/ /usr/local/share/bootc/
COPY --chmod=0644 ./rootfs/etc/yum.repos.d/ /etc/yum.repos.d/


# systemd-sysusers
COPY ./rootfs/etc/sysusers.d/ /etc/sysusers.d/
RUN systemd-sysusers 


RUN dnf upgrade -y --refresh --setopt=install_weak_deps=False \
    && dnf clean all

# Core System Install
RUN set -e; \
    PKGS=$(sed -e 's/#.*//' -e 's/;.*//' /usr/local/share/bootc/packages-core | tr '\n' ' '); \
    if [ -n "$PKGS" ]; then \
        dnf install -y --setopt=strict=0 --setopt=install_weak_deps=False --allowerasing $PKGS \
        && dnf clean all; \
    fi

# Desktop / GUI Install
RUN set -e; \
    PKGS=$(sed -e 's/#.*//' -e 's/;.*//' /usr/local/share/bootc/packages-desktop | tr '\n' ' '); \
    if [ -n "$PKGS" ]; then \
        dnf install -y --setopt=strict=0 --setopt=install_weak_deps=False --allowerasing $PKGS \
        && dnf clean all; \
    fi

# Dev Tools & Virtualization Install
RUN set -e; \
    PKGS=$(sed -e 's/#.*//' -e 's/;.*//' /usr/local/share/bootc/packages-dev-virt | tr '\n' ' '); \
    if [ -n "$PKGS" ]; then \
        dnf install -y --setopt=strict=0 --setopt=install_weak_deps=False --allowerasing $PKGS \
        && dnf clean all; \
    fi

# Extra Utilities Install
RUN set -e; \
    PKGS=$(sed -e 's/#.*//' -e 's/;.*//' /usr/local/share/bootc/packages-extra | tr '\n' ' '); \
    if [ -n "$PKGS" ]; then \
        dnf install -y --setopt=strict=0 --setopt=install_weak_deps=False --allowerasing $PKGS \
        && dnf clean all; \
    fi

# Removals & Final Cleanup
RUN set -e; \
    PKGS=$(sed -e 's/#.*//' -e 's/;.*//' /usr/local/share/bootc/packages-removed | tr '\n' ' '); \
    if [ -n "$PKGS" ]; then \
        dnf remove -y $PKGS; \
    fi \
    && dnf autoremove -y \
    && dnf clean all \
    && rm -rf /var/cache/dnf /var/cache/libdnf

# root filesystem copy
COPY ./rootfs/ /

# CONFIGURATION

# sudo-rs
# See justfile's sudo-rs.just
# RUN chown root:root /usr/local/bin/sudo
# RUN chmod 4755 /usr/local/bin/sudo

#COPY --chmod=0644 ./rootfs/etc/skel/leloi-bootc /etc/skel/.bashrc.d/leloi-bootc
#COPY --chmod=0600 ./rootfs/usr/lib/ostree/auth.json /usr/lib/ostree/auth.json
#COPY --chmod=0644 ./rootfs/etc/vconsole.conf /etc/vconsole.conf
#COPY --chmod=0644 ./rootfs/etc/default/keyboard /etc/default/keyboard
# COPY --chmod=0644 ./rootfs/etc/sudoers.d/seungjin /etc/sudoers.d/seungjin
#COPY --chmod=0644 ./rootfs/usr/share/ibus/component/hangul.xml /usr/share/ibus/component/hangul.xml 

#RUN systemctl set-default graphical.target 
RUN ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target


#RUN systemctl mask systemd-remount-fs.service
# Created symlink '/etc/systemd/system/systemd-remount-fs.service' → '/dev/null'.
RUN ln -sf /dev/null /etc/systemd/system/systemd-remount-fs.service 

RUN ln -sf /dev/null /usr/lib/systemd/system/cosmic-greeter-daemon.service  
RUN ln -sf /dev/null /usr/lib/systemd/system/cosmic-greeter.service
RUN ln -s /usr/lib/systemd/system/greetd.service /etc/systemd/system/multi-user.target.wants/greetd.service

RUN ln -s /etc/systemd/system/disable-lid-wake.service /etc/systemd/system/multi-user.target.wants/disable-lid-wake.service

##
#RUN systemctl mask packagekit.service
RUN ln -sf /dev/null /etc/systemd/system/packagekit.service

#RUN systemctl mask packagekit-offline-update.service
RUN ln -sf /dev/null /etc/systemd/system/packagekit-offline-update.service

# This does not work at Containerfile
#RUN gsettings set org.gnome.software allow-updates false
# This does not work at Containerfile
#RUN gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"

# CLEAN & CHECK
RUN find /var/log -type f ! -empty -delete
RUN bootc container lint
