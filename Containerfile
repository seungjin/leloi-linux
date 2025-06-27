FROM quay.io/fedora/fedora-bootc:42

LABEL org.opencontainers.image.title="LeLoi Linux"
LABEL org.opencontainers.image.description="LeLoi Linux's bootc container image"
LABEL org.opencontainers.image.authors="Seungjin Kim <seungjin@duck.com>"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/seungjin/leloi-linux"

RUN rmdir /opt && ln -s -T /var/opt /opt
RUN mkdir /var/roothome

# PREPARE PACKAGES
COPY --chmod=0644 ./rootfs/usr/local/share/bootc/packages-added /usr/local/share/bootc/packages-added
COPY --chmod=0644 ./rootfs/usr/local/share/bootc/packages-removed /usr/local/share/bootc/packages-removed
COPY --chmod=0644 ./rootfs/etc/yum.repos.d/* /etc/yum.repos.d/

# INSTALL REPOS
RUN dnf -y install dnf5-plugins

# Update - Not recommanded
#RUN dnf update -y

# INSTALL PACKAGES
RUN dnf -y group install workstation-product-environment
#RUN dnf -y install @base-x
RUN dnf -y install initial-setup
#RUN grep -vE '^#' /usr/local/share/bootc/packages-added | xargs dnf -y install --allowerasing 
#RUN dnf install -y $(cat /tmp/packages | grep "^[^#;]")
RUN cat /usr/local/share/bootc/packages-added | grep "^[^#;]" | xargs dnf -y install --allowerasing

# REMOVE PACKAGES
#RUN grep -vE '^#' /usr/local/share/bootc/packages-removed | xargs dnf -y remove
RUN cat /usr/local/share/bootc/packages-removed | grep "^[^#;]" | xargs dnf -y remove
RUN dnf -y autoremove
RUN dnf clean all

# CONFIGURATION
COPY --chmod=0755 ./rootfs/usr/local/bin/* /usr/local/bin/
#COPY --chmod=0644 ./rootfs/etc/skel/leloi-bootc /etc/skel/.bashrc.d/leloi-bootc
COPY --chmod=0600 ./rootfs/usr/lib/ostree/auth.json /usr/lib/ostree/auth.json
COPY --chmod=0644 ./rootfs/etc/vconsole.conf /etc/vconsole.conf
COPY --chmod=0644 ./rootfs/etc/sudoers.d/seungjin /etc/sudoers.d/seungjin

COPY --chmod=0644 ./rootfs/usr/share/xsessions/leftwm.desktop /usr/share/xsessions/leftwm.desktop
COPY --chmod=0644 ./rootfs/usr/share/ibus/component/hangul.xml /usr/share/ibus/component/hangul.xml 

# USERS
#COPY --chmod=0644 ./rootfs/usr/lib/credstore/home.create.seungjin /usr/lib/credstore/home.create.seungjin
#COPY --chmod=0755 ./scripts/* /tmp/scripts/
#RUN /tmp/scripts/config-users
#RUN /tmp/scripts/config-authselect && rm -r /tmp/scripts

# SYSTEMD
#COPY --chmod=0644 ./rootfs/usr/lib/systemd/system/firstboot-setup.service /usr/lib/systemd/system/firstboot-setup.service
#COPY --chmod=0644 ./rootfs/usr/lib/systemd/system/bootc-fetch.service /usr/lib/systemd/system/bootc-fetch.service
#COPY --chmod=0644 ./rootfs/usr/lib/systemd/system/bootc-fetch.timer /usr/lib/systemd/system/bootc-fetch.timer
#COPY --chmod=0644 ./rootfs/usr/lib/systemd/system/set-colemak-keymap.service /usr/lib/systemd/system/set-colemak-keymap.service

#RUN systemctl set-default graphical.target 
RUN ln -sf /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target

#RUN systemctl mask systemd-remount-fs.service
# Created symlink '/etc/systemd/system/systemd-remount-fs.service' → '/dev/null'.
RUN ln -s /dev/null /etc/systemd/system/systemd-remount-fs.service 

##
#RUN systemctl mask packagekit.service
RUN ln -s /dev/null /etc/systemd/system/packagekit.service

#RUN systemctl mask packagekit-offline-update.service
RUN ln -s /dev/null /etc/systemd/system/packagekit-offline-update.service

##

COPY --chmod=755 ./bin/* /usr/local/bin/


RUN systemctl enable gdm 
#RUN systemctl enable firstboot-setup.service
#RUN systemctl mask bootloader-update.service
#RUN systemctl mask bootc-fetch-apply-updates.timer

# RUN systemctl enable set-colemak-keymap.service

# This does not work at Containerfile
RUN gsettings set org.gnome.software allow-updates false
# This does not work at Containerfile
RUN gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"

# CLEAN & CHECK
RUN find /var/log -type f ! -empty -delete
RUN bootc container lint
