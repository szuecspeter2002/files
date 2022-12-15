#!/bin/bash

# debugging
set -x

# load variables we defined
source "/etc/libvirt/hooks/kvm.conf"

# stop display manager
#dinitctl stop sddm
#dinitctl stop nvidia-persistenced
systemctl stop sddm
systemctl disable sddm
ip link set eth0 down

sleep 1

# UNBIND VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# UNBIND EFI-framebuffer
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/unbind

# avoid race condition
sleep 10

# unload nvidia
modprobe -r nvidia_uvm
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r drm_kms_helper
modprobe -r drm
modprobe -r nvidia
modprobe -r r8169
modprobe -r xhci-hcd
modprobe -r snd_hda_intel

# unbind gpu
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO
virsh nodedev-detach $VIRSH_HD_AUDIO
virsh nodedev-detach $VIRSH_USB_CONTROLLER
virsh nodedev-detach $VIRSH_NIC

# load vfio
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1
modprobe vfio_virqfd
modprobe vfio_pci_core

# set tuned profile
tuned-adm profile virtual-host
