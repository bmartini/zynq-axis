#include <interface.h>

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	if (argc != 2) {
		fprintf(stderr, "Usage: %s <uio-dev-file>\n", argv[0]);
		exit(1);
	}

	if (axis_init(argv[1]) != 0) {
		return 1;
	}

	return 0;
}
