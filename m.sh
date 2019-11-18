#!/bin/bash
CR_DIR=$(pwd)
CR_TC=/home/sarr/aarch64-linux-android-4.9/bin/aarch64-linux-android-
CR_DTS=arch/arm64/boot/dts
CR_OUT=$CR_DIR/MK/Out
CR_AIK=$CR_DIR/MK/A.I.K
CR_RAMDISK=$CR_DIR/MK/Ramdisk
CR_KERNEL=$CR_DIR/arch/arm64/boot/Image
CR_DTB=$CR_DIR/boot.img-dtb
CR_PACKBOOT=$CR_DIR/MK/Out/MINHKA_kernel_j7pro/MINHKA/j730g
CR_VERSION=V2.4
CR_NAME=MINHKA_Kernel
CR_JOBS=`grep processor /proc/cpuinfo|wc -l`
CR_ANDROID=o
CR_PLATFORM=9.0.0
CR_ARCH=arm64
export CROSS_COMPILE=$CR_TC
export ANDROID_MAJOR_VERSION=$CR_ANDROID
export PLATFORM_VERSION=$CR_PLATFORM
export $CR_ARCH
CR_DTSFILES_J4="exynos7570-on5xelte_swa_open_00.dtb exynos7570-on5xelte_swa_open_01.dtb exynos7570-on5xelte_swa_open_02.dtb exynos7570-on5xelte_swa_open_03.dtb exynos7570-on5xelte_swa_open_04.dtb exynos7570-on5xelte_ltn_open_05.dtb"
CR_CONFG_J4=on5xelte_00_defconfig
CR_VARIANT_J4=J4
CLEAN_SOURCE()
{
echo "Cleaning"
#make clean
#make mrproper
rm -r -f $CR_DTB
rm -rf $CR_DTS/.*.tmp
rm -rf $CR_DTS/.*.cmd
rm -rf $CR_DTS/*.dtb
}
DIRTY_SOURCE()
{
echo "Cleaning"
rm -r -f $CR_DTB
rm -rf $CR_DTS/.*.tmp
rm -rf $CR_DTS/.*.cmd
rm -rf $CR_DTS/*.dtb
}
BUILD_ZIMAGE()
{
	echo "Building zImage for $CR_VARIANT"
	export LOCALVERSION=-$CR_NAME-$CR_VERSION-$CR_VARIANT
	make  $CR_CONFG
	make -j$CR_JOBS
}
BUILD_DTB()
{
	echo "Building DTB for $CR_VARIANT"
	export $CR_ARCH
	export CROSS_COMPILE=$CR_TC
	export ANDROID_MAJOR_VERSION=$CR_ANDROID
	make  $CR_CONFG
	make $CR_DTSFILES
	./scripts/dtbTool/dtbTool -o ./boot.img-dtb -d $CR_DTS/ -s 2048
	du -k "./boot.img-dtb" | cut -f1 >sizT
	sizT=$(head -n 1 sizT)
	rm -rf sizT
	echo "Combined DTB Size = $sizT Kb"
	rm -rf $CR_DTS/.*.tmp
	rm -rf $CR_DTS/.*.cmd
	rm -rf $CR_DTS/*.dtb
}
PACK_BOOT_IMG()
{
	echo "Building Boot.img for $CR_VARIANT"
	cp -rf $CR_RAMDISK/* $CR_AIK
	#cp $CR_KERNEL $CR_OUT/kernelv2-1/zImage
	#cp $CR_DTB $CR_OUT/kernelv2-1/dtb
	cp $CR_KERNEL $CR_AIK/split_img/boot.img-zImage
	cp $CR_DTB $CR_AIK/split_img/boot.img-dtb
	$CR_AIK/repackimg.sh
	echo -n "SEANDROIDENFORCE" » $CR_AIK/image-new.img
	cp $CR_AIK/image-new.img $CR_OUT/boot.img
	mv $CR_AIK/image-new.img $CR_OUT/$CR_NAME-$CR_VERSION-$CR_VARIANT.img
	cp $CR_OUT/boot.img  $CR_DIR/Share/J5 Prime
	$CR_AIK/cleanup.sh 
}
            clear
            CLEAN_SOURCE
           # echo "Starting $CR_VARIANT_J4 kernel build..."
            CR_VARIANT=$CR_VARIANT_J4
	    CR_CONFG=$CR_CONFG_J4
            CR_DTSFILES=$CR_DTSFILES_J4
            BUILD_DTB
            echo "$CR_VARIANT kernel build finished."
            echo "$CR_VARIANT Ready at $CR_OUT"
            echo "Combined DTB Size = $sizT Kb"
           

