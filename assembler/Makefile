INSTALL_DIR =$(HOME)/projects/install/asm
OBJECTS = assembler.o
#INCDIRS = -I$(INSTALL_DIR)/include/iverilog-0.8
#LIBDIRS = -L$(INSTALL_DIR)/lib
CFLAGS = -g
CC = g++

all: install

%.o: %.cpp
	$(CC) $(CFLAGS) $(INCDIRS) -c $<
asm16: $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS)
install: asm16
	cp asm16 $(INSTALL_DIR)/.
clean:
	rm -rf asm16 *.o
