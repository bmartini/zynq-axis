#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>

int main(int argc, char *argv[])
{
	int i = 0;
	int total = 0;

	if (argc < 3) {
		printf("Usage: %s <phys_addr> <length>\n", argv[0]);
		return 0;
	}

	//off_t offset = 462422016;
	off_t offset = atoi(argv[1]);
	size_t len = atoi(argv[2]);
	printf("phys_addr: %ld, %02x, length: %ld\n", (long int)offset, (unsigned int)offset,
	       (long int)len);

	int fd = open("/dev/mem", O_SYNC);
	unsigned short *mem =
	    (unsigned short *)mmap(NULL, len, PROT_READ | PROT_WRITE,
				   MAP_PRIVATE, fd, offset);

	if (mem == NULL) {
		printf("Can't map memory\n");
		return -2;
	}

//      for (i = 0; i < len; ++i) {
//              mem[i] = 0xDEAD;
//      }

	for (i = 0; i < len; ++i) {
		if (0xDEAD == mem[i]) {
			total++;
			printf("%6d, %10ld, %02x, %02x\n", total, (offset + i),
			       (unsigned int)(offset + i), (int)mem[i]);
		}
	}
	printf("\n");

	return 0;
}
