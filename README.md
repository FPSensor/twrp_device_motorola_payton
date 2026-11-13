# TWRP Device configuration for Motorola Moto X4 (payton)

Copyright 2018 - The OmniROM Project
Copyright 2022 - The TeamWin Recovery Project

For building TWRP for Motorola Moto X4 ONLY.

This branch matches the LineageOS 24.0 port of payton to kernel 4.19.
It doesn't work with kernel 4.4 ROMs: use TeamWin's android-12.1 branch
for those.

### Kernel Source
https://github.com/moto-sdm660/android_kernel_motorola_sdm660
(branch lineage-24.0, `vendor/sdm660-perf_defconfig` plus
`vendor/ext_config/moto-sdm660.config` and `vendor/ext_config/payton.config`).
`prebuilt/Image.gz-dtb` is built from it.

### Decryption
The data of LineageOS 24.0 can be decrypted, also with a lock screen
PIN. Two things make that work on kernel 4.19:

- `/dev/block/mmcblk0rpmb` links to the RPMB char device. The keymaster
  TA reads RPMB to use the rollback resistant FBE keys and fails with
  error -8 without it.
- `ro.twrp.fscrypt.legacy_keyring` makes vold add the keys to the
  session keyring. Keys added to the filesystem are dropped whenever
  recovery remounts /data, so the credential could no longer be checked.

### Partitions
The usual static A/B layout: `system_a/b`, and `oem_a/b` holding vendor.
The TWRP ramdisk carries the first stage fstab, so it can still start
Android when installed in boot: the bootloader passes skip_initramfs on
a normal boot, which the 4.19 kernel turns into
androidboot.force_normal_boot.
That fstab mounts /metadata in first stage too: Android 17 keeps its
aconfig flag storage there and doesn't boot without it.

The boot image header must carry the same OS version and security patch
level as the ROM (currently Android 17, 2026-11). Keymaster upgrades
the FBE key blobs to the patch level of the running boot image when
TWRP decrypts /data, and Android can't use upgraded blobs afterwards.

### Device specifications
=====================================

Basic   | Spec Sheet
-------:|:-------------------------
CPU     | Octa-core (8x2.21 GHz Cortex A53)
CHIPSET | Qualcomm SDM630 Snapdragon 630
GPU     | Adreno 508
Memory  | 3, 4, 6 GB
Shipped Android Version | 7.1.1 (Nougat)
Storage | 32, 64GB
Battery | 3000 mAh
Dimensions | 148.4 x 73.4 x 8 mm (5.84 x 2.89 x 0.31 in)
Display | 1080 x 1920 pixels, 5.2" LTPS IPS LCD 16:9 ratio (~424 ppi density)
Rear Camera 1 (main | 12 MP f/2.0 1.4-micron pixels and dual pixel autofocus
Rear Camera 2 (ultrawide) | 8 MP f/2.2 and fixed focus
Front Camera | 16 MP with flash and fixed focus

<p align="center">
<img height="600" src="https://i.imgur.com/pEEUbfS.png" title="Motorola Moto X4 (payton)"/>
</p>

## Compile

First repo init the twrp-12.1 tree:

```
mkdir ~/android/twrp-12.1
cd ~/android/twrp-12.1
repo init -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
mkdir -p .repo/local_manifests
```

Then add the payton local manifest. Besides this tree it brings
moto-sdm660/android_system_vold, TeamWin's vold with an option to keep the
v1 FBE keys in the session keyring (see below):

```
git clone -b twrp-12.1 https://github.com/moto-sdm660/local_manifests .repo/local_manifests
```

Now you can sync your source:

```
repo sync
```

To automatically make the TWRP installer zip, you need to import this commit in the build/make path: https://gerrit.twrp.me/c/android_build/+/5445

Finally execute these:

```
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL=C
lunch twrp_payton-eng
make adbd bootimage
```
