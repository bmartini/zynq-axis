# U-Boot, Kernel and the Devicetree

A current Kernel and the kernel source is require to build the AXIS kernel
module. The Devicetree is used by the kernel to identify the AXIS hardware.
While U-Boot tools are used when building the kernel to package it into the
finial uImage file.


## Dependencies

Install the latest Vivado from Xilinx, as of writing the current version is
Vivado 2015.4.

Clone the Xilinx u-boot and Linux kernel repos.

```bash
git clone https://github.com/Xilinx/linux-xlnx.git
git clone https://github.com/Xilinx/u-boot-xlnx.git
```

The following system decencies are needed to enable the Vivado cross compile
tool chain to compile the u-boot and kernel.


### Ubuntu

```bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386
sudo apt-get install device-tree-compiler
```

### CentOS 6.6

```bash
sudo yum install /lib/ld-linux.so.2
sudo yum install dtc
```


## Set Environmental Variables

```bash
. /opt/Xilinx/Vivado/2015.4/settings64.sh
export CROSS_COMPILE=arm-xilinx-linux-gnueabi-
export ARCH=arm
export PATH=$PWD/u-boot-xlnx/tools:$PATH
```


## Compile U-Boot

Select the Zynq platform your system will target, for example zynq_zc706_config
or zynq_zed_config etc.


```bash
cd u-boot-xlnx
make zynq_zc706_config
make
```


## Compile Kernel

Use menuconfig to customize the kernel with extra drives, e.g., USB camera
modules etc. Even if not changing the default configuration the menuconfig
should still be entered to ensure config files are written.

```bash
cd linux-xlnx
make xilinx_zynq_defconfig
make menuconfig
make UIMAGE_LOADADDR=0x8000 uImage
```


## Compile Devicetree

Edit the Zynq dts file and add the AXIS node.

```bash
make zynq-zc706.dtb
```
