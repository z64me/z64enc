#export PATH="$PATH:/opt/n64/bin"
FILE   = src/$(CODEC)
OBJ    = src/$(CODEC).o
BIN    = bin/$(CODEC)
PUT    = bin/util/put        # this utility generates the cloudpatch

# N64 toolchain
CC      = mips64-gcc
LD      = mips64-ld
OBJCOPY = mips64-objcopy
OBJDUMP = mips64-objdump

# default compilation flags
CFLAGS = -DNDEBUG -Wall -Wno-main -mno-gpopt -fomit-frame-pointer -G 0 -Os --std=gnu99 -mtune=vr4300 -mabi=32 -mips3 -mno-check-zero-division -mno-explicit-relocs -mno-memcpy
LDFLAGS = --emit-relocs -T

# display compilation options
default:
	@echo "type: make z64enc GAME=game CODEC=CODEC"
	@echo "  GAME options"
	@echo "    oot-debug      build for OoT debug"
	@echo "    oot-ntsc-10    build for OoT NTSC 1.0"
	@echo "    mm-u           build for MM U"
	@echo "  CODEC options"
	@echo "    yaz"
	@echo "    ucl"

# every GAME option should have a matching .ld of the same name
LDFILE = src/ld/$(GAME).ld

# ROMOFS is the rom offset where we inject the code
ROMOFS = $(shell cat $(LDFILE) | grep ROMOFS | head -c 8)

# ROMJAL is the rom offset of the jal that invokes the original
#        function; this gets overwritten with one that will call
#        the new function
ROMJAL = $(shell cat $(LDFILE) | grep ROMJAL | head -c 8)

# MMJUMP is the rom offset of the original decompression function;
#        it happens to be invoked by `code` when processing yaz
#        archives; because these patches are meant to support both
#        compressed and decompressed versions of MM, modifying `code`
#        directly is not viable, especially considering its contents
#        can be rearranged and the file itself could be relocated; the
#        cleanest solution is to simply place a jump at the start of
#        the old function, redirecting it to the new function
MMJUMP = $(shell cat $(LDFILE) | grep MMJUMP | head -c 8)

# MAXBYTES is the number of bytes that have been deemed safe to
#          overwrite with custom code
MAXBYTES = $(shell cat $(LDFILE) | grep MAXBYTES | head -n1 | sed -e 's/\s.*$$//' | head -c -1)

# TARGET is the cloudpatch that will be created, of the form
#        "patch/codec/game_z64enc_codec.txt"
#        this may seem verbose, but consider how cryptic mm-u.txt
#        would be in a messy download folder
# NOTE   you can change this to a rom to target a rom directly; if
#        you do that, you will want to add something to this makefile
#        to produce a clean rom each run
TARGET = $(shell printf 'patch/' && printf $(CODEC) && printf '/' && printf $(GAME) && printf '_z64enc_' && printf $(CODEC) && printf '.txt')

# add the linker file for the chosen ga me to the compilation flags
LDFLAGS += $(LDFILE)

# fetch DEFINEs from the linker file
CFLAGS += $(shell cat $(LDFILE) | grep DEFINE | sed -e 's/\s.*$$//')

z64enc: all

all: clean build rompatch

build: $(OBJ)
	@mkdir -p patch/$(CODEC)
	@mkdir -p bin/util
	@$(LD) -o $(FILE).elf $(OBJ) $(LDFLAGS)
	@$(OBJCOPY) -R .MIPS.abiflags -O binary $(FILE).elf $(FILE).bin
	@printf "$(FILE).bin: "
	@stat --printf="%s" $(FILE).bin
	@printf " out of "
	@printf $(MAXBYTES)
	@printf " bytes used\n"
	@gcc -o bin/util/put src/util/put.c
	@mv src/*.bin src/*.elf src/*.o bin

rompatch:
	@$(PUT) $(TARGET) --file $(ROMOFS) $(BIN).bin
	@$(PUT) $(TARGET) --jal $(ROMJAL) $(shell $(OBJDUMP) -t $(BIN).elf | grep .text.startup | head -c 8)
# NOTE the following is MM only
	@if [ $(shell echo $(GAME) | head -c 3) = "mm-" ]; then\
		$(PUT) $(TARGET) --jump $(MMJUMP) $(shell $(OBJDUMP) -t $(BIN).elf | grep .text.startup | head -c 8); \
	fi

clean:
	@rm -vf $(TARGET)
