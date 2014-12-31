#ifndef INTERFACE_H
#define INTERFACE_H

#ifdef __cplusplus
extern "C" {
#endif

#define REGISTER_NB 32

	int axis_init(const char *path);

	int axis_exit();

#ifdef __cplusplus
}
#endif
#endif				/* INTERFACE_H */
