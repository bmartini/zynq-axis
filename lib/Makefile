CC = ${CROSS_COMPILE}gcc
CFLAGS := -c -fpic -Wall -Werror
INCLUDES := -I.
LIBOPTS := -shared


.PHONY : all
all : interface


interface.o :
	$(CC) $(CFLAGS) $(INCLUDES) interface.c


interface : interface.o
	$(CC) *.o $(LIBOPTS) -o libinterface.so


install :
	sudo cp ${PWD}/libinterface.so /usr/lib
	sudo cp ${PWD}/interface.h /usr/include
	sudo chmod 0755 /usr/lib/libinterface.so
	sudo ldconfig


uninstall :
	sudo rm /usr/lib/libinterface.so
	sudo rm /usr/include/interface.h
	sudo ldconfig


.PHONY : clean
clean :
	rm -f *.o libinterface.so
