CC = gcc
LDFLAGS := -linterface
CFLAGS := -c -Wall -Werror
INCLUDES := -I.

EXECUTABLE = \
	test-cfg


.PHONY : all
all : $(EXECUTABLE)


.c.o :
	$(CC) $(INCLUDES) $(CFLAGS) $< -o $@


test-cfg : test-cfg.o
	$(CC) $< -o $@ $(LDFLAGS)


.PHONY : clean
clean :
	rm -f *.o $(EXECUTABLE)
