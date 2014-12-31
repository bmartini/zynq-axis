#ifndef INTERFACE_H
#define INTERFACE_H

#ifdef __cplusplus
extern "C" {
#endif

#define REGISTER_NB 32

	// init/exit function for device interface
	int axis_init(const char *path);

	int axis_exit();

	// configuration bus
	void cfg_write(unsigned int addr, unsigned int data);

	int cfg_read(unsigned int addr);


#ifdef __cplusplus
}
#endif
#endif				/* INTERFACE_H */
