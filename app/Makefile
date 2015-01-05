CC = gcc
LDFLAGS := -linterface
CFLAGS := -c -Wall -Werror
INCLUDES := -I.

EXECUTABLE = \
	read-memory \
	test-cfg


.PHONY : all
all : $(EXECUTABLE)


.c.o :
	$(CC) $(INCLUDES) $(CFLAGS) $< -o $@


read-memory : read-memory.o
	$(CC) $< -o $@ $(LDFLAGS)


test-cfg : test-cfg.o
	$(CC) $< -o $@ $(LDFLAGS)


.PHONY : clean
clean :
	rm -f *.o $(EXECUTABLE)
