#!/bin/bash

# Set default arguments if not provided
KERNEL_DIR=${1:-.}
IMAGE_DIR=${2:-image}

# Start the QEMU instance
echo "Starting QEMU..."

../qemu/build/qemu-system-x86_64 \
    -m 4G \
    -smp 8 \
    -kernel "$KERNEL_DIR/arch/x86/boot/bzImage" \
    -append "console=ttyS0 root=/dev/sda earlyprintk=serial net.ifnames=0 nokaslr" \
    -drive file="$IMAGE_DIR/bookworm.img",format=raw \
    -drive file="$IMAGE_DIR/blknvme",if=none,id=mynvme,format=raw \
    -device nvme,drive=mynvme,serial=deadbeef,id=nvme0,x-tio=on,spdm_port=2323 \
    -net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
    -net nic,model=e1000 \
    -trace enable=nvme_dma_mode_enabled \
    -trace enable=nvme_dma_mode_disabled \
    -trace enable=nvme_bounce_buffer_copy_error \
    -trace file=qemu-instance.log \
    -enable-kvm \
    -nographic \
    -pidfile vm.pid \
    -machine q35
