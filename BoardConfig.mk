#
# Copyright (C) 2018 The Android Open Source Project
# Copyright (C) 2019-2022 TeamWin Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

# This contains the module build definitions for the hardware-specific
# components for this device.
#
# As much as possible, those components should be built unconditionally,
# with device-specific names to avoid collisions, to avoid device-specific
# bitrot and build breakages. Building a component unconditionally does
# *not* include it on all devices, so it is safe even with hardware-specific
# components.

# Default device path
DEVICE_PATH := device/$(PRODUCT_BRAND)/$(TARGET_DEVICE)

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := $(TARGET_ARCH_VARIANT)
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := $(TARGET_CPU_VARIANT)
TARGET_2ND_CPU_VARIANT_RUNTIME := $(TARGET_CPU_VARIANT_RUNTIME)

ENABLE_CPUSETS := true
ENABLE_SCHEDBOOST := true

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := $(PRODUCT_PLATFORM)
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := true

# Kernel
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET     := 0x01000000
# Same command line as the LineageOS 22.2 kernel 4.19 boot image, so the
# TWRP ramdisk can also boot Android when installed into boot.
BOARD_KERNEL_CMDLINE := \
    androidboot.hardware=qcom \
    ehci-hcd.park=3 \
    lpm_levels.sleep_disabled=1 \
    service_locator.enable=1 \
    swiotlb=2048 \
    androidboot.configfs=true \
    androidboot.usbcontroller=a800000.dwc3 \
    loop.max_part=7 \
    androidboot.veritymode=eio \
    printk.devkmsg=on \
    androidboot.boot_devices=soc/c0c4000.sdhci \
    androidboot.selinux=permissive \
    loglevel=3
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
TARGET_KERNEL_ARCH := arm64
# Kernel 4.19 from FPSensor/android_kernel_motorola_sdm660-4.19
# (vendor/payton_defconfig), the same one LineageOS 22.2 boots.
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/$(BOARD_KERNEL_IMAGE_NAME)

# Platform
TARGET_BOARD_PLATFORM := $(TARGET_BOOTLOADER_BOARD_NAME)
TARGET_BOARD_PLATFORM_GPU := qcom-adreno512
TARGET_USES_HARDWARE_QCOM_BOOTCTRL := true
QCOM_BOARD_PLATFORMS += $(TARGET_BOARD_PLATFORM)

# Partitions
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x04000000
BOARD_USERDATAIMAGE_PARTITION_SIZE := 20749172224 # 20749204992 - 32768
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Retrofit dynamic partitions, same layout as LineageOS 22.2: each slot's
# super is its system + oem partitions, with the metadata on system.
BOARD_SUPER_PARTITION_BLOCK_DEVICES := system oem
BOARD_SUPER_PARTITION_METADATA_DEVICE := system
BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 4328521728
BOARD_SUPER_PARTITION_OEM_DEVICE_SIZE := 603979776
BOARD_SUPER_PARTITION_SIZE := 4932501504
BOARD_SUPER_PARTITION_GROUPS := payton_dynamic_partitions
BOARD_PAYTON_DYNAMIC_PARTITIONS_SIZE := 4928307200
BOARD_PAYTON_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    product \
    system \
    system_ext \
    vendor

BOARD_ROOT_EXTRA_FOLDERS := bt_firmware \
                            dsp \
                            firmware \
                            persist

# Workaround for error copying vendor files to recovery ramdisk
TARGET_COPY_OUT_VENDOR := vendor

# Recovery
TARGET_OTA_ASSERT_DEVICE := payton
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_SELECT_BUTTON := true
TARGET_RECOVERY_DEVICE_MODULES += \
    libion \
    libxml2 \
    vendor.display.config@1.0 \
    vendor.display.config@2.0

# Enable A/B Specific Flags
BOARD_USES_RECOVERY_AS_BOOT := true
TW_INCLUDE_FASTBOOTD := true

# Encryption
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_RESETPROP := true
TW_USE_FSCRYPT_POLICY := 1
BOARD_USES_QCOM_FBE_DECRYPTION := true
# Keep the boot image header the same as LineageOS 22.2 (Android 15,
# 2026-10). Keymaster upgrades the FBE key blobs to the patch level of
# the running boot image when they are used, and refuses to downgrade
# them, so decrypting /data from a TWRP with a newer patch level would
# leave Android unable to unlock its own keys. Bump these together with
# the LineageOS security patch.
PLATFORM_VERSION := 15
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH := 2026-10-01
PRODUCT_ENFORCE_VINTF_MANIFEST := true
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

# TWRP specific build flags
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TW_THEME := portrait_hdpi
TW_SCREEN_BLANK_ON_BOOT := true
RECOVERY_SDCARD_ON_DATA := true
BOARD_PROVIDES_GPTUTILS := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TW_BRIGHTNESS_PATH := /sys/class/leds/lcd-backlight/brightness
TW_MAX_BRIGHTNESS := 255
TW_INCLUDE_NTFS_3G := true
TW_EXTRA_LANGUAGES := true
TW_INPUT_BLACKLIST := hbtp_vm
TW_EXCLUDE_TWRPAPP := true
TW_NO_USB_STORAGE := true
TW_INCLUDE_REPACKTOOLS := true
TW_HAS_EDL_MODE := true

RECOVERY_LIBRARY_SOURCE_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/libion.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libxml2.so \
    $(TARGET_OUT_SYSTEM_EXT_SHARED_LIBRARIES)/vendor.display.config@1.0.so \
    $(TARGET_OUT_SYSTEM_EXT_SHARED_LIBRARIES)/vendor.display.config@2.0.so

# TWRP Debug Flags
#TWRP_EVENT_LOGGING := true
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true
TARGET_RECOVERY_DEVICE_MODULES += debuggerd
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/debuggerd
TARGET_RECOVERY_DEVICE_MODULES += strace
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/strace

#
# For local builds only
#
# TWRP zip installer
ifneq ($(wildcard bootable/recovery/installer/.),)
    USE_RECOVERY_INSTALLER := true
    RECOVERY_INSTALLER_PATH := bootable/recovery/installer
endif

# Custom TWRP Versioning
ifneq ($(wildcard device/common/version-info/.),)
    CUSTOM_TWRP_VERSION_PREFIX := UNOFFICIAL

    include device/common/version-info/custom_twrp_version.mk

    ifeq ($(CUSTOM_TWRP_VERSION),)
        CUSTOM_TWRP_VERSION := $(shell date +%Y%m%d)-01
    endif
endif
#
# end local build flags
#
