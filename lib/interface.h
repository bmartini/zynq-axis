#ifndef INTERFACE_H
#define INTERFACE_H

#ifdef __cplusplus
extern "C" {
#endif

#define REGISTER_NB 32
#define MEM_SIZE (126*1024*1024)

	// init/exit function for device interface
	int axis_init(const char *path);

	int axis_exit();

	// configuration bus
	void cfg_write(unsigned int addr, unsigned int data);

	void cfg_write_array(unsigned int addr, unsigned int *data, int length);

	void cfg_write_sequence(unsigned int *addr,
				unsigned int *data, int length);

	int cfg_read(unsigned int addr);

	void cfg_poll(unsigned int addr, unsigned int data);

	// dma memory
	void *mem_alloc(const int length, const int byte_nb);

	int mem_alloc_size(const int length, const int byte_nb);

	int mem_alloc_length(const int length, const int byte_nb);

	// axis ports
	unsigned int axis_port_id(const int index, const int dirc);

	unsigned int axis_memory_addr(void *ptr);

	void *axis_memory_offset(unsigned int offset);

	unsigned int axis_stream_length(const int length, const int byte_nb);

#ifdef __cplusplus
}
#endif
#endif				/* INTERFACE_H */
