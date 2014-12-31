#include <interface.h>

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	int i;
	int data;

	if (argc != 2) {
		fprintf(stderr, "Usage: %s <uio-dev-file>\n", argv[0]);
		exit(1);
	}

	if (axis_init(argv[1]) != 0) {
		return 1;
	}

	for (i = 0; i < REGISTER_NB; i++) {
		cfg_write(i, ((i * 2) + 1));
	}

	for (i = 0; i < REGISTER_NB; i++) {
		data = cfg_read(i);
		printf("reg %d: %d: %x\n", i, data, data);
	}

	if (axis_exit() != 0) {
		return 1;
	}

	return 0;
}
