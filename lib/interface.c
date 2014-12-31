#include "interface.h"

#include <assert.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

static void *cfg;

int axis_init(const char *path)
{
	int fd;
	assert((fd = open(path, O_RDWR)) >= 0);

	cfg =
	    mmap(NULL, REGISTER_NB, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

	close(fd);
	if (cfg == MAP_FAILED) {
		return -1;	// failure
	}

	return 0;
}
