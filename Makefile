TARGET := trustcache

OBJS = trustcache.o
OBJS += append.o create.o info.o remove.o
OBJS += machoparse/cdhash.o cache_from_tree.o sort.o
OBJS += uuid/gen_uuid.o uuid/pack.o uuid/unpack.o uuid/parse.o uuid/unparse.o uuid/copy.o
OBJS += compat_strtonum.o

ifeq ($(shell uname -s),Darwin)
	COMMONCRYPTO ?= 1
endif

ifeq ($(COMMONCRYPTO),1)
	CFLAGS += -DCOMMONCRYPTO
else
	LIBS   += -lcrypto
endif

SIGN  := ldid -S
STRIP := strip -rSx -no_code_signature_warning

all: $(TARGET) cdhash

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $@ $(LIBS)
	$(STRIP) $(TARGET)
	$(SIGN) $(TARGET)

cdhash: machoparse/cdhash.c
	$(CC) $(CFLAGS) -DMAIN $^ -o $@ $(LIBS)
	$(STRIP) cdhash
	$(SIGN) cdhash

clean:
	rm -f $(TARGET) $(OBJS) cdhash

.PHONY: all clean
