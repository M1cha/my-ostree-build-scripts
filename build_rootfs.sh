packages=(
	# Basics
	base
	linux-firmware
	linux-zen
	linux-zen-headers
	intel-ucode
	amd-ucode

	# ostree-related
	efibootmgr
	grub
	ostree
	which

	# Useful filesystem and partitioning utils
	btrfs-progs
	cryptsetup
	dosfstools
	lvm2
	sshfs
	xfsprogs

	# Security
	apparmor
	sudo

	# Utilities
	android-tools
	bash-completion
	bc
	broot
	fd
	git
	htop
	jq
	man-db
	neovim
	ripgrep
	openssh
	sd
	tmux
	usbutils
	yq

	# Containers
	podman
	toolbox

	# VMs
	dmidecode
	dnsmasq
	edk2-ovmf
	gettext
	iptables-nft
	libvirt
	openbsd-netcat
	qemu-full
	virt-manager
	virt-viewer

	# QEMU
	qemu-user-static
	qemu-user-static-binfmt

	# Audio
	pavucontrol
	pipewire
	pipewire-alsa
	pipewire-audio
	pipewire-jack
	pipewire-pulse
	wireplumber

	# GPU
	glxinfo
	vulkan-icd-loader
	vulkan-intel
	vulkan-radeon
	vulkan-tools

	# GUI: basics
	dunst
	ddcutil
	grim
	hyprland
	kdeconnect
	keyd
	polkit-kde-agent
	qt5-wayland
	qt6-wayland
	sddm
	slurp
	xdg-desktop-portal
	xdg-desktop-portal-gtk
	xdg-desktop-portal-hyprland
	xorg-xwayland
	xwaylandvideobridge

	# GUI: fonts
	ttf-dejavu
	ttf-dejavu-nerd
	ttf-font-awesome
	ttf-roboto
	ttf-roboto-mono
	noto-fonts
	noto-fonts-cjk
	noto-fonts-emoji
	noto-fonts-extra
	otf-font-awesome

	# GUI: apps
	alacritty
	eog
	flatpak
	meld
	mpv
	pcmanfm-qt
	gvfs-mtp
	swaylock
	swayidle
	waybar
	wofi

	# Networking
	networkmanager
	wireguard-tools

	# Bluetooth
	bluez
	bluez-utils
	blueberry

	# OBS webcam
	v4l2loopback-dkms
	v4l2loopback-utils
	v4l-utils

	# file sharing
	samba

	# remote unlock
	tinyssh

	# HSM
	ccid
	opensc
	pcsc-tools

	fwupd
)
aur_packages=(
	mkinitcpio-systemd-extras
)

prepare() {
	install -d "$rootfs/etc"
	install -m 0644 files/mkinitcpio.conf "$rootfs/etc/"
	install -m 0644 files/vconsole.conf "$rootfs/etc/"

	install -d "$rootfs/etc/systemd/network-initramfs"
	install -m 0644 files/20-wired.network "$rootfs/etc/systemd/network-initramfs/"

	install -d "$rootfs/etc/ssh"
	install -m 0644 /etc/ssh/ssh_host_ed25519_key "$rootfs/etc/ssh/"

	install -d "$rootfs/root/.ssh"
	install -m 0644 "/root/.ssh/authorized_keys" "$rootfs/root/.ssh/"
}

post_install_early() {
	echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' > /etc/pacman.d/mirrorlist
	pacman-key --init
	pacman-key --populate
}

post_install() {
	mkdir /efi

	ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
	sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen

	sed -i 's/^#\(write-cache\)/\1/' /etc/apparmor/parser.conf

	echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

	install -m 0644 files/modules-load.conf /etc/modules-load.d/ostree.conf
	install -m 0644 files/modprobe.conf /etc/modprobe.d/ostree.conf

	# /usr/lib/sddm/sddm.conf.d would make more sense conceptionally, but
	# for some reason sddm doesn't load configs from readonly mounts.
	cp -r files/sddm-theme /usr/share/sddm/themes/m1cha
	install -d /etc/sddm.conf.d
	install -m 0644 files/sddm.conf /etc/sddm.conf.d/00-ostree.conf

	locale-gen
	systemctl enable apparmor.service
	systemctl enable bluetooth.service
	systemctl enable fwupd.service
	systemctl enable libvirtd.service
	systemctl enable libvirtd.socket
	systemctl enable NetworkManager.service
	systemctl enable pcscd.service
	systemctl enable sddm.service
	systemctl enable smb.service
	systemctl enable sshd.service
	systemctl enable systemd-timesyncd.service
}
