#!/bin/bash

# debug
set -x

# load variables
source "/etc/libvirt/hooks/kvm.conf"

# unload vfio-pci
# modprobe -r vfio_virqfd
modprobe -r vfio_pci_core
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio_virqfd
modprobe -r vfio

# rebind gpu
virsh nodedev-reattach $VIRSH_GPU_VIDEO
virsh nodedev-reattach $VIRSH_GPU_AUDIO
virsh nodedev-reattach $VIRSH_HD_AUDIO
virsh nodedev-reattach $VIRSH_USB_CONTROLLER
virsh nodedev-reattach $VIRSH_NIC

# bind efi framebuffer
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

# rebind vtconsoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo 1 > /sys/class/vtconsole/vtcon1/bind

# read nvidia x config
sleep 2
nvidia-xconfig --query-gpu-info > /dev/null 2>&1

sleep 2
# load nvidia
modprobe nvidia_drm
modprobe nvidia_modeset
modprobe drm_kms_helper
modprobe nvidia
modprobe drm
modprobe nvidia_uvm
modprobe r8169
modprobe xhci-hcd
modprobe snd_hda_intel

#enable eth0
ip link set eth0 up

sleep 2
# restart display manager
# dinitctl start sddm
# dinitctl restart sddm
# dinitctl start nvidia-persistenced
systemctl enable sddm.service
systemctl start sddm.service

# set tuned profile
tuned-adm profile throughput-performance 

