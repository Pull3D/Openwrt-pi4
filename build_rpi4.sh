#!/bin/bash

OUTPUT="$(pwd)/images"
BUILD_VERSION="22.03.5"
BUILDER="https://downloads.openwrt.org/releases/${BUILD_VERSION}/targets/bcm27xx/bcm2711/openwrt-imagebuilder-${BUILD_VERSION}-bcm27xx-bcm2711.Linux-x86_64.tar.xz"
KERNEL_PARTSIZE=256 #Kernel-Partitionsize in MB
ROOTFS_PARTSIZE=8192 #Rootfs-Partitionsize in MB
BASEDIR=$(realpath "$0" | xargs dirname)

# download image builder
if [ ! -f "${BUILDER##*/}" ]; then
	wget "$BUILDER"
	tar xJvf "${BUILDER##*/}"
fi

[ -d "${OUTPUT}" ] || mkdir "${OUTPUT}"

cd openwrt-*/

# clean previous images
make clean

# Packages are added if no prefix is given, '-packaganame' does not integrate a package
sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=$KERNEL_PARTSIZE/g" .config
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=$ROOTFS_PARTSIZE/g" .config

make image  PROFILE="rpi-4" \
           PACKAGES="base-files bcm27xx-gpu-fw busybox ca-bundle cypress-firmware-43455-sdio cypress-nvram-43455-sdio-rpi-4b \
                    dnsmasq dropbear e2fsprogs firewall4 fstools iwinfo kmod-brcmfmac kmod-fs-vfat kmod-nft-offload \
                    kmod-nls-cp437 kmod-nls-iso8859-1 kmod-sound-arm-bcm2835 kmod-sound-core kmod-usb-hid kmod-usb-net-lan78xx libc \
                    libgcc libustream-wolfssl logd mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg partx-utils ppp ppp-mod-pppoe \
                    procd procd-seccomp procd-ujail uci uclient-fetch urandom-seed wpad-basic-wolfssl kmod-usb-storage luci-compat \
                    luci-lib-ipkg cfdisk resize2fs kmod-usb-storage-extras kmod-usb-storage-uas usbutils block-mount ntfs-3g \
                    kmod-fs-ext4 wget-ssl lsblk luci-compat luci-lib-ipkg kmod-usb-net-rtl8152 luci luci-ssl kmod-ath9k-htc \
                    nano dockerd luci-app-dockerman adblock luci-app-adblock tcpdump" \
            FILES="${BASEDIR}/files/" \
            BIN_DIR="${OUTPUT}"
