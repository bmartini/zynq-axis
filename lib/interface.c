#include "interface.h"

#include <assert.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>

static void *cfg;

int axis_init(const char *path)
{
	int fd;
	assert((fd = open(path, O_RDWR)) >= 0);

	cfg =
	    mmap(NULL, REGISTER_NB, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

	close(fd);
	if (cfg == MAP_FAILED) {
		return -1;
	}

	return 0;
}

int axis_exit()
{
	if (munmap(cfg, REGISTER_NB) != 0) {
		perror("Error un-mmapping the axis cfg");
		return -1;
	}

	return 0;
}

void cfg_write(unsigned int addr, unsigned int data)
{
	volatile unsigned int *reg = ((volatile unsigned int *)cfg) + addr;

	*reg = data;
}

int cfg_read(unsigned int addr)
{
	volatile unsigned int *reg = ((volatile unsigned int *)cfg) + addr;

	return *reg;
}
