FROM ghcr.io/seungjin/leloi-linux-base:latest
# source: https://gitlab.com/fedora/bootc/base-images
# source: https://gitlab.com/fedora/bootc/base-images/-/blob/main/Containerfile?ref_type=heads

LABEL org.opencontainers.image.title="LeLoi Linux"
LABEL org.opencontainers.image.description="LeLoi Linux's bootc container image"
LABEL org.opencontainers.image.authors="Seungjin Kim <seungjin@duck.com>"
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.source="https://github.com/seungjin/leloi-linux"

# PREPARE PACKAGES
COPY --chmod=0644 ./rootfs/usr/local/share/bootc/packages-added /usr/local/share/bootc/packages-added
COPY --chmod=0644 ./rootfs/usr/local/share/bootc/packages-removed /usr/local/share/bootc/packages-removed
COPY --chmod=0644 ./rootfs/etc/yum.repos.d/* /etc/yum.repos.d/

# INSTALL PACKAGES
RUN grep "^[^#;]" /usr/local/share/bootc/packages-added | grep -E '^[A-Ea-e]' | xargs -r dnf -y install --allowerasing
RUN grep "^[^#;]" /usr/local/share/bootc/packages-added | grep -E '^[F-Jf-j]' | xargs -r dnf -y install --allowerasing
RUN grep "^[^#;]" /usr/local/share/bootc/packages-added | grep -E '^[K-Ok-o]' | xargs -r dnf -y install --allowerasing
RUN grep "^[^#;]" /usr/local/share/bootc/packages-added | grep -E '^[P-Tp-t]' | xargs -r dnf -y install --allowerasing
RUN grep "^[^#;]" /usr/local/share/bootc/packages-added | grep -E '^[U-Zu-z]' | xargs -r dnf -y install --allowerasing
RUN grep "^[^#;]" /usr/local/share/bootc/packages-added | grep -E '^[0-9]' | xargs -r dnf -y install --allowerasing

# REMOVE PACKAGES
RUN cat /usr/local/share/bootc/packages-removed | grep "^[^#;]" | xargs -r dnf -y remove
RUN dnf -y autoremove
RUN dnf clean all

# CONFIGURATION
# COPY --chmod=0755 ./rootfs/usr/local/bin/* /usr/local/bin/ # now I use systemd-sysext for /usr/local/bin

COPY --chmod=0644 ./rootfs/etc/skel/leloi-bootc /etc/skel/.bashrc.d/leloi-bootc
COPY --chmod=0600 ./rootfs/usr/lib/ostree/auth.json /usr/lib/ostree/auth.json
COPY --chmod=0644 ./rootfs/etc/vconsole.conf /etc/vconsole.conf
COPY --chmod=0644 ./rootfs/etc/default/keyboard /etc/default/keyboard
# COPY --chmod=0644 ./rootfs/etc/sudoers.d/seungjin /etc/sudoers.d/seungjin
COPY --chmod=0644 ./rootfs/usr/share/ibus/component/hangul.xml /usr/share/ibus/component/hangul.xml 

#RUN systemctl set-default graphical.target 
RUN ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target

#RUN systemctl mask systemd-remount-fs.service
# Created symlink '/etc/systemd/system/systemd-remount-fs.service' → '/dev/null'.
RUN ln -sf /dev/null /etc/systemd/system/systemd-remount-fs.service 

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
