#ifndef INTERFACE_H
#define INTERFACE_H

#ifdef __cplusplus
extern "C" {
#endif

#define REGISTER_NB 32
#define MEM_SIZE (63*1024*1024)

	// init/exit function for device interface
	int axis_init(const char *path);

	int axis_exit();

	// configuration bus
	void cfg_write(unsigned int addr, unsigned int data);

	int cfg_read(unsigned int addr);

	// dma memory
	void *mem_alloc(const int length, const int byte_nb);

	int mem_alloc_size(const int length, const int byte_nb);

	int mem_alloc_length(const int length, const int byte_nb);

#ifdef __cplusplus
}
#endif
#endif				/* INTERFACE_H */
