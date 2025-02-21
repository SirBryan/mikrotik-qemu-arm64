#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0); pwd)
source "$SCRIPT_DIR/helpers"

BR=br0

if ip link show br-lan &>/dev/null; then
  BR=br-lan
fi

CPUS=3
MEM=1024

exec qemu-system-aarch64 -m "${MEM:-256}" \
     -pflash AAVMF_CODE.fd \
     -daemonize \
     -vga none  \
     -monitor telnet:127.0.0.1:5801,server,nowait \
     -cpu host -smp "cpus=${CPUS:-2},sockets=1,cores=${CPUS:-2},threads=1" \
     -machine virt,accel=kvm \
     -device nvme,drive=hd0,serial=BDCF8C72-9BE7-4118-B274-EAD8B0982915,bootindex=0 \
     -drive if=none,file=root.qcow2,id=hd0,media=disk,discard=unmap,detect-zeroes=unmap \
     -device virtio-net-pci,netdev=netdev0,mq=on,packed=on,vectors=10,rx_queue_size=1024,tx_queue_size=256 \
     -netdev tap,vhost=on,ifname=vnet0,id=netdev0\
     "$@"

#  -serial chardev:term0 -chardev stdio,id=term0 \


#  -netdev bridge,br=$BR,id=netdev0 \
