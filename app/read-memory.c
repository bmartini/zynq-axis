#include <interface.h>

#include <stdio.h>
#include <stdlib.h>

enum cfg_regsiters {
	CFG_AXIS_ADDR,
	CFG_AXIS_DATA,
	CFG_HP0_DST_CNT,
	CFG_HP0_SRC_CNT,
	CFG_HP0_DST_DATA,
	CFG_HP0_SRC_DATA,
	CFG_EMPTY,
};

int main(int argc, char *argv[])
{
	int i = 0;

	if (axis_init("/dev/axis") != 0) {
		return -1;
	}

	if (argc < 2) {
		printf("Usage: %s <length>\n", argv[0]);
		return 0;
	}

	off_t offset = 0x1b900000;
	size_t len = atoi(argv[1]);
	printf("phys_addr: %ld, %02x, length: %ld\n", (long int)offset,
	       (unsigned int)offset, (long int)len);


	// configure axis to write to memory
	printf("config start\n");
	cfg_write(CFG_AXIS_ADDR, 1);
	cfg_write(CFG_AXIS_DATA, offset);
	cfg_write(CFG_AXIS_DATA, len);
	printf("config done\n");

	// send data to be written over cfg bus
	printf("read start\n");
	cfg_read(CFG_HP0_SRC_DATA); // prime cfg register
	for (i = 0; i < len; ++i) {
		printf("%d ", cfg_read(CFG_HP0_SRC_DATA));
	}
	printf("\nhp0 src cnt: %d\n", cfg_read(CFG_HP0_SRC_CNT));

	if (axis_exit() != 0) {
		return -1;
	}

	printf("\ndone\n");

	return 0;
}
