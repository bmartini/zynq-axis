#include <interface.h>

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>

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

	int fd = open("/dev/mem", O_SYNC);
	unsigned int *mem =
	    (unsigned int *)mmap(NULL, len, PROT_READ | PROT_WRITE, MAP_PRIVATE,
				 fd, offset);

	if (mem == NULL) {
		printf("Can't map memory\n");
		return -2;
	}

	// configure axis to write to memory
	printf("config start\n");
	cfg_write(CFG_AXIS_ADDR, 2);
	cfg_write(CFG_AXIS_DATA, offset);
	cfg_write(CFG_AXIS_DATA, len);
	printf("config done\n");

	// send data to be written over cfg bus
	printf("write start\n");
	for (i = 0; i < len; ++i) {
		cfg_write(CFG_HP0_DST_DATA, i + 1);
		//cfg_write(CFG_HP0_DST_DATA, 0);
	}
	printf("hp0 dst cnt: %d\n", cfg_read(CFG_HP0_DST_CNT));
	printf("write done\n");

	// check memory for data
	for (i = 0; i < len; ++i) {
		printf("%6d, %10ld, %02x, hex: %x,\tbinary: %d\n", i + 1,
		       (offset + (sizeof(mem[0]) * i)),
		       (unsigned int)(offset + (sizeof(mem[0]) * i)),
		       (int)mem[i], (int)mem[i]);
	}

	if (munmap(mem, len) < 0) {
		printf("Can't unmap memory\n");
		return -3;
	}

	if (axis_exit() != 0) {
		return -1;
	}

	printf("\ndone\n");

	return 0;
}
