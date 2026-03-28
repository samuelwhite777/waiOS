#!/bin/bash
# 🧬 waiOS Genesis - Fundação de Particionamento e Subvolumes
# Objetivo: Preparar o disco virtual para o mecanismo de snapshots

echo "🛠️  Iniciando a fundação do waiOS..."

# 1. Definir o disco (Alvo padrão da VM: /dev/vda)
DISK="/dev/vda"

# 2. Limpeza total e Particionamento GPT
sgdisk -Z $DISK
sgdisk -n 1:0:+512M -t 1:ef00 $DISK # Partição EFI (Boot)
sgdisk -n 2:0:0     -t 2:8300 $DISK # Partição ROOT (Btrfs)

# 3. Formatação
mkfs.fat -F32 "${DISK}1"
mkfs.btrfs -f "${DISK}2"

# 4. Criação dos Subvolumes (O Segredo da Resiliência)
mount "${DISK}2" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var
umount /mnt

# 5. Montagem Estruturada com Compressão ZSTD (Performance Nitro)
mount -o noatime,compress=zstd,subvol=@ "${DISK}2" /mnt
mkdir -p /mnt/{boot/efi,home,.snapshots,var}
mount -o noatime,compress=zstd,subvol=@home "${DISK}2" /mnt/home
mount -o noatime,compress=zstd,subvol=@snapshots "${DISK}2" /mnt/.snapshots
mount -o noatime,compress=zstd,subvol=@var "${DISK}2" /mnt/var
mount "${DISK}1" /mnt/boot/efi

# 6. Bootstrap do Sistema Base
# linux-zen: O Kernel de baixa latência (Toji Mode)
pacstrap /mnt base linux-zen linux-firmware btrfs-progs nano networkmanager

echo "✅ Fase Genesis concluída. O esqueleto do waiOS está montado no disco!"
