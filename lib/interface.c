#include "interface.h"

#include <assert.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

#define AXIS_BUS_BYTES 4
#define AXIS_NB 4
#define SRC 0
#define DST 1

static void *cfg;
static char *mem;
unsigned int mem_start = 0;
unsigned int mem_offset = 0;

int axis_init(const char *path)
{
	int fd;
	FILE *sys_fd;
	char sys_path[1024];
	char uio_name[1024];
	ssize_t len = 0;

	assert((fd = open(path, O_RDWR)) >= 0);

	// configuration bus memory map
	cfg =
	    mmap(NULL, REGISTER_NB, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

	if (cfg == MAP_FAILED) {
		fprintf(stderr,
			"ERROR <Memory Map Failed> could not mmap *cfg* memory\n");
		assert(0);
	}
	// dma array memory map
	mem = (char *)
	    mmap(NULL, MEM_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd,
		 sysconf(_SC_PAGESIZE));

	if (mem == MAP_FAILED) {
		fprintf(stderr,
			"ERROR <Memory Map Failed> could not mmap *mem* memory\n");
		assert(0);
	}
	close(fd);

	// dma ram start address
	if ((len = readlink(path, uio_name, sizeof(uio_name) - 1)) == -1) {
		perror("Error cannot resolve uio driver filename");
		assert(0);
	}

	uio_name[len] = '\0';
	sprintf(sys_path, "%s%s%s",
		"/sys/class/uio/", uio_name, "/maps/map1/addr");

	assert((sys_fd = fopen(sys_path, "r")) >= 0);

	fscanf(sys_fd, "%x", &mem_start);
	fclose(sys_fd);

	return 0;
}

int axis_exit()
{
	if (munmap(cfg, REGISTER_NB) != 0) {
		perror("Error un-mmapping the axis cfg");
		return -1;
	}

	if (munmap(mem, MEM_SIZE) != 0) {
		perror("Error un-mmapping the axis mem");
		return -1;
	}

	return 0;
}

void cfg_write(unsigned int addr, unsigned int data)
{
	volatile unsigned int *reg = ((volatile unsigned int *)cfg) + addr;

	*reg = data;
}

void cfg_write_array(unsigned int addr, unsigned int *data, int length)
{
	int xx;
	volatile unsigned int *reg = ((volatile unsigned int *)cfg) + addr;

	for (xx = 0; xx < length; xx++) {
		*reg = data[xx];
	}
}

void cfg_write_sequence(unsigned int *addr, unsigned int *data, int length)
{
	int xx;
	volatile unsigned int *reg = ((volatile unsigned int *)cfg);

	for (xx = 0; xx < length; xx++) {
		*(reg + addr[xx]) = data[xx];
	}
}

int cfg_read(unsigned int addr)
{
	volatile unsigned int *reg = ((volatile unsigned int *)cfg) + addr;

	return *reg;
}

void cfg_poll(unsigned int addr, unsigned int data)
{
	int test = 0;
	do {
		test = cfg_read(addr);
	} while (data > test) ;
}

void *mem_alloc(const int length, const int byte_nb)
{
	assert(mem);

	// calculate start of next array
	int next_offset = mem_offset + mem_alloc_size(length, byte_nb);

	if (MEM_SIZE < next_offset) {
		fprintf(stderr,
			"ERROR <Out Of Memory> attempted total memory allocation: %i bytes\n",
			next_offset);
		assert(0);
	}
	// pointer to new array
	void *ptr = &mem[mem_offset];

	// update memory pointer to the next free area
	mem_offset = next_offset;

	return ptr;
}

int mem_alloc_size(const int length, const int byte_nb)
{
	assert(length);
	assert(byte_nb);

	int size = length * byte_nb;
	int remainder = size % sysconf(_SC_PAGESIZE);

	if (0 != remainder) {
		size = size + sysconf(_SC_PAGESIZE) - remainder;
	}

	return size;
}

int mem_alloc_length(const int length, const int byte_nb)
{
	assert(length);
	assert(byte_nb);

	return (mem_alloc_size(length, byte_nb) / byte_nb);
}

unsigned int axis_port_id(const int index, const int dirc)
{
	assert(index >= 0);
	assert(index < AXIS_NB);
	assert((dirc == SRC) || (dirc == DST));

	return ((2 * index) + (dirc + 1));
}

unsigned int axis_memory_addr(void *ptr)
{
	assert(((char *)ptr) >= mem);
	assert(((char *)ptr) < (mem + MEM_SIZE));

	return (mem_start + ((unsigned int)ptr) - ((unsigned int)mem));
}

unsigned int axis_stream_length(const int length, const int byte_nb)
{
	assert(length);
	assert(byte_nb);

	int size = length * byte_nb;
	int remainder = size % AXIS_BUS_BYTES;

	if (0 != remainder) {
		size = size + AXIS_BUS_BYTES - remainder;
	}

	return (size / AXIS_BUS_BYTES);
}
