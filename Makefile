#set environment variable RM_INCLUDE_DIR to the location of valkeymodule.h
ifndef RM_INCLUDE_DIR
	RM_INCLUDE_DIR=.
endif

#set environment variable REDIS_INCLUDE_DIR to the location of valkey/src/*.h
ifndef VALKEY_INCLUDE_DIR
	VALKEY_INCLUDE_DIR=../valkey/src/
	LUA_INCLUDE_DIR=../valkey/deps/lua/src
endif

# find the OS
uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

# Compile flags for linux / osx
ifeq ($(uname_S),Linux)
	SHOBJ_CFLAGS ?=  -fno-common -g -ggdb
	SHOBJ_LDFLAGS ?= -shared -Bsymbolic
else
	SHOBJ_CFLAGS ?= -dynamic -fno-common -g -ggdb
	SHOBJ_LDFLAGS ?= -bundle -undefined dynamic_lookup
endif
CFLAGS = -I$(RM_INCLUDE_DIR) -I$(VALKEY_INCLUDE_DIR) -I$(LUA_INCLUDE_DIR) -g -fPIC -O3 -std=gnu11 -Wall -D_GNU_SOURCE
CC=gcc

MODULE = module-shm
MODULE_SRC = \
	module-shm.c \
	lockless-char-fifo/charfifo.c
MODULE_OBJS = $(MODULE_SRC:.c=.o)

PRELOAD = module-shm-preload
PRELOAD_SRC = \
	module-shm-preload.c
PRELOAD_OBJS = $(PRELOAD_SRC:.c=.o)

all: $(MODULE) $(PRELOAD)

$(MODULE): $(MODULE_OBJS)
	$(LD) -o $@.so $^ $(SHOBJ_LDFLAGS) $(LIBS) -g -lrt

$(PRELOAD): $(PRELOAD_OBJS)
	$(LD) -o $@.so $^ $(SHOBJ_LDFLAGS) $(LIBS) -g -lrt -ldl

clean:
	rm -rf *.so *.o */*.o