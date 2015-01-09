#include <interface.h>

#include <stdio.h>
#include <stdlib.h>

#define SRC 0
#define DST 1

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

	if (argc != 2) {
		fprintf(stderr, "Usage: %s <uio-dev-file>\n", argv[0]);
		return 1;
	}

	if (axis_init(argv[1]) != 0) {
		return 1;
	}
	// alloc memory from interface
	int *array = (int *)mem_alloc(100, sizeof(int));

	for (i = 0; i < 100; i++) {
		array[i] = 100 + i;
	}
	// configure axis to write to memory
	cfg_write(CFG_AXIS_ADDR, axis_port_id(0, SRC));
	cfg_write(CFG_AXIS_DATA, axis_memory_addr(array));
	cfg_write(CFG_AXIS_DATA, axis_stream_length(100, sizeof(int)));

	// display data that was read using axis
	printf("read start\n");
	cfg_read(CFG_HP0_SRC_DATA);	// prime cfg register
	for (i = 0; i < 100; i++) {
		printf("%d ", cfg_read(CFG_HP0_SRC_DATA));
	}
	printf("\nhp0 src cnt: %d\n", cfg_read(CFG_HP0_SRC_CNT));

	if (axis_exit() != 0) {
		return 1;
	}

	printf("\ndone\n");

	return 0;
}
