# Zynq AXIS: A complete DMA system

This repo contains all the components needed to set up a DMA based project
using the Zynq FPGA from Xilinx. First there is a hardware module called AXIS
that connects to a high performance AXI interface port. Second, there is a
Linux UIO Driver that exposes the low level AXIS control hardware to the Linux
userspace. Third is a userspace library that takes the low level driver
interface and provides a more application friendly interface for the user.
Lastly there are some example applications to demonstrate the use of the above
components.


## Hardware

HDL code is kept in the *hdl* directory, separate from the Xilinx Vivado
project directories to make it easier to share code between projects and also
to upgrade Xilinx tool versions as needed.

To synthesize the bitstream file one must have the Vivado tools installed and
sourced, then simply run the "syn-proj" script from this repos root directory.

``` bash
./syn-proj
```

If there is more then one Xilinx project in the *syn* directory, pass the
projects name as an argument into the syn-proj script to chose it. A bash
completion script can be found in the *util* directory to make working with
this repos scripts easier.


## Linux UIO Driver

This Linux driver has been developed to run on the Xilinx Zynq ARM. It is a
userspace input/output driver (UIO) that enables the passing of register values
to and from the Zynq FPGA. Userspace libraries/applications use this UIO driver
to configure and control the AXIS modules operation. It also controls a
contiguous memory area that is used to pass data between the host (PS) and FPGA
(PL) sides of the Zynq.

### Compile Driver

Kernel modules need to be built against the version of the kernel it will be
inserted in. It is recommended to uses the Linux kernel maintained by Xilinx.

``` bash
git clone https://github.com/Xilinx/linux-xlnx.git
```

The driver module can be compiling outside of the Linux kernel source tree. A
variable 'KDIR' in the Makefile is used to point to the kernel source
directory. The default value has it pointing to the default Linux install
location for kernel sources. However, if cross compiling or if the sources are
in a non-default location the value can be overridden using an exported
environmental variable or as an argument passes into the make command.

```bash
cd zynq-axis/dev/
export KDIR=../../linux-xlnx
make
```

or

```bash
cd zynq-axis/dev/
make KDIR=../../linux-xlnx
```

### Creating Devicetree

The following AXIS device node needs to be added to the Zynq devicetree to
expose the new hardware to the AXIS driver.

```
axis: axis@43C00000 {
	compatible = "xlnx,axis-1.00";
	reg = < 0x43C00000 0x10000 >;
	xlnx,num-mem = <0x1>;
	xlnx,num-reg = <0x20>;
	xlnx,s-axi-min-size = <0x1ff>;
	xlnx,slv-awidth = <0x20>;
	xlnx,slv-dwidth = <0x20>;
};
```

Source code for a usable and tested devicetree has been placed int the *util*
directory of this repo. It is an altered version of the
'arch/arm/boot/dts/zynq-7000.dtsi' file found in the linux-xlnx Xilinx repo,
master branch commit (da2d296bb6b89f7bc7644f6b552b9766ac1c17d5).

Once the kernel has been compiled for the Zynq, place the altered
'zynq-7000-dtsi' file into the kernel 'arch/arm/boot/dts' directory. Then
compile the new devicetree, for the Zedboard run the following command.

```bash
make zynq-zed.dtb
```

### Installing Driver

Use of the driver module requires it to be inserted into the running Linux
kernel. Once inserted it will automatically create a character device file in
'/dev' called '/dev/uio\*'. However, the default permissions will not allow
non-root users to read/write to the file, nor is the numbering consistent if
more then one UIO driver is being used. These problems are overcome by
installing the udev rule file found in this projects *util* directory into the
systems '/etc/udev/rules.d/' directory.

```bash
sudo cp util/80-axis.rules /etc/udev/rules.d/
```

To install the module and have it loaded at boot, first install the udev rule
as shown above and then follow the below instructions.

```bash
sudo mkdir -p /lib/modules/$(uname -r)/extra/
sudo cp axis.ko /lib/modules/$(uname -r)/extra/
sudo depmod -a
sudo modprobe axis
```


## Library

The axis library has to be built and installed on the Zynq before the example
applications can be compiled. The library offers a number of generic functions
for use in configuring the axis hardware.

```bash
cd lib/
make
make install
```


## Applications

The example application demonstrates some simple usage of the AXIS system.

```bash
cd app/
make
```
