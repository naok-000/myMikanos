#!/usr/bin/env sh
set -eu

if [ $# -lt 1 ]; then
    echo "Usage: $0 <.efi file> [file-or-dir ...]"
    exit 1
fi

EFI_FILE=$1
shift

QEMU=${QEMU:-qemu-system-x86_64}
MEMORY=${MEMORY:-1G}
MONITOR=${MONITOR:-stdio}
FAT_DIR=${FAT_DIR:-}
KEEP_FAT_DIR=${KEEP_FAT_DIR:-}

if [ ! -f "$EFI_FILE" ]; then
    echo "No such file: $EFI_FILE"
    exit 1
fi

QEMU_BIN=$(command -v "$QEMU" || true)
if [ "$QEMU_BIN" = "" ]; then
    echo "No such command: $QEMU"
    exit 1
fi

QEMU_PREFIX=$(cd "$(dirname "$QEMU_BIN")/.." && pwd)
QEMU_SHARE=${QEMU_SHARE:-"$QEMU_PREFIX/share/qemu"}
OVMF_CODE=${OVMF_CODE:-"$QEMU_SHARE/edk2-x86_64-code.fd"}
OVMF_VARS_TEMPLATE=${OVMF_VARS_TEMPLATE:-"$QEMU_SHARE/edk2-i386-vars.fd"}

if [ ! -f "$OVMF_CODE" ]; then
    echo "No such OVMF code file: $OVMF_CODE"
    echo "Set OVMF_CODE or run this script from the Nix dev shell."
    exit 1
fi

if [ ! -f "$OVMF_VARS_TEMPLATE" ]; then
    echo "No such OVMF vars template: $OVMF_VARS_TEMPLATE"
    echo "Set OVMF_VARS_TEMPLATE or run this script from the Nix dev shell."
    exit 1
fi

TMP_FAT_DIR=
VARS_FILE=$(mktemp "${TMPDIR:-/tmp}/mikanos-ovmf-vars.XXXXXX")

cleanup() {
    rm -f "$VARS_FILE"
    if [ "$TMP_FAT_DIR" != "" ] && [ "$KEEP_FAT_DIR" = "" ]; then
        rm -rf "$TMP_FAT_DIR"
    fi
}

trap cleanup EXIT HUP INT TERM

cp "$OVMF_VARS_TEMPLATE" "$VARS_FILE"

if [ "$FAT_DIR" = "" ]; then
    FAT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mikanos-fat.XXXXXX")
    TMP_FAT_DIR=$FAT_DIR
else
    mkdir -p "$FAT_DIR"
fi

mkdir -p "$FAT_DIR/EFI/BOOT"
cp "$EFI_FILE" "$FAT_DIR/EFI/BOOT/BOOTX64.EFI"

for EXTRA in "$@"; do
    if [ ! -e "$EXTRA" ]; then
        echo "No such file or directory: $EXTRA"
        exit 1
    fi
    cp -R "$EXTRA" "$FAT_DIR/"
done

"$QEMU_BIN" \
    -m "$MEMORY" \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$VARS_FILE" \
    -drive if=ide,index=0,media=disk,file=fat:rw:"$FAT_DIR",format=raw \
    -device nec-usb-xhci,id=xhci \
    -device usb-mouse \
    -device usb-kbd \
    -monitor "$MONITOR" \
    ${QEMU_OPTS:-}
