  #!/bin/bash
#
# Nitrogen Build Script V3.5
# For exynos7570
# Coded by BlackMesa/AnanJaser1211/Asarre @2020
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software

# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Main Dir
CR_DIR=$(pwd)
# Define toolchan path
CR_TC=~/home/sarr/aarch64-linux-android-4.9/bin/aarch64-linux-android-
# Define proper arch and dir for dts files
CR_DTSJ5=arch/arm64/boot/exynos7570-on5xe_common.dtsi
CR_DTSJ5t=arch/arm64/boot/exynos7570-on5xe_common-trble.dtsi
CR_DTSJ3=exynos7570-j3y17lte_common
CR_DTSJ3t=exynos7570-j3y17lte_common
CR_DTS=arch/arm64/boot/dts
CR_DTS_ONEUI=arch/arm64/boot/exynos7570.dtsi
CR_DTS_X6LTE=arch/arm64/boot/exynos7570_x6lte.dtsi
# Define boot.img out dir
CR_OUT=$CR_DIR/Nitrogen/Out
CR_PRODUCT=$CR_DIR/Nitrogen/Product
# Presistant A.I.K Location
CR_AIK=$CR_DIR/Nitrogen/A.I.K
# Main Ramdisk Location
CR_RAMDISK_ONEUI=$CR_DIR/Nitrogen/Oneui
CR_RAMDISK_PORT=$CR_DIR/Nitrogen/Treble_unofficial
CR_RAMDISK_TREBLE=$CR_DIR/Nitrogen/Treble_official
# Compiled image name and location (Image/zImage)
CR_KERNEL=$CR_DIR/arch/arm64/boot/Image
# Compiled dtb by dtbtool
CR_DTB=$CR_DIR/boot.img-dtb
# Kernel Name and Version
CR_VERSION=V3.5
CR_NAME=NitrogenKernel
# Thread count
CR_JOBS=$(nproc --all)
# Target android version and platform (9/p/10/q)
# Target ARCH
export ARCH=arm64
# Current Date
CR_DATE=$(date +%Y%m%d)
# Init build
export CROSS_COMPILE=/home/sarr/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export ANDROID_MAJOR_VERSION=p
export PLATFORM_VERSION=9.0.0
##########################################
# Device specific Variables [SM-G570F)]
CR_DTSFILES_G570F="exynos7570-on5xelte_swa_open_00.dtb exynos7570-on5xelte_swa_open_01.dtb exynos7570-on5xelte_swa_open_02.dtb exynos7570-on5xelte_swa_open_03.dtb exynos7570-on5xelte_swa_open_04.dtb exynos7570-on5xreflte_swa_open_00.dtb"
CR_CONFG_G570F=on5xelte_defconfig
CR_VARIANT_G570F=G570X
# Device specific Variables [SM-J400X]
CR_DTSFILES_J400X="exynos7570-j4lte_mea_open_00.dtb exynos7570-j4lte_mea_open_01.dtb exynos7570-j4lte_mea_open_02.dtb"
CR_CONFG_J400X=j4lte_defconfig
CR_VARIANT_J400X=J400X
# Device specific Variables [SM-J330X]
CR_DTSFILES_J330X="exynos7570-j3y17lte_eur_open_00.dtb exynos7570-j3y17lte_eur_open_01.dtb exynos7570-j3y17lte_eur_open_02.dtb exynos7570-j3y17lte_eur_open_03.dtb exynos7570-j3y17lte_eur_open_04.dtb"
CR_CONFG_J330X=j3y17lte_defconfig
CR_VARIANT_J330X=J330X
# Common configs
CR_CONFIG_TREBLE=treble_defconfig
CR_CONFIG_ONEUI=oneui_defconfig
CR_CONFIG_SPLIT=NULL
CR_CONFIG_HELIOS=helios_defconfig
# Flashable Variables
FL_MODEL=NULL
FL_VARIANT=NULL
FL_DIR=$CR_DIR/Nitrogen/Flashable
FL_EXPORT=$CR_DIR/Nitrogen/Flashable_OUT
FL_MAGISK=$FL_EXPORT/Asarre/magisk/magisk.zip
FL_SCRIPT=$FL_EXPORT/META-INF/com/google/android/updater-script
#####################################################

# Script functions

read -p "Clean source (y/n) > " yn
if [ "$yn" = "Y" -o "$yn" = "y" ]; then
     echo "Clean Build"
     CR_CLEAN="1"
else
     echo "Dirty Build"
     CR_CLEAN="0"
fi

# Treble / OneUI
read -p "Variant? (1 (oneUI) | 2 (Treble) > " aud
if [ "$aud" = "Treble" -o "$aud" = "2" ]; then
     echo "Build Treble Variant"
     CR_MODE="2"
else
     echo "Build OneUI Variant"
     CR_MODE="1"
fi

# Pie / Quack
read -p "Version? (1 (pie) | 2 (quack) > " aud
if [ "$aud" = "quack" -o "$aud" = "2" ]; then
     echo "Building for Android 10"
     CR_ANDROID=q
     CR_PLATFORM=10
else
     echo "Building for Android 9"
     CR_ANDROID=p
     CR_PLATFORM=9.0.0
fi

BUILD_CLEAN()
{
if [ $CR_CLEAN = 1 ]; then
     echo " "
     echo " Cleaning build dir"
     make clean && make mrproper
     rm -r -f $CR_DTB
     rm -rf $CR_DTS/.*.tmp
     rm -rf $CR_DTS/.*.cmd
     rm -rf $CR_DTS/*.dtb
     rm -rf $CR_DIR/.config
     rm -rf $CR_DTS/exynos7570.dtsi
     rm -rf $CR_OUT/*.img
     rm -rf $CR_OUT/*.zip
fi
if [ $CR_CLEAN = 0 ]; then
     echo " "
     echo " Skip Full cleaning"
     rm -r -f $CR_DTB
     rm -rf $CR_DTS/.*.tmp
     rm -rf $CR_DTS/.*.cmd
     rm -rf $CR_DTS/*.dtb
     rm -rf $CR_DIR/.config
     rm -rf $CR_DTS/exynos7570.dtsi
fi
}

BUILD_IMAGE_NAME()
{
	CR_IMAGE_NAME=$CR_NAME-$CR_VERSION-$CR_VARIANT-$CR_DATE

  # Flashable_script
  if [ $CR_VARIANT = $CR_VARIANT_G570F-TREBLE ]; then
    FL_VARIANT="G570X-Treble"
    FL_MODEL=j5f
  fi
  if [ $CR_VARIANT = $CR_VARIANT_G570F-ONEUI ]; then
    FL_VARIANT="G570X-OneUI"
    FL_MODEL=j5f
  fi
  if [ $CR_VARIANT = $CR_VARIANT_J400X-TREBLE ]; then
    FL_VARIANT="J400X-Treble"
    FL_MODEL=j4
  fi
  if [ $CR_VARIANT = $CR_VARIANT_J400X-ONEUI ]; then
    FL_VARIANT="J400X-OneUI"
    FL_MODEL=j4
  fi
  if [ $CR_VARIANT = $CR_VARIANT_J330X-TREBLE ]; then
    FL_VARIANT="J330X-Treble"
    FL_MODEL=j3
  fi
  if [ $CR_VARIANT = $CR_VARIANT_J330X-ONEUI ]; then
    FL_VARIANT="J330X-OneUI"
    FL_MODEL=j3
  fi
}

BUILD_GENERATE_CONFIG()
{
  # Only use for devices that are unified with 2 or more configs
  echo "----------------------------------------------"
	echo " "
	echo "Building defconfig for $CR_VARIANT"
  echo " "
  # Respect CLEAN build rules
  BUILD_CLEAN
  if [ -e $CR_DIR/arch/$CR_ARCH/configs/tmp_defconfig ]; then
    echo " cleanup old configs "
    rm -rf $CR_DIR/arch/$CR_ARCH/configs/tmp_defconfig
  fi
  echo " Copy $CR_CONFIG "
  cp -f $CR_DIR/arch/$CR_ARCH/configs/$CR_CONFIG $CR_DIR/arch/$CR_ARCH/configs/tmp_defconfig
  if [ $CR_CONFIG_SPLIT = NULL ]; then
    echo " No split config support! "
  else
    echo " Copy $CR_CONFIG_SPLIT "
    cat $CR_DIR/arch/$CR_ARCH/configs/$CR_CONFIG_SPLIT >> $CR_DIR/arch/$CR_ARCH/configs/tmp_defconfig
  fi
  if [ $CR_MODE = 2 ]; then
    echo " Copy $CR_CONFIG_USB "
    cat $CR_DIR/arch/$CR_ARCH/configs/$CR_CONFIG_USB >> $CR_DIR/arch/$CR_ARCH/configs/tmp_defconfig
  fi
  if [ $CR_MODE = 1 ]; then
    echo " Copy $CR_CONFIG_USB "
    cat $CR_DIR/arch/$CR_ARCH/configs/$CR_CONFIG_USB >> $CR_DIR/arch/$CR_ARCH/configs/tmp_defconfig
  fi
  echo " Copy $CR_CONFIG_HELIOS "
  cat $CR_DIR/arch/$CR_ARCH/configs/$CR_CONFIG_HELIOS >> $CR_DIR/arch/$CR_ARCH/configs/tmp_defconfig
  echo " Set $CR_VARIANT to generated config "
  CR_CONFIG=tmp_defconfig
}

BUILD_OUT()
{
    echo " "
    echo "----------------------------------------------"
    echo "$CR_VARIANT kernel build finished."
    echo "Compiled DTB Size = $sizdT Kb"
    echo "Kernel Image Size = $sizT Kb"
    echo "Boot Image   Size = $sizkT Kb"
    echo "Image Generated at $CR_PRODUCT/$CR_IMAGE_NAME.img"
    echo "Zip Generated at $CR_PRODUCT/$CR_NAME-$CR_VERSION-$FL_VARIANT-$CR_DATE.zip"
    echo "Press Any key to end the script"
    echo "----------------------------------------------"
}

BUILD_ZIMAGE()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building zImage for $CR_VARIANT"
	export LOCALVERSION=-$CR_IMAGE_NAME
	cp $CR_DTB_MOUNT $CR_DTS/exynos7570-on5xe_common.dtsi
	echo "Make $CR_CONFIG"
	make $CR_DEF
	make -j$CR_JOBS
	if [ ! -e $CR_KERNEL ]; then
	exit 0;
	echo "Image Failed to Compile"
	echo " Abort "
	fi
    du -k "$CR_KERNEL" | cut -f1 >sizT
    sizT=$(head -n 1 sizT)
    rm -rf sizT
	echo " "
	echo "----------------------------------------------"
}
BUILD_DTB()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building DTB for $CR_VARIANT"
	# This source compiles dtbs while doing Image
	./scripts/dtbTool/dtbTool -o $CR_DTB -d $CR_DTS/ -s 2048
	if [ ! -e $CR_DTB ]; then
    exit 0;
    echo "DTB Failed to Compile"
    echo " Abort "
	fi
	rm -rf $CR_DTS/.*.tmp
	rm -rf $CR_DTS/.*.cmd
	rm -rf $CR_DTS/*.dtb
  rm -rf $CR_DTS/exynos7570.dtsi
    du -k "$CR_DTB" | cut -f1 >sizdT
    sizdT=$(head -n 1 sizdT)
    rm -rf sizdT
	echo " "
	echo "----------------------------------------------"
}
PACK_BOOT_IMG()
{
	echo "----------------------------------------------"
	echo " "
	echo "Building Boot.img for $CR_VARIANT"
	# Copy Ramdisk
	cp -rf $CR_RAMDISK/* $CR_AIK
	# Move Compiled kernel and dtb to A.I.K Folder
	mv $CR_KERNEL $CR_AIK/split_img/boot.img-zImage
	mv $CR_DTB $CR_AIK/split_img/boot.img-dtb
	# Create boot.img
	$CR_AIK/repackimg.sh
	# Remove red warning at boot
	echo -n "SEANDROIDENFORCE" » $CR_AIK/image-new.img
  # Copy boot.img to Production folder
	cp $CR_AIK/image-new.img $CR_PRODUCT/$CR_IMAGE_NAME.img
	# Move boot.img to out dir
	mv $CR_AIK/image-new.img $CR_OUT/$CR_IMAGE_NAME.img
	du -k "$CR_OUT/$CR_IMAGE_NAME.img" | cut -f1 >sizkT
	sizkT=$(head -n 1 sizkT)
	rm -rf sizkT
	echo " "
	$CR_AIK/cleanup.sh
}

PACK_FLASHABLE()
{

  echo "----------------------------------------------"
  echo "$CR_NAME $CR_VERSION Flashable Generator"
  echo "----------------------------------------------"
	echo " "
	echo " Target device : $CR_VARIANT "
  echo " Target image $CR_OUT/$CR_IMAGE_NAME.img "
  echo " Prepare Temporary Dirs"
  FL_DEVICE=$FL_EXPORT/Asarre/device/$FL_MODEL/boot.img
  echo " Copy $FL_DIR to $FL_EXPORT"
  rm -rf $FL_EXPORT
  mkdir $FL_EXPORT
  cp -rf $FL_DIR/* $FL_EXPORT
  echo " Generate updater for $FL_VARIANT"
  sed -i 's/FL_NAME/ui_print("* '$CR_NAME'");/g' $FL_SCRIPT
  sed -i 's/FL_VERSION/ui_print("* '$CR_VERSION'");/g' $FL_SCRIPT
  sed -i 's/FL_VARIANT/ui_print("* For '$FL_VARIANT' ");/g' $FL_SCRIPT
  sed -i 's/FL_DATE/ui_print("* Compiled at '$CR_DATE'");/g' $FL_SCRIPT
  echo " Copy Image to $FL_DEVICE"
  cp $CR_OUT/$CR_IMAGE_NAME.img $FL_DEVICE
  echo " Packing zip"
  # TODO: FInd a better way to zip
  # TODO: support multi-compile
  # TODO: Conditional
  cd $FL_EXPORT
  zip -r $CR_OUT/$CR_NAME-$CR_VERSION-$FL_VARIANT-$CR_DATE.zip .
  cd $CR_DIR
  rm -rf $FL_EXPORT
  # Copy zip to production
  cp $CR_OUT/$CR_NAME-$CR_VERSION-$FL_VARIANT-$CR_DATE.zip $CR_PRODUCT
  # Move out dir to BUILD_OUT
  # Respect CLEAN build rules
  BUILD_CLEAN
}

# Main Menu
clear
echo "----------------------------------------------"
echo "$CR_NAME $CR_VERSION Build Script"
echo "----------------------------------------------"
PS3='Please select your option (1-4): '
menuvar=("SM-G570F" "SM-J400X" "SM-J330X" "Build_All" "Exit")
select menuvar in "${menuvar[@]}"
do
    case $menuvar in
        "SM-G570F")
            clear
            echo "Starting $CR_VARIANT_G570F kernel build..."
            CR_CONFIG=$CR_CONFG_G570F
            CR_DTSFILES=$CR_DTSFILES_G570F
            if [ $CR_MODE = "2" ]; then
              echo " Building Treble variant "
              CR_CONFIG_USB=$CR_CONFIG_TREBLE
              CR_VARIANT=$CR_VARIANT_G570F-TREBLE
              CR_RAMDISK=$CR_RAMDISK_PORT
              CR_DTB_MOUNT=$CR_DTSJ5t
			  CR_DEF=on5t_defconfig
            else
              echo " Building OneUI variant "
              CR_CONFIG_USB=$CR_CONFIG_ONEUI
              CR_VARIANT=$CR_VARIANT_G570F-ONEUI
              CR_DTB_MOUNT=$CR_DTSJ5
              CR_RAMDISK=$CR_RAMDISK_ONEUI
			  CR_DEF=on5_defconfig
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            read -n1 -r key
            break
            ;;
        "SM-J400X")
            clear
            echo "Starting $CR_VARIANT_J400X kernel build..."
            CR_DTSFILES=$CR_DTSFILES_J400X
            CR_RAMDISK=$CR_RAMDISK_TREBLE
            CR_CONFIG=$CR_CONFG_J400X
            CR_DTB_MOUNT=$CR_DTS_X6LTE
            export ANDROID_MAJOR_VERSION=$CR_ANDROID
            export PLATFORM_VERSION=$CR_PLATFORM
            if [ $CR_MODE = "2" ]; then
              echo " Building Treble variant "
              CR_CONFIG_USB=$CR_CONFIG_TREBLE
              CR_VARIANT=$CR_VARIANT_J400X-TREBLE
            else
              echo " Building OneUI variant "
              CR_CONFIG_USB=$CR_CONFIG_ONEUI
              CR_VARIANT=$CR_VARIANT_J400X-ONEUI
			  CR_DEF=j4lte_defconfig
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            read -n1 -r key
            break
            ;;
	       "SM-J330X")
            clear
            echo "Starting $CR_VARIANT_J330X kernel build..."
            CR_DTSFILES=$CR_DTSFILES_J330X
            CR_RAMDISK=$CR_RAMDISK_TREBLE
            CR_CONFIG=$CR_CONFG_J330X
            CR_DTB_MOUNT=$CR_DTS_X6LTE
            export ANDROID_MAJOR_VERSION=$CR_ANDROID
            export PLATFORM_VERSION=$CR_PLATFORM
            if [ $CR_MODE = "2" ]; then
              echo " Building Treble variant "
              CR_CONFIG_USB=$CR_CONFIG_TREBLE
              CR_VARIANT=$CR_VARIANT_J330X-TREBLE
			  CR_DEF=j3_defconfig
            else
              echo " Building OneUI variant "
              CR_CONFIG_USB=$CR_CONFIG_ONEUI
              CR_VARIANT=$CR_VARIANT_J330X-ONEUI
  			  CR_DEF=j3y17ltet_defconfig
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            read -n1 -r key
            break
            ;;
        "Build_All")
            echo "Starting $CR_VARIANT_G570F kernel build..."
            CR_CONFIG=$CR_CONFG_G570F
            CR_DTSFILES=$CR_DTSFILES_G570F
            if [ $CR_MODE = "2" ]; then
              echo " Building Treble variant "
              CR_CONFIG_USB=$CR_CONFIG_TREBLE
              CR_VARIANT=$CR_VARIANT_G570F-TREBLE
              CR_RAMDISK=$CR_RAMDISK_PORT
              CR_DTB_MOUNT=$CR_DTS_TREBLE
            else
              echo " Building OneUI variant "
              CR_CONFIG_USB=$CR_CONFIG_ONEUI
              CR_VARIANT=$CR_VARIANT_G570F-ONEUI
              CR_DTB_MOUNT=$CR_DTS_ONEUI
              CR_RAMDISK=$CR_RAMDISK_ONEUI
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            echo "Starting $CR_VARIANT_G570M kernel build..."
            CR_VARIANT=$CR_VARIANT_G570M
            CR_CONFIG=$CR_CONFG_G570M
            CR_DTSFILES=$CR_DTSFILES_G570M
            if [ $CR_MODE = "2" ]; then
              echo " Building Treble variant "
              CR_CONFIG_USB=$CR_CONFIG_TREBLE
              CR_VARIANT=$CR_VARIANT_G570M-TREBLE
              CR_RAMDISK=$CR_RAMDISK_PORT
              CR_DTB_MOUNT=$CR_DTS_TREBLE
            else
              echo " Building OneUI variant "
              CR_CONFIG_USB=$CR_CONFIG_ONEUI
              CR_VARIANT=$CR_VARIANT_G570M-ONEUI
              CR_DTB_MOUNT=$CR_DTS_ONEUI
              CR_RAMDISK=$CR_RAMDISK_ONEUI
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            echo "Starting $CR_VARIANT_J400X kernel build..."
            CR_DTSFILES=$CR_DTSFILES_J400X
            CR_RAMDISK=$CR_RAMDISK_TREBLE
            CR_CONFIG=$CR_CONFG_J400X
            CR_DTB_MOUNT=$CR_DTS_X6LTE
            # Build Oreo WiFi HAL
            export ANDROID_MAJOR_VERSION=$CR_ANDROID
            export PLATFORM_VERSION=$CR_PLATFORM
            if [ $CR_MODE = "2" ]; then
              echo " Building Treble variant "
              CR_CONFIG_USB=$CR_CONFIG_TREBLE
              CR_VARIANT=$CR_VARIANT_J400X-TREBLE
            else
              echo " Building OneUI variant "
              CR_CONFIG_USB=$CR_CONFIG_ONEUI
              CR_VARIANT=$CR_VARIANT_J400X-ONEUI
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            echo "Starting $CR_VARIANT_J330X kernel build..."
            CR_DTSFILES=$CR_DTSFILES_J330X
            CR_RAMDISK=$CR_RAMDISK_TREBLE
            CR_CONFIG=$CR_CONFG_J330X
            CR_DTB_MOUNT=$CR_DTS_X6LTE
            # Build Oreo WiFi HAL
            export ANDROID_MAJOR_VERSION=$CR_ANDROID
            export PLATFORM_VERSION=$CR_PLATFORM
            if [ $CR_MODE = "2" ]; then
              echo " Building Treble variant "
              CR_CONFIG_USB=$CR_CONFIG_TREBLE
              CR_VARIANT=$CR_VARIANT_J330X-TREBLE
            else
              echo " Building OneUI variant "
              CR_CONFIG_USB=$CR_CONFIG_ONEUI
              CR_VARIANT=$CR_VARIANT_J330X-ONEUI
            fi
            BUILD_IMAGE_NAME
            BUILD_GENERATE_CONFIG
            BUILD_ZIMAGE
            BUILD_DTB
            PACK_BOOT_IMG
            PACK_FLASHABLE
            BUILD_OUT
            echo " "
            echo " "
            echo " compilation finished "
            echo " Targets at $CR_OUT"
            echo " "
            echo "Press Any key to end the script"
            echo "----------------------------------------------"
            read -n1 -r key
            break
            ;;
        "Exit")
            break
            ;;
        *) echo Invalid option.;;
    esac
done
