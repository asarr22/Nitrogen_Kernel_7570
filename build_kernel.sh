#!/bin/bash

export ARCH=arm64
export CROSS_COMPILE=/home/sarr/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export ANDROID_MAJOR_VERSION=p
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
make on5xelte_defconfig
make -j$BUILD_JOB_NUMBER
